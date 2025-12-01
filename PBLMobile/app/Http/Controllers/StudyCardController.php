<?php

namespace App\Http\Controllers;

use App\Models\StudyCard;
use App\Models\Quiz;
use App\Models\QuizAttempt;
use App\Services\AIService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;

class StudyCardController extends Controller
{
    protected $aiService;

    public function __construct(AIService $aiService)
    {
        $this->aiService = $aiService;
    }

    private function getUserId(Request $request)
    {
        return Auth::id() ?: ($request->header('X-User-Id') ?: ($request->query('user_id') ?: 1));
    }

    public function index(Request $request)
    {
        try {
            $userId = $this->getUserId($request);
            
            $studyCards = StudyCard::forUser($userId)
                ->with('quizzes')
                ->recent(50)
                ->get()
                ->map(function($card) {
                    return [
                        'id' => $card->id,
                        'title' => $card->title,
                        'notes' => $card->notes,
                        'quiz_count' => $card->quiz_count,
                        'word_count' => $card->word_count,
                        'created_at' => $card->created_at,
                        'latest_quiz_id' => $card->latest_quiz?->id,
                    ];
                });

            return response()->json(['success' => true, 'data' => $studyCards], 200);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }

    public function store(Request $request)
    {
        try {
            // Validate input - either notes OR file is required
            $validated = $request->validate([
                'title' => 'required|string|max:255',
                'notes' => 'nullable|string|min:50',
                'file' => 'nullable|file|mimes:pdf,docx,doc,txt|max:10240', // max 10MB
            ]);

            $notes = $validated['notes'] ?? '';

            // If file is uploaded, extract text from it
            if ($request->hasFile('file')) {
                $fileExtractor = new \App\Services\FileExtractorService();
                $file = $request->file('file');

                // Validate file
                if (!$fileExtractor->isValidFileType($file)) {
                    return response()->json([
                        'success' => false,
                        'error' => 'Invalid file type. Allowed: PDF, DOCX, DOC, TXT'
                    ], 422);
                }

                if (!$fileExtractor->isValidFileSize($file)) {
                    return response()->json([
                        'success' => false,
                        'error' => 'File too large. Maximum size: 10MB'
                    ], 422);
                }

                // Extract text from file
                $extractedText = $fileExtractor->extractText($file);
                
                // Combine manual notes with extracted text (if both provided)
                $notes = !empty($notes) ? $notes . "\n\n" . $extractedText : $extractedText;
            }

            // Ensure we have some content
            if (empty($notes) || strlen($notes) < 50) {
                return response()->json([
                    'success' => false,
                    'error' => 'Please provide at least 50 characters of study material (either manually or via file upload)'
                ], 422);
            }

            $studyCard = StudyCard::create([
                'user_id' => $this->getUserId($request),
                'title' => $validated['title'],
                'notes' => $notes,
                'quiz_count' => 0,
            ]);

            return response()->json(['success' => true, 'data' => $studyCard], 201);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 422);
        }
    }

    public function generateQuiz(Request $request, $id)
    {
        try {
            $validated = $request->validate(['question_count' => 'nullable|integer|min:5|max:20']);
            $userId = $this->getUserId($request);
            $studyCard = StudyCard::forUser($userId)->findOrFail($id);
            $questionCount = $validated['question_count'] ?? 5;

            // Get previous quiz questions to avoid duplication
            $previousQuizzes = Quiz::where('study_card_id', $studyCard->id)
                ->orderBy('created_at', 'desc')
                ->limit(3)
                ->get();
            
            $previousQuestions = [];
            foreach ($previousQuizzes as $prevQuiz) {
                foreach ($prevQuiz->questions as $q) {
                    $previousQuestions[] = $q['question'] ?? '';
                }
            }

            try {
                $questions = $this->aiService->generateQuiz(
                    $studyCard->title, 
                    $studyCard->notes, 
                    $questionCount,
                    $previousQuestions
                );
            } catch (\Exception $e) {
                Log::warning('AI failed: ' . $e->getMessage());
                $questions = $this->aiService->generateFallbackQuiz($studyCard->title, $studyCard->notes);
            }

            $quiz = Quiz::create([
                'study_card_id' => $studyCard->id,
                'user_id' => $userId,
                'questions' => $questions,
                'total_questions' => count($questions),
            ]);

            $studyCard->increment('quiz_count');

            return response()->json([
                'success' => true,
                'data' => [
                    'quiz_id' => $quiz->id,
                    'questions' => $questions,
                    'total_questions' => count($questions),
                ],
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }

    public function getQuiz(Request $request, $id)
    {
        try {
            $quiz = Quiz::with('studyCard')->forUser($this->getUserId($request))->findOrFail($id);
            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $quiz->id,
                    'study_card' => ['id' => $quiz->studyCard->id, 'title' => $quiz->studyCard->title],
                    'questions' => $quiz->questions,
                    'total_questions' => $quiz->total_questions,
                    'times_attempted' => $quiz->times_attempted,
                    'best_score' => $quiz->best_score,
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 404);
        }
    }

    public function submitQuiz(Request $request, $id)
    {
        try {
            $validated = $request->validate(['answers' => 'required|array', 'time_spent' => 'nullable|integer']);
            $userId = $this->getUserId($request);
            $quiz = Quiz::forUser($userId)->findOrFail($id);

            $userAnswers = $validated['answers'];
            $correctCount = 0;
            $results = [];

            foreach ($quiz->questions as $index => $question) {
                $userAnswer = $userAnswers[$index] ?? null;
                $isCorrect = $userAnswer === $question['correct_answer'];
                if ($isCorrect) $correctCount++;
                
                $results[] = [
                    'question_index' => $index,
                    'user_answer' => $userAnswer,
                    'correct_answer' => $question['correct_answer'],
                    'is_correct' => $isCorrect,
                    'explanation' => $question['explanation'] ?? null,
                ];
            }

            $score = round(($correctCount / $quiz->total_questions) * 100, 2);

            $attempt = QuizAttempt::create([
                'quiz_id' => $quiz->id,
                'user_id' => $userId,
                'user_answers' => $userAnswers,
                'score' => $score,
                'total_questions' => $quiz->total_questions,
                'correct_answers' => $correctCount,
                'time_spent' => $validated['time_spent'] ?? null,
            ]);

            $quiz->incrementAttempts();
            $quiz->updateBestScore($score);

            return response()->json([
                'success' => true,
                'data' => [
                    'attempt_id' => $attempt->id,
                    'score' => $score,
                    'correct_answers' => $correctCount,
                    'total_questions' => $quiz->total_questions,
                    'passed' => $score >= 60,
                    'results' => $results,
                    'best_score' => $quiz->best_score,
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }

    public function getQuizAttempts(Request $request, $id)
    {
        try {
            $userId = $this->getUserId($request);
            $quiz = Quiz::forUser($userId)->findOrFail($id);
            $attempts = QuizAttempt::forQuiz($id)->forUser($userId)->recent(20)->get();

            return response()->json([
                'success' => true,
                'data' => [
                    'quiz_id' => $quiz->id,
                    'best_score' => $quiz->best_score,
                    'times_attempted' => $quiz->times_attempted,
                    'attempts' => $attempts,
                ],
            ], 200);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }

    public function destroy(Request $request, $id)
    {
        try {
            StudyCard::forUser($this->getUserId($request))->findOrFail($id)->delete();
            return response()->json(['success' => true, 'message' => 'Study card deleted'], 200);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }
}
