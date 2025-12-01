<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Quiz extends Model
{
    use HasFactory;

    protected $fillable = [
        'study_card_id',
        'user_id',
        'questions',
        'total_questions',
        'times_attempted',
        'best_score',
    ];

    protected $casts = [
        'questions' => 'array',
        'total_questions' => 'integer',
        'times_attempted' => 'integer',
        'best_score' => 'float',
    ];

    // Relationships
    public function studyCard()
    {
        return $this->belongsTo(StudyCard::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function attempts()
    {
        return $this->hasMany(QuizAttempt::class);
    }

    // Scopes
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeForStudyCard($query, $studyCardId)
    {
        return $query->where('study_card_id', $studyCardId);
    }

    // Methods
    public function updateBestScore($newScore)
    {
        if (is_null($this->best_score) || $newScore > $this->best_score) {
            $this->best_score = $newScore;
            $this->save();
        }
    }

    public function incrementAttempts()
    {
        $this->increment('times_attempted');
    }
}
