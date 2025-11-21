<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\User;
use App\Models\Assignment;

echo "=== Checking Notification Requirements ===\n\n";

// 1. Check users and FCM tokens
echo "1. USER FCM TOKENS:\n";
echo str_repeat('-', 50) . "\n";
$users = User::all();
foreach ($users as $user) {
    $hasToken = $user->fcm_token ? '✅' : '❌';
    echo "{$hasToken} User ID {$user->id} ({$user->name}): ";
    echo $user->fcm_token ? substr($user->fcm_token, 0, 30) . '...' : 'NO TOKEN';
    echo "\n";
}

echo "\n2. ASSIGNMENTS REQUIRING NOTIFICATIONS:\n";
echo str_repeat('-', 50) . "\n";

$now = \Carbon\Carbon::now('Asia/Jakarta');
$today = $now->copy()->startOfDay();

// H-3 candidates
$h3Date = $today->copy()->addDays(3);
$h3Assignments = Assignment::where('is_done', false)
    ->where('has_reminder', true)
    ->whereDate('deadline', $h3Date->toDateString())
    ->where(function($q) {
        $q->whereNull('last_notification_type')
          ->orWhere('last_notification_type', '!=', 'h_minus_3');
    })
    ->get();

echo "\nH-3 (Deadline: {$h3Date->format('Y-m-d')}): " . $h3Assignments->count() . " assignments\n";
foreach ($h3Assignments as $a) {
    echo "  - ID {$a->id}: {$a->title} (User: {$a->user_id}, Last notif: " . ($a->last_notification_type ?? 'none') . ")\n";
}

// D-Day candidates
$dDayAssignments = Assignment::where('is_done', false)
    ->where('has_reminder', true)
    ->whereDate('deadline', $today->toDateString())
    ->where(function($q) {
        $q->whereNull('last_notification_type')
          ->orWhere('last_notification_type', '!=', 'd_day');
    })
    ->get();

echo "\nD-Day (Deadline: {$today->format('Y-m-d')}): " . $dDayAssignments->count() . " assignments\n";
foreach ($dDayAssignments as $a) {
    echo "  - ID {$a->id}: {$a->title} (User: {$a->user_id}, Last notif: " . ($a->last_notification_type ?? 'none') . ")\n";
}

// H+3 candidates
$h3AfterDate = $today->copy()->subDays(3);
$h3AfterAssignments = Assignment::where('is_done', false)
    ->where('has_reminder', true)
    ->whereDate('deadline', $h3AfterDate->toDateString())
    ->where(function($q) {
        $q->whereNull('last_notification_type')
          ->orWhere('last_notification_type', '!=', 'h_plus_3');
    })
    ->get();

echo "\nH+3 (Deadline: {$h3AfterDate->format('Y-m-d')}): " . $h3AfterAssignments->count() . " assignments\n";
foreach ($h3AfterAssignments as $a) {
    echo "  - ID {$a->id}: {$a->title} (User: {$a->user_id}, Last notif: " . ($a->last_notification_type ?? 'none') . ")\n";
}

echo "\n3. TIME CHECK:\n";
echo str_repeat('-', 50) . "\n";
echo "Current time: {$now->format('Y-m-d H:i:s')}\n";
echo "Current hour: {$now->hour}\n";
echo "H-3 & D-Day send if hour >= 8: " . ($now->hour >= 8 ? '✅ YES' : '❌ NO (wait until 08:00)') . "\n";
echo "H+3 send if hour >= 9: " . ($now->hour >= 9 ? '✅ YES' : '❌ NO (wait until 09:00)') . "\n";

echo "\n4. FCM SERVICE CHECK:\n";
echo str_repeat('-', 50) . "\n";
$fcmKeyPath = storage_path('app/mystudymate-acfbe-firebase-adminsdk-fbsvc-435c4c6bb6.json');
if (file_exists($fcmKeyPath)) {
    echo "✅ Firebase credentials file exists\n";
    $creds = json_decode(file_get_contents($fcmKeyPath), true);
    echo "   Project ID: " . ($creds['project_id'] ?? 'N/A') . "\n";
    echo "   Path: {$fcmKeyPath}\n";
} else {
    echo "❌ Firebase credentials file NOT FOUND at:\n";
    echo "   {$fcmKeyPath}\n";
}

echo "\n5. SUMMARY:\n";
echo str_repeat('-', 50) . "\n";
$usersWithToken = User::whereNotNull('fcm_token')->count();
$totalUsers = User::count();
$canSendH3 = $h3Assignments->count() > 0 && $now->hour >= 8;
$canSendDDay = $dDayAssignments->count() > 0 && $now->hour >= 8;
$canSendH3After = $h3AfterAssignments->count() > 0 && $now->hour >= 9;

echo "Users with FCM token: {$usersWithToken}/{$totalUsers}\n";
echo "Can send H-3 notifications: " . ($canSendH3 ? '✅ YES' : '❌ NO') . "\n";
echo "Can send D-Day notifications: " . ($canSendDDay ? '✅ YES' : '❌ NO') . "\n";
echo "Can send H+3 notifications: " . ($canSendH3After ? '✅ YES' : '❌ NO') . "\n";

if ($usersWithToken == 0) {
    echo "\n⚠️  WARNING: No users have FCM tokens set!\n";
    echo "Notifications cannot be sent without FCM tokens.\n";
}

echo "\n";
