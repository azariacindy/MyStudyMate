<?php

// Test assignment creation via API endpoint

$url = 'http://127.0.0.1:8000/api/assignments';

$data = [
    'title' => 'Test Assignment via API',
    'description' => 'Testing assignment creation through API endpoint',
    'deadline' => '2025-11-30',
    'color' => '#FF5733',
    'has_reminder' => true,
    'reminder_minutes' => 60,
];

$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json',
    'X-User-Id: 1'
]);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));

echo "Testing POST /api/assignments\n";
echo "URL: $url\n";
echo "Data: " . json_encode($data, JSON_PRETTY_PRINT) . "\n\n";

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "HTTP Status: $httpCode\n";
echo "Response:\n";
echo json_encode(json_decode($response), JSON_PRETTY_PRINT) . "\n";

if ($httpCode == 201) {
    echo "\n✅ Assignment created successfully!\n";
} else {
    echo "\n❌ Failed to create assignment\n";
}
