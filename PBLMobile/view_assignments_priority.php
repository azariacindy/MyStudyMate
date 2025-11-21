<?php

$url = 'http://127.0.0.1:8000/api/assignments';

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Accept: application/json',
    'X-User-Id: 2'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "=== Assignment List with Priority ===\n\n";
echo "HTTP Status: $httpCode\n\n";

$data = json_decode($response, true);

if ($data['success'] ?? false) {
    $assignments = $data['data'];
    echo "Total Assignments: " . count($assignments) . "\n\n";
    
    foreach ($assignments as $assignment) {
        // Calculate priority on client side (like Flutter will do)
        $deadline = new DateTime($assignment['deadline']);
        $now = new DateTime();
        $daysUntil = $now->diff($deadline)->days * ($deadline > $now ? 1 : -1);
        
        $isDone = $assignment['is_done'];
        if ($isDone) {
            $priority = 'completed';
            $label = 'Done';
        } elseif ($deadline < $now) {
            $priority = 'critical';
            $label = 'Overdue';
        } elseif ($daysUntil <= 1) {
            $priority = 'high';
            $label = 'Urgent';
        } elseif ($daysUntil <= 3) {
            $priority = 'medium';
            $label = 'Soon';
        } else {
            $priority = 'low';
            $label = 'Upcoming';
        }
        
        $emoji = [
            'critical' => '🔴',
            'high' => '🟠',
            'medium' => '🔵',
            'low' => '🟢',
            'completed' => '✅',
        ][$priority];
        
        echo "{$emoji} [{$label}] {$assignment['title']}\n";
        echo "   ID: {$assignment['id']}\n";
        echo "   Deadline: " . $deadline->format('Y-m-d H:i') . "\n";
        echo "   Days until: {$daysUntil}\n";
        echo "   Done: " . ($isDone ? 'Yes' : 'No') . "\n";
        echo "\n";
    }
} else {
    echo "Error: " . ($data['message'] ?? 'Unknown error') . "\n";
}
