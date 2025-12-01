<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class QuizQuestion extends Model
{
    use HasFactory;

    protected $fillable = [
        'quiz_id',
        'question_text',
        'question_type',
        'order_number',
        'points',
        'explanation',
    ];

    protected $casts = [
        'order_number' => 'integer',
        'points' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relationships
    public function quiz()
    {
        return $this->belongsTo(Quiz::class);
    }

    public function answers()
    {
        return $this->hasMany(QuizAnswer::class)->orderBy('order_number');
    }

    public function correctAnswer()
    {
        return $this->hasOne(QuizAnswer::class)->where('is_correct', true);
    }

    public function userAnswers()
    {
        return $this->hasMany(UserQuizAnswer::class);
    }

    // Check question type
    public function isMultipleChoice()
    {
        return $this->question_type === 'multiple_choice';
    }

    public function isTrueFalse()
    {
        return $this->question_type === 'true_false';
    }

    public function isEssay()
    {
        return $this->question_type === 'essay';
    }
}