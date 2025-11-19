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
        // Add FCM token to users table (skip if exists)
        if (!Schema::hasColumn('users', 'fcm_token')) {
            Schema::table('users', function (Blueprint $table) {
                $table->text('fcm_token')->nullable()->after('password');
            });
        }

        // Add notification_sent flag to schedules table
        if (!Schema::hasColumn('schedules', 'notification_sent')) {
            Schema::table('schedules', function (Blueprint $table) {
                $table->boolean('notification_sent')->default(false);
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn('fcm_token');
        });

        Schema::table('schedules', function (Blueprint $table) {
            $table->dropColumn('notification_sent');
        });
    }
};
