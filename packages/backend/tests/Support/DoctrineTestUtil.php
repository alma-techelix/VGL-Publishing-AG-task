<?php

declare(strict_types=1);

namespace Tests\Support;

use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\Tools\Setup;
use Doctrine\ORM\EntityManager;
use Doctrine\ORM\Tools\SchemaTool;

final class DoctrineTestUtil
{
    public static function createEntityManager(): EntityManagerInterface
    {
        $config = Setup::createAttributeMetadataConfiguration(
            [__DIR__ . '/../../src/Entity'],
            true,
            null,
            null,
            false
        );
        $connection = [
            'driver' => 'pdo_sqlite',
            'memory' => true,
        ];
        $em = EntityManager::create($connection, $config);

        // Create schema for all entities
        $metadata = $em->getMetadataFactory()->getAllMetadata();
        if (!empty($metadata)) {
            $tool = new SchemaTool($em);
            $tool->createSchema($metadata);
        }
        return $em;
    }
}
