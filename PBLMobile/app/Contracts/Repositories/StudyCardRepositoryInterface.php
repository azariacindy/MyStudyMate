<?php

namespace App\Contracts\Repositories;

use App\Models\StudyCard;
use Illuminate\Pagination\LengthAwarePaginator;

interface StudyCardRepositoryInterface
{
    public function findById(int $id): ?StudyCard;
    public function findByUser(int $userId, int $perPage = 15): LengthAwarePaginator;
    public function create(array $data): StudyCard;
    public function update(int $id, array $data): StudyCard;
    public function delete(int $id): bool;
}