<?php

namespace App\Repositories;

use App\Contracts\Repositories\QuizRepositoryInterface;
use App\Models\Quiz;
use Illuminate\Database\Eloquent\Collection;

class QuizRepository implements QuizRepositoryInterface
{
    protected Quiz $model;

    public function __construct(Quiz $model)
    {
        $this->model = $model;
    }

    public function findById(int $id): ?Quiz
    {
        return $this->model->with(['questions.answers'])->find($id);
    }

    public function findByStudyCard(int $studyCardId): Collection
    {
        return $this->model
            ->where('study_card_id', $studyCardId)
            ->with(['questions'])
            ->latest()
            ->get();
    }

    public function create(array $data): Quiz
    {
        return $this->model->create($data);
    }
}