<?php
echo "Starting server test...\n";
echo "PHP version: " . phpversion() . "\n";
echo "Swoole extension loaded: " . (extension_loaded('swoole') ? 'YES' : 'NO') . "\n";

// Test basic Swoole server
use Swoole\Http\Server as HttpServer;

$server = new HttpServer('0.0.0.0', 8080);

$server->on('request', function ($request, $response) {
    $response->header('Content-Type', 'text/plain');
    $response->end("Hello from test server!\n");
});

echo "Test server starting on http://0.0.0.0:8080\n";
$server->start();
