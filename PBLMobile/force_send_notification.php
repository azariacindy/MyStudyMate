<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\Assignment;
use App\Services\FCMService;

echo "=== Force Send Test Notification ===\n\n";

$fcmService = new FCMService();

// Get assignments that need H-3, D-Day, or H+3 notifications
$now = \Carbon\Carbon::now('Asia/Jakarta');
$today = $now->copy()->startOfDay();

$h3Date = $today->copy()->addDays(3);
$h3AfterDate = $today->copy()->subDays(3);

// Find assignment with user that has FCM token
$assignments = Assignment::with('user')
    ->where('is_done', false)
    ->where('has_reminder', true)
    ->whereHas('user', function($q) {
        $q->whereNotNull('fcm_token');
    })
    ->get();

echo "Found " . $assignments->count() . " assignments with users having FCM tokens\n\n";

if ($assignments->isEmpty()) {
    echo "❌ No assignments found with users having FCM tokens.\n";
    echo "Please set FCM token for at least one user.\n";
    exit(1);
}

// Send test notification to each
$sent = 0;
foreach ($assignments as $assignment) {
    $daysUntil = $now->diffInDays($assignment->deadline, false);
    
    if ($daysUntil == 3) {
        $type = 'h_minus_3';
        $title = '⏰ Assignment Due in 3 Days!';
        $body = "Don't forget: \"{$assignment->title}\" is due in 3 days. Start working on it!";
    } elseif ($assignment->deadline->isToday()) {
        $type = 'd_day';
        $title = '🔥 Assignment Due Today!';
        $body = "Urgent: \"{$assignment->title}\" is due today! Complete it before the deadline.";
    } elseif ($daysUntil < 0) {
        $type = 'h_plus_3';
        $title = '❗ Assignment Overdue!';
        $body = "Assignment \"{$assignment->title}\" is overdue. Please complete it as soon as possible!";
    } else {
        echo "⏭️  Skipping assignment {$assignment->id} (not in notification window)\n";
        continue;
    }
    
    echo "📤 Sending {$type} notification for: {$assignment->title}\n";
    echo "   User: {$assignment->user->name} (ID: {$assignment->user_id})\n";
    echo "   FCM Token: " . substr($assignment->user->fcm_token, 0, 30) . "...\n";
    echo "   Title: {$title}\n";
    echo "   Body: {$body}\n";
    
    try {
        $result = $fcmService->sendNotification(
            $assignment->user->fcm_token,
            $title,
            $body,
            [
                'type' => 'assignment_reminder',
                'assignment_id' => (string) $assignment->id,
                'notification_type' => $type,
                'deadline' => $assignment->deadline->toIso8601String(),
            ]
        );
        
        if ($result) {
            echo "   ✅ Notification sent successfully!\n";
            
            // Update last notification type
            $assignment->last_notification_type = $type;
            $assignment->save();
            echo "   ✅ Updated last_notification_type to: {$type}\n";
            
            $sent++;
        } else {
            echo "   ❌ Failed to send notification\n";
        }
    } catch (\Exception $e) {
        echo "   ❌ Error: " . $e->getMessage() . "\n";
    }
    
    echo "\n";
}

echo "=== Summary ===\n";
echo "Total notifications sent: {$sent}\n";
echo "Check storage/logs/laravel.log for detailed FCM logs\n";
