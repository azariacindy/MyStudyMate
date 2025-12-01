<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class QuizAnswer extends Model
{
    use HasFactory;

    protected $fillable = [
        'quiz_question_id',
        'answer_text',
        'is_correct',
        'order_number',
    ];

    protected $casts = [
        'is_correct' => 'boolean',
        'order_number' => 'integer',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    // Relationships
    public function question()
    {
        return $this->belongsTo(QuizQuestion::class, 'quiz_question_id');
    }

    public function userAnswers()
    {
        return $this->hasMany(UserQuizAnswer::class, 'selected_answer_id');
    }

    // Get answer label (A, B, C, D)
    public function getLabelAttribute()
    {
        if ($this->order_number === null) return '';
        
        return chr(65 + $this->order_number - 1); // A=65 in ASCII
    }
}