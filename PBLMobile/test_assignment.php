<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

use App\Models\Assignment;
use Carbon\Carbon;

try {
    $assignment = Assignment::create([
        'user_id' => 1,
        'title' => 'Test Assignment',
        'description' => 'Testing assignment creation',
        'deadline' => Carbon::now()->addDays(3)->endOfDay(),
        'color' => '#5B9FED',
        'has_reminder' => true,
        'reminder_minutes' => 30,
        'is_done' => false,
    ]);
    
    echo "✓ Assignment created successfully!\n";
    echo "ID: {$assignment->id}\n";
    echo "Title: {$assignment->title}\n";
    echo "Deadline: {$assignment->deadline}\n";
    
} catch (\Exception $e) {
    echo "✗ Error: " . $e->getMessage() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
}
