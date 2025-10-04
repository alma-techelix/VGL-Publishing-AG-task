<?php

declare(strict_types=1);

namespace App\Entity;

use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity(repositoryClass: \App\Repository\AlbumRepository::class)]
#[ORM\Table(name: "albums")]
class Album
{
    #[ORM\Id]
    #[ORM\Column(name: "AlbumId", type: "integer")]
    #[ORM\GeneratedValue(strategy: "AUTO")]
    private int $id;

    #[ORM\Column(name: "Title", type: "string", length: 160, nullable: true)]
    private ?string $title = null;

    #[ORM\ManyToOne(targetEntity: Artist::class)]
    #[ORM\JoinColumn(name: "ArtistId", referencedColumnName: "ArtistId", nullable: true, onDelete: "SET NULL")]
    private ?Artist $artist = null;

    public function getId(): int
    {
        return $this->id;
    }

    public function getTitle(): ?string
    {
        return $this->title;
    }

    public function setTitle(?string $title): void
    {
        $this->title = $title;
    }

    public function getArtist(): ?Artist
    {
        return $this->artist;
    }

    public function setArtist(?Artist $artist): void
    {
        $this->artist = $artist;
    }
}
