<?php

namespace App\Services;

use App\Contracts\Repositories\StudyCardRepositoryInterface;
use App\Contracts\Services\StudyCardServiceInterface;
use App\Models\StudyCard;
use Illuminate\Pagination\LengthAwarePaginator;

class StudyCardService implements StudyCardServiceInterface
{
    protected StudyCardRepositoryInterface $repository;

    public function __construct(StudyCardRepositoryInterface $repository)
    {
        $this->repository = $repository;
    }

    public function getAllUserStudyCards(int $userId, int $perPage = 15): LengthAwarePaginator
    {
        return $this->repository->findByUser($userId, $perPage);
    }

    public function getStudyCardById(int $id): ?StudyCard
    {
        return $this->repository->findById($id);
    }

    public function createStudyCard(array $data, int $userId): StudyCard
    {
        $data['user_id'] = $userId;
        return $this->repository->create($data);
    }

    public function updateStudyCard(int $id, array $data, int $userId): StudyCard
    {
        $studyCard = $this->repository->findById($id);
        if (!$studyCard || $studyCard->user_id !== $userId) {
            throw new \Exception('Unauthorized', 403);
        }
        return $this->repository->update($id, $data);
    }

    public function deleteStudyCard(int $id, int $userId): bool
    {
        $studyCard = $this->repository->findById($id);
        if (!$studyCard || $studyCard->user_id !== $userId) {
            throw new \Exception('Unauthorized', 403);
        }
        return $this->repository->delete($id);
    }
}