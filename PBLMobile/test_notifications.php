<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Assignment;
use App\Models\User;
use Carbon\Carbon;

echo "=== Assignment Notification Test ===\n\n";

// Get test user
$user = User::first();
if (!$user) {
    echo "❌ No user found. Please create a user first.\n";
    exit(1);
}

echo "Using User ID: {$user->id} ({$user->name})\n";
echo "FCM Token: " . ($user->fcm_token ? 'Set ✓' : 'Not set ✗') . "\n\n";

// Create test assignments
echo "Creating test assignments...\n\n";

// 1. H-3 (3 days before deadline)
$h3 = Assignment::create([
    'user_id' => $user->id,
    'title' => 'Assignment H-3 Test',
    'description' => 'This assignment is due in 3 days',
    'deadline' => Carbon::now()->addDays(3)->endOfDay(),
    'color' => '#5B9FED',
    'has_reminder' => true,
    'reminder_minutes' => 30,
    'is_done' => false,
]);
echo "✅ H-3 Assignment created (ID: {$h3->id})\n";
echo "   Deadline: {$h3->deadline->format('Y-m-d H:i:s')}\n";
echo "   Priority: {$h3->priority} ({$h3->priority_label})\n\n";

// 2. D-Day (today)
$dday = Assignment::create([
    'user_id' => $user->id,
    'title' => 'Assignment D-Day Test',
    'description' => 'This assignment is due TODAY!',
    'deadline' => Carbon::today()->endOfDay(),
    'color' => '#F59E0B',
    'has_reminder' => true,
    'reminder_minutes' => 30,
    'is_done' => false,
]);
echo "✅ D-Day Assignment created (ID: {$dday->id})\n";
echo "   Deadline: {$dday->deadline->format('Y-m-d H:i:s')}\n";
echo "   Priority: {$dday->priority} ({$dday->priority_label})\n\n";

// 3. H+3 (3 days overdue)
$hplus3 = Assignment::create([
    'user_id' => $user->id,
    'title' => 'Assignment H+3 Test (Overdue)',
    'description' => 'This assignment is 3 days overdue',
    'deadline' => Carbon::now()->subDays(3)->endOfDay(),
    'color' => '#EF4444',
    'has_reminder' => true,
    'reminder_minutes' => 30,
    'is_done' => false,
]);
echo "✅ H+3 Assignment created (ID: {$hplus3->id})\n";
echo "   Deadline: {$hplus3->deadline->format('Y-m-d H:i:s')}\n";
echo "   Priority: {$hplus3->priority} ({$hplus3->priority_label})\n\n";

// 4. Upcoming (7 days)
$upcoming = Assignment::create([
    'user_id' => $user->id,
    'title' => 'Assignment Upcoming Test',
    'description' => 'This assignment is due in 7 days',
    'deadline' => Carbon::now()->addDays(7)->endOfDay(),
    'color' => '#10B981',
    'has_reminder' => true,
    'reminder_minutes' => 30,
    'is_done' => false,
]);
echo "✅ Upcoming Assignment created (ID: {$upcoming->id})\n";
echo "   Deadline: {$upcoming->deadline->format('Y-m-d H:i:s')}\n";
echo "   Priority: {$upcoming->priority} ({$upcoming->priority_label})\n\n";

echo "=== Summary ===\n";
echo "Total assignments created: 4\n";
echo "Current time: " . Carbon::now()->format('Y-m-d H:i:s') . "\n\n";

echo "To test notifications, run:\n";
echo "php artisan assignments:check-reminders\n\n";

echo "To view assignments:\n";
echo "curl -X GET http://127.0.0.1:8000/api/assignments \\\n";
echo "  -H 'X-User-Id: {$user->id}' \\\n";
echo "  -H 'Accept: application/json'\n\n";

echo "To cleanup (delete test assignments):\n";
echo "php artisan tinker --execute=\"\App\Models\Assignment::whereIn('id', [{$h3->id}, {$dday->id}, {$hplus3->id}, {$upcoming->id}])->delete();\"\n";
