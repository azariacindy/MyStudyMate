<?php

use Illuminate\Support\Facades\DB;

require __DIR__.'/vendor/autoload.php';

$app = require_once __DIR__.'/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

try {
    $columns = DB::select("SELECT column_name, data_type, is_nullable, column_default 
                           FROM information_schema.columns 
                           WHERE table_name = 'assignments' 
                           ORDER BY ordinal_position");
    
    echo "Assignments Table Structure:\n";
    echo "============================\n\n";
    
    foreach ($columns as $column) {
        echo "Column: {$column->column_name}\n";
        echo "  Type: {$column->data_type}\n";
        echo "  Nullable: {$column->is_nullable}\n";
        echo "  Default: {$column->column_default}\n\n";
    }
    
} catch (\Exception $e) {
    echo "Error: " . $e->getMessage() . "\n";
    echo "File: " . $e->getFile() . "\n";
    echo "Line: " . $e->getLine() . "\n\n";
    echo "Trace:\n" . $e->getTraceAsString() . "\n";
}
