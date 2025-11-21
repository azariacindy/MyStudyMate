<?php

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

try {
    // Get the latest batch number
    $latestBatch = DB::table('migrations')->max('batch') ?? 0;
    $newBatch = $latestBatch + 1;
    
    // Insert the migration record
    DB::table('migrations')->insert([
        'migration' => '2025_11_22_002420_add_missing_columns_to_assignments_table',
        'batch' => $newBatch
    ]);
    
    echo "✅ Migration record added successfully (batch: {$newBatch})\n";
    
} catch (\Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}
