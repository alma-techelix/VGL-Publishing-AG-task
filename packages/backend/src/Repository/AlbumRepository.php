<?php

declare(strict_types=1);

namespace App\Repository;

use App\Entity\Album;
use Doctrine\ORM\EntityRepository;

/**
 * Custom repository for Album to always eager-load Artist via fetch join.
 */
class AlbumRepository extends EntityRepository
{
    /**
     * @return Album[]
     */
    public function findAllWithArtist(int $limit = 100): array
    {
        $qb = $this->createQueryBuilder('a')
            ->leftJoin('a.artist', 'ar')
            ->addSelect('ar')
            ->orderBy('a.id', 'ASC')
            ->setMaxResults($limit);

        return $qb->getQuery()->getResult();
    }

    public function findOneWithArtist(int $id): ?Album
    {
        $qb = $this->createQueryBuilder('a')
            ->leftJoin('a.artist', 'ar')
            ->addSelect('ar')
            ->andWhere('a.id = :id')
            ->setParameter('id', $id)
            ->setMaxResults(1);

        return $qb->getQuery()->getOneOrNullResult();
    }
}
