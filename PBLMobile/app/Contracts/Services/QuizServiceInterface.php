<?php

namespace App\Contracts\Services;

use App\Models\Quiz;
use Illuminate\Database\Eloquent\Collection;

interface QuizServiceInterface
{
    public function getQuizById(int $id): ?Quiz;
    public function getQuizzesByStudyCard(int $studyCardId): Collection;
    public function createQuiz(array $data): Quiz;
}