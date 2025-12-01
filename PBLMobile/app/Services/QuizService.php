<?php

namespace App\Services;

use App\Contracts\Repositories\QuizRepositoryInterface;
use App\Contracts\Services\QuizServiceInterface;
use App\Models\Quiz;
use Illuminate\Database\Eloquent\Collection;

class QuizService implements QuizServiceInterface
{
    protected QuizRepositoryInterface $repository;

    public function __construct(QuizRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function getQuizById(int $id): ?Quiz
    {
        return $this->repository->findById($id);
    }

    public function getQuizzesByStudyCard(int $studyCardId): Collection
    {
        return $this->repository->findByStudyCard($studyCardId);
    }

    public function createQuiz(array $data): Quiz
    {
        return $this->repository->create($data);
    }
}