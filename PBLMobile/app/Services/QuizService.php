<?php

namespace App\Services;

use App\Contracts\Repositories\QuizRepositoryInterface;
use App\Contracts\Repositories\StudyCardRepositoryInterface;
use App\Contracts\Services\QuizServiceInterface;
use App\Models\Quiz;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\Http;

class QuizService implements QuizServiceInterface
{
    protected QuizRepositoryInterface $repository;
    protected StudyCardRepositoryInterface $studyCardRepository;

    public function __construct(
        QuizRepositoryInterface $repository,
        StudyCardRepositoryInterface $studyCardRepository
    ) {
        $this->repository = $repository;
        $this->studyCardRepository = $studyCardRepository;
    }

    public function getQuizById(int $id): ?Quiz
    {
        return $this->repository->findById($id);
    }

    public function getQuizzesByStudyCard(int $studyCardId): Collection
    {
        return $this->repository->findByStudyCard($studyCardId);
    }

    public function generateQuizFromAI(int $studyCardId, array $options = []): Quiz
    {
        // 1. Ambil study card
        $studyCard = $this->studyCardRepository->findById($studyCardId);
        if (!$studyCard) {
            throw new \Exception('Study Card not found', 404);
        }

        // 2. Siapkan prompt untuk DeepSeek
        $numQuestions = $options['num_questions'] ?? 5;
        $prompt = "Generate a quiz with {$numQuestions} multiple-choice questions based on this material. Each question must have 4 answer options with only 1 correct answer. Return in JSON format with structure: {\"questions\": [{\"question_text\": \"...\", \"answers\": [{\"answer_text\": \"...\", \"is_correct\": true/false}]}]}. Material:\n\n";
        $prompt .= $studyCard->material_content;

        // 3. Panggil DeepSeek API
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . config('services.deepseek.api_key'),
            'Content-Type' => 'application/json',
        ])->post(config('services.deepseek.endpoint'), [
            'prompt' => $prompt,
            'max_tokens' => 2000,
        ]);

        if (!$response->successful()) {
            throw new \Exception('Failed to generate quiz from AI: ' . $response->body(), 502);
        }

        $aiResponse = $response->json();
        
        // 4. Simpan quiz ke database
        $quiz = $this->repository->create([
            'study_card_id'        => $studyCardId,
            'title'                => $studyCard->title . ' - Quiz',
            'description'          => 'Quiz generated automatically by AI',
            'duration_minutes'     => $options['duration_minutes'] ?? 30,
            'shuffle_questions'    => true,
            'shuffle_answers'      => true,
            'show_correct_answers' => false,
            'generated_by_ai'      => true,
        ]);

        // 5. Simpan questions dan answers
        foreach ($aiResponse['questions'] ?? [] as $questionData) {
            $question = $quiz->questions()->create([
                'question_text' => $questionData['question_text'],
            ]);

            foreach ($questionData['answers'] ?? [] as $answerData) {
                $question->answers()->create([
                    'answer_text' => $answerData['answer_text'],
                    'is_correct'  => $answerData['is_correct'] ?? false,
                ]);
            }
        }

        return $quiz->load('questions.answers');
    }
}