<?php

use Illuminate\Support\Facades\DB;

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

try {
    echo "Adding missing columns to assignments table...\n\n";
    
    // Add columns one by one
    DB::statement("ALTER TABLE assignments ADD COLUMN color VARCHAR(255) NOT NULL DEFAULT '#5B9FED'");
    echo "✓ Added color column\n";
    
    DB::statement("ALTER TABLE assignments ADD COLUMN has_reminder BOOLEAN NOT NULL DEFAULT true");
    echo "✓ Added has_reminder column\n";
    
    DB::statement("ALTER TABLE assignments ADD COLUMN reminder_minutes INTEGER NOT NULL DEFAULT 30");
    echo "✓ Added reminder_minutes column\n";
    
    DB::statement("ALTER TABLE assignments ADD COLUMN last_notification_type VARCHAR(255) NULL");
    echo "✓ Added last_notification_type column\n";
    
    echo "\n✅ All columns added successfully!\n";
    
} catch (\Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    echo "Code: " . $e->getCode() . "\n";
}
