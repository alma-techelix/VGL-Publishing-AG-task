<?php

declare(strict_types=1);

namespace App\Doctrine;

use Doctrine\ORM\EntityManager;
use Doctrine\ORM\ORMSetup;
use Doctrine\DBAL\DriverManager;

final class EntityManagerFactory
{
    public static function create(array $config): EntityManager
    {
        $paths = [__DIR__ . '/../Entity'];
        $isDevMode = true;

        $ormConfig = ORMSetup::createAttributeMetadataConfiguration($paths, $isDevMode);

        $connectionParams = [];
        $driver = strtolower((string)($config['DB_DRIVER'] ?? 'sqlite'));
        if ($driver === 'sqlite') {
            $connectionParams = [
                'driver' => 'pdo_sqlite',
                'path'   => $config['DB_PATH'] ?? (__DIR__ . '/../../data/dev.db'),
            ];
        } elseif ($driver === 'mysql') {
            $connectionParams = [
                'driver' => 'pdo_mysql',
                'host'   => $config['DB_HOST'] ?? '127.0.0.1',
                'port'   => (int)($config['DB_PORT'] ?? 3306),
                'dbname' => $config['DB_NAME'] ?? 'app',
                'user'   => $config['DB_USER'] ?? 'app',
                'password' => $config['DB_PASS'] ?? 'app',
                'charset'  => 'utf8mb4',
            ];
        } else {
            throw new \RuntimeException('Unsupported DB_DRIVER for Doctrine: ' . $driver);
        }

        $conn = DriverManager::getConnection($connectionParams, $ormConfig);
        return new EntityManager($conn, $ormConfig);
    }
}
