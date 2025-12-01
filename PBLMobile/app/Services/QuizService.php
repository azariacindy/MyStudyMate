<?php

namespace App\Services;

use App\Contracts\Repositories\QuizRepositoryInterface;
use App\Contracts\Repositories\StudyCardRepositoryInterface;
use App\Contracts\Services\QuizServiceInterface;
use App\Models\Quiz;
use App\Models\StudyCard;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

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

        // 2. Extract konten materi (text atau dari PDF)
        $materialContent = $this->extractMaterialContent($studyCard);
        
        if (empty(trim($materialContent))) {
            throw new \Exception('No material content found to generate quiz. Please ensure the material contains text.', 400);
        }

        // Limit text length untuk avoid token limit
        $materialContent = substr($materialContent, 0, 10000);

        // 3. Siapkan prompt untuk DeepSeek
        $numQuestions = $options['num_questions'] ?? 5;
        $prompt = "Generate a quiz with {$numQuestions} multiple-choice questions based on this material. 

For each question, provide:
- question_text: the question
- question_type: 'multiple_choice'
- points: 10
- explanation: brief explanation of the correct answer
- answers: array of 4 answer options, only 1 is correct

Return ONLY valid JSON in this exact format:
{
  \"questions\": [
    {
      \"question_text\": \"...\",
      \"question_type\": \"multiple_choice\",
      \"points\": 10,
      \"explanation\": \"...\",
      \"answers\": [
        {\"answer_text\": \"...\", \"is_correct\": true},
        {\"answer_text\": \"...\", \"is_correct\": false},
        {\"answer_text\": \"...\", \"is_correct\": false},
        {\"answer_text\": \"...\", \"is_correct\": false}
      ]
    }
  ]
}

Material:\n\n" . $materialContent;

        // 4. Panggil DeepSeek API
        $response = Http::withHeaders([
            'Authorization' => 'Bearer ' . config('services.deepseek.api_key'),
            'Content-Type' => 'application/json',
        ])->timeout(60)->post(config('services.deepseek.endpoint'), [
            'prompt' => $prompt,
            'max_tokens' => 3000,
            'temperature' => 0.7,
        ]);

        if (!$response->successful()) {
            Log::error('DeepSeek API Error', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);
            throw new \Exception('Failed to generate quiz from AI: ' . $response->body(), 502);
        }

        $aiResponse = $response->json();
        $questionsData = $aiResponse['questions'] ?? [];

        if (empty($questionsData)) {
            throw new \Exception('AI did not return any questions. Please try again.', 500);
        }

        // 5. Simpan quiz ke database
        $quiz = $this->repository->create([
            'study_card_id'        => $studyCardId,
            'title'                => $studyCard->title . ' - Quiz',
            'description'          => 'Quiz generated automatically by AI from ' . $studyCard->material_type . ' material',
            'total_questions'      => count($questionsData),
            'duration_minutes'     => $options['duration_minutes'] ?? 30,
            'shuffle_questions'    => true,
            'shuffle_answers'      => true,
            'show_correct_answers' => true,
            'generated_by_ai'      => true,
            'ai_model'             => 'deepseek',
        ]);

        // 6. Simpan questions dan answers
        $questionOrder = 1;
        foreach ($questionsData as $questionData) {
            $question = $quiz->questions()->create([
                'question_text' => $questionData['question_text'],
                'question_type' => $questionData['question_type'] ?? 'multiple_choice',
                'order_number'  => $questionOrder++,
                'points'        => $questionData['points'] ?? 10,
                'explanation'   => $questionData['explanation'] ?? null,
            ]);

            $answerOrder = 1;
            foreach ($questionData['answers'] ?? [] as $answerData) {
                $question->answers()->create([
                    'answer_text'  => $answerData['answer_text'],
                    'is_correct'   => $answerData['is_correct'] ?? false,
                    'order_number' => $answerOrder++,
                ]);
            }
        }

        return $quiz->load('questions.answers');
    }

    /**
     * Extract material content dari study card (text atau PDF saja)
     */
    private function extractMaterialContent(StudyCard $studyCard): string
    {
        // Jika material type adalah text
        if ($studyCard->material_type === 'text') {
            return $studyCard->material_content ?? '';
        }

        // Jika material type adalah file
        if ($studyCard->material_type === 'file') {
            $fileUrl = $studyCard->material_file_url;
            $fileType = $studyCard->material_file_type;

            if (empty($fileUrl)) {
                throw new \Exception('File URL is empty', 400);
            }

            // Hanya handle PDF
            if (str_contains(strtolower($fileType), 'pdf')) {
                return $this->extractTextFromPDF($fileUrl);
            }

            // Format lain tidak didukung
            throw new \Exception('Only PDF and text materials are supported for quiz generation. Images/photos are not supported yet.', 400);
        }

        return '';
    }

    /**
     * Extract text dari PDF
     */
    private function extractTextFromPDF(string $fileUrl): string
    {
        try {
            Log::info('Extracting text from PDF', ['url' => $fileUrl]);

            // Download/get file path
            $filePath = $this->getFilePath($fileUrl);

            // Pakai library PDF parser
            $parser = new \Smalot\PdfParser\Parser();
            $pdf = $parser->parseFile($filePath);
            $text = $pdf->getText();

            // Cleanup temp file jika ada
            $this->cleanupTempFile($filePath);

            Log::info('PDF text extracted', ['length' => strlen($text)]);

            if (empty(trim($text))) {
                throw new \Exception('No text found in PDF. The PDF might be image-based or encrypted.');
            }

            return trim($text);
        } catch (\Exception $e) {
            Log::error('PDF extraction failed', ['error' => $e->getMessage()]);
            throw new \Exception('Failed to extract text from PDF: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Get file path from URL atau Storage
     */
    private function getFilePath(string $fileUrl): string
    {
        // Jika path dari Laravel Storage (misal: /storage/study-materials/xxx.pdf)
        $relativePath = str_replace('/storage/', '', $fileUrl);
        $publicPath = 'public/' . $relativePath;
        
        if (Storage::exists($publicPath)) {
            return Storage::path($publicPath);
        }

        // Jika absolute path lokal
        if (file_exists($fileUrl)) {
            return $fileUrl;
        }

        // Jika URL remote, download ke temp
        try {
            $tempFile = tempnam(sys_get_temp_dir(), 'study_material_');
            $extension = pathinfo(parse_url($fileUrl, PHP_URL_PATH), PATHINFO_EXTENSION);
            $tempFileWithExt = $tempFile . '.' . $extension;
            rename($tempFile, $tempFileWithExt);

            $content = file_get_contents($fileUrl);
            
            if ($content === false) {
                throw new \Exception('Failed to download file from URL');
            }

            file_put_contents($tempFileWithExt, $content);

            return $tempFileWithExt;
        } catch (\Exception $e) {
            throw new \Exception('Failed to access file: ' . $e->getMessage());
        }
    }

    /**
     * Cleanup temporary file
     */
    private function cleanupTempFile(string $filePath): void
    {
        // Hanya hapus file di temp directory (jangan hapus file asli di storage)
        if (str_starts_with($filePath, sys_get_temp_dir())) {
            @unlink($filePath);
        }
    }
}