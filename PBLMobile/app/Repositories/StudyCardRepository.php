<?php

namespace App\Repositories;

use App\Contracts\Repositories\StudyCardRepositoryInterface;
use App\Models\StudyCard;
use Illuminate\Pagination\LengthAwarePaginator;

class StudyCardRepository implements StudyCardRepositoryInterface
{
    protected StudyCard $model;

    public function __construct(StudyCard $model)
    {
        $this->model = $model;
    }

    public function findById(int $id): ?StudyCard
    {
        return $this->model->with(['quizzes'])->find($id);
    }

    public function findByUser(int $userId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->model
            ->where('user_id', $userId)
            ->with(['quizzes'])
            ->latest()
            ->paginate($perPage);
    }

    public function create(array $data): StudyCard
    {
        return $this->model->create($data);
    }

    public function update(int $id, array $data): StudyCard
    {
        $studyCard = $this->model->findOrFail($id);
        $studyCard->update($data);
        return $studyCard->fresh();
    }

    public function delete(int $id): bool
    {
        $studyCard = $this->model->findOrFail($id);
        return $studyCard->delete();
    }
}