<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('quiz_questions', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('quiz_id')->constrained('quizzes')->onDelete('cascade');
            
            $table->text('question_text');
            
            // Question type: 'multiple_choice', 'true_false', 'essay'
            $table->enum('question_type', ['multiple_choice', 'true_false', 'essay'])
                  ->default('multiple_choice');
            
            $table->integer('order_number'); // Question order in quiz
            $table->integer('points')->default(10); // Points for correct answer
            
            $table->text('explanation')->nullable(); // Explanation for correct answer
            
            $table->timestamps();
            
            // Indexes
            $table->index('quiz_id');
            $table->index(['quiz_id', 'order_number']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('quiz_questions');
    }
};