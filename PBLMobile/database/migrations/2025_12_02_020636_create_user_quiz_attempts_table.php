<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_quiz_attempts', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->foreignUuid('quiz_id')->constrained('quizzes')->onDelete('cascade');
            
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            
            $table->decimal('score', 5, 2)->nullable();
            $table->integer('total_correct')->default(0);
            $table->integer('total_incorrect')->default(0);
            $table->integer('total_questions')->default(0);
            $table->integer('total_points_earned')->default(0);
            $table->integer('total_points_possible')->default(0);
            
            $table->enum('status', ['in_progress', 'completed', 'abandoned', 'expired'])
                  ->default('in_progress');
            
            $table->integer('time_spent_seconds')->nullable();
            
            $table->timestamps();
            
            $table->index('user_id');
            $table->index('quiz_id');
            $table->index(['user_id', 'quiz_id']);
            $table->index('status');
            $table->index('completed_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_quiz_attempts');
    }
};