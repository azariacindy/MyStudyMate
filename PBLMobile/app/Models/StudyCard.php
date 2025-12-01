<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class StudyCard extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'title',
        'notes',
        'quiz_count',
    ];

    protected $casts = [
        'quiz_count' => 'integer',
    ];

    // Relationships
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function quizzes()
    {
        return $this->hasMany(Quiz::class);
    }

    // Scopes
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    public function scopeRecent($query, $limit = 10)
    {
        return $query->orderBy('created_at', 'desc')->limit($limit);
    }

    // Accessors
    public function getWordCountAttribute()
    {
        return str_word_count($this->notes);
    }

    public function getLatestQuizAttribute()
    {
        return $this->quizzes()->latest()->first();
    }
}
