<?php

declare(strict_types=1);

namespace App;

use Swoole\Http\Request;
use Swoole\Http\Response;
use Doctrine\ORM\EntityManagerInterface;
use App\Entity\Artist;
use App\Entity\Album;
use App\Entity\Genre;

class Router
{
    public function __construct(private EntityManagerInterface $em)
    {
    }

    public function handle(Request $req, Response $res): void
    {
        $method = strtoupper($req->server['request_method'] ?? 'GET');
        $uri    = $req->server['request_uri'] ?? '/';

        // Health
        if ($uri === '/health') {
            $this->json($res, 200, ['status' => 'ok']);
            return;
        }

        // Doctrine-only endpoints
        if ($uri === '/artists' && $method === 'GET') {
            $this->listArtists($res);
            return;
        }
        if (preg_match('#^/artists/(\\d+)$#', $uri, $m) && $method === 'GET') {
            $this->getArtist($res, (int)$m[1]);
            return;
        }

        if ($uri === '/albums' && $method === 'GET') {
            $this->listAlbums($res);
            return;
        }
        if (preg_match('#^/albums/(\\d+)$#', $uri, $m) && $method === 'GET') {
            $this->getAlbum($res, (int)$m[1]);
            return;
        }

        if ($uri === '/genres' && $method === 'GET') {
            $this->listGenres($res);
            return;
        }
        if (preg_match('#^/genres/(\\d+)$#', $uri, $m) && $method === 'GET') {
            $this->getGenre($res, (int)$m[1]);
            return;
        }

        $this->json($res, 404, ['error' => 'not_found']);
    }

    private function listArtists(Response $res): void
    {
        $repo = $this->em->getRepository(Artist::class);
        $artists = $repo->findBy([], ['id' => 'ASC'], 100);
        $data = array_map(fn(Artist $a) => ['ArtistId' => $a->getId(), 'Name' => $a->getName()], $artists);
        $this->json($res, 200, ['data' => $data]);
    }

    private function getArtist(Response $res, int $id): void
    {
        $artist = $this->em->find(Artist::class, $id);
        if (!$artist) {
            $this->json($res, 404, ['error' => 'not_found']);
            return;
        }
        $this->json($res, 200, ['data' => ['ArtistId' => $artist->getId(), 'Name' => $artist->getName()]]);
    }

    private function listAlbums(Response $res): void
    {
        $repo = $this->em->getRepository(Album::class);
        // Use custom repository methods to always eager-load Artist
        if (method_exists($repo, 'findAllWithArtist')) {
            /** @var Album[] $albums */
            $albums = $repo->findAllWithArtist(100);
        } else {
            $albums = $repo->findBy([], ['id' => 'ASC'], 100);
        }
        $data = array_map(function (Album $al) {
            $artist = $al->getArtist();
            return [
                'AlbumId' => $al->getId(),
                'Title'   => $al->getTitle(),
                'ArtistId' => $artist?->getId(),
                'Artist' => $artist ? [
                    'ArtistId' => $artist->getId(),
                    'Name' => $artist->getName(),
                ] : null,
            ];
        }, $albums);
        $this->json($res, 200, ['data' => $data]);
    }

    private function getAlbum(Response $res, int $id): void
    {
        $repo = $this->em->getRepository(Album::class);
        if (method_exists($repo, 'findOneWithArtist')) {
            $album = $repo->findOneWithArtist($id);
        } else {
            $album = $this->em->find(Album::class, $id);
        }
        if (!$album) {
            $this->json($res, 404, ['error' => 'not_found']);
            return;
        }
        $artist = $album->getArtist();
        $this->json($res, 200, ['data' => [
            'AlbumId' => $album->getId(),
            'Title'   => $album->getTitle(),
            'ArtistId' => $artist?->getId(),
            'Artist' => $artist ? [
                'ArtistId' => $artist->getId(),
                'Name' => $artist->getName(),
            ] : null,
        ]]);
    }

    private function listGenres(Response $res): void
    {
        $repo = $this->em->getRepository(Genre::class);
        $genres = $repo->findBy([], ['id' => 'ASC'], 100);
        $data = array_map(fn(Genre $g) => ['GenreId' => $g->getId(), 'Name' => $g->getName()], $genres);
        $this->json($res, 200, ['data' => $data]);
    }

    private function getGenre(Response $res, int $id): void
    {
        $genre = $this->em->find(Genre::class, $id);
        if (!$genre) {
            $this->json($res, 404, ['error' => 'not_found']);
            return;
        }
        $this->json($res, 200, ['data' => ['GenreId' => $genre->getId(), 'Name' => $genre->getName()]]);
    }

    private function json(Response $res, int $status, array $payload): void
    {
        $res->status($status);
        $res->header('Content-Type', 'application/json');
        $res->end(json_encode($payload));
    }
}
