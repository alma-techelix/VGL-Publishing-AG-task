#!/usr/bin/env php
<?php
declare(strict_types=1);

require __DIR__ . '/../vendor/autoload.php';

use App\Bootstrap;
use App\Router;
use App\Doctrine\EntityManagerFactory;
use App\Service\ResponseCache;
use Swoole\Http\Server as HttpServer;
use Swoole\Http\Request as HttpRequest;
use Swoole\Http\Response as HttpResponse;

// Load env and bootstrap
$bootstrap = new Bootstrap(__DIR__ . '/../');
$config = $bootstrap->getConfig();
$entityManager = EntityManagerFactory::create($config);

$host = $config['HTTP_HOST'] ?? '0.0.0.0';
$port = (int)($config['HTTP_PORT'] ?? 8080);

$server = new HttpServer($host, $port);
$router = new Router($entityManager);
$cache  = new ResponseCache();

$server->on('request', function (HttpRequest $request, HttpResponse $response) use ($router, $cache) {
    try {
        // Attempt read-through cache only for GET by path
        $method = strtoupper($request->server['request_method'] ?? 'GET');
        $uri = $request->server['request_uri'] ?? '/';
        if ($method === 'GET') {
            $cacheKey = 'resp:' . $uri;
            $cached = $cache->get($cacheKey);
            if ($cached !== null) {
                echo sprintf("[ACCESS] %s %s (cache)\n", $method, $uri);
                $response->status(200);
                $response->header('Content-Type', 'application/json');
                $response->end($cached);
                return;
            }
        }

        echo sprintf("[ACCESS] %s %s\n", $method, $uri);
        $router->handle($request, $response);
    } catch (Throwable $e) {
        echo sprintf("[ERROR] %s: %s\n%s\n", $e::class, $e->getMessage(), $e->getTraceAsString());
        $response->status(500);
        $response->header('Content-Type', 'application/json');
        $response->end(json_encode([
            'error' => 'internal_error',
            'message' => $e->getMessage(),
            'trace' => $e->getTraceAsString(),
        ]));
    }
});

echo sprintf("Swoole HTTP server listening on http://%s:%d\n", $host, $port);
$server->start();
