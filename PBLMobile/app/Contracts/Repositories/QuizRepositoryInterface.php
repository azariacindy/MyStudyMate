<?php

namespace App\Contracts\Repositories;

use App\Models\Quiz;
use Illuminate\Database\Eloquent\Collection;

interface QuizRepositoryInterface
{
    public function findById(int $id): ?Quiz;
    public function findByStudyCard(int $studyCardId): Collection;
    public function create(array $data): Quiz;
}