<?php

namespace App\Contracts\Services;

use App\Models\StudyCard;
use Illuminate\Pagination\LengthAwarePaginator;

interface StudyCardServiceInterface
{
    public function getAllUserStudyCards(int $userId, int $perPage = 15): LengthAwarePaginator;
    public function getStudyCardById(int $id): ?StudyCard;
    public function createStudyCard(array $data, int $userId): StudyCard;
    public function updateStudyCard(int $id, array $data, int $userId): StudyCard;
    public function deleteStudyCard(int $id, int $userId): bool;
}