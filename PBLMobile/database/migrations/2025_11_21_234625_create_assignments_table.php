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
        Schema::create('assignments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('title');
            $table->text('description')->nullable();
            $table->timestamp('deadline');
            $table->boolean('is_done')->default(false);
            $table->string('color')->default('#5B9FED');
            $table->boolean('has_reminder')->default(true);
            $table->integer('reminder_minutes')->default(30);
            $table->string('last_notification_type')->nullable();
            $table->timestamps();
            
            // Indexes
            $table->index(['user_id', 'is_done']);
            $table->index('deadline');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('assignments');
    }
};
