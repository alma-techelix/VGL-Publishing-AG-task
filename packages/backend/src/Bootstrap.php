<?php

declare(strict_types=1);

namespace App;

use Dotenv\Dotenv;
use RuntimeException;

class Bootstrap
{
    private array $config;

    public function __construct(string $projectRoot)
    {
        // Load .env (non-fatal if missing, use defaults)
        if (is_file($projectRoot . '/.env')) {
            $dotenv = Dotenv::createImmutable($projectRoot);
            $dotenv->safeLoad();
        }

        $this->config = [
            'DB_DRIVER' => getenv('DB_DRIVER') ?: 'sqlite',
            'DB_PATH'   => getenv('DB_PATH') ?: $projectRoot . 'data/dev.db',
            'DB_HOST'   => getenv('DB_HOST') ?: '127.0.0.1',
            'DB_PORT'   => getenv('DB_PORT') ?: '3306',
            'DB_NAME'   => getenv('DB_NAME') ?: 'app',
            'DB_USER'   => getenv('DB_USER') ?: 'app',
            'DB_PASS'   => getenv('DB_PASS') ?: 'app',
            'HTTP_HOST' => getenv('HTTP_HOST') ?: '0.0.0.0',
            'HTTP_PORT' => getenv('HTTP_PORT') ?: '8080',
        ];
    }

    public function getConfig(): array
    {
        return $this->config;
    }

    // Doctrine-only bootstrap: PDO removed; config remains for Doctrine DBAL
}
