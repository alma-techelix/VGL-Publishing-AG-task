<?php

declare(strict_types=1);

use PHPUnit\Framework\TestCase;
use App\Router;
use App\Entity\Artist;
use App\Entity\Album;

require_once __DIR__ . '/Support/FakeSwoole.php';
require_once __DIR__ . '/Support/DoctrineTestUtil.php';

final class RouterTest extends TestCase
{
    private function makeRouterWithFixtures(): array
    {
        $em = Tests\Support\DoctrineTestUtil::createEntityManager();

        // Seed minimal data
        $artist = new Artist();
        // Assuming Artist has setName
        $refA = new ReflectionClass($artist);
        if ($refA->hasMethod('setName')) {
            $artist->setName('AC/DC');
        } else {
            // fallback via reflection to set private property if necessary
            $prop = $refA->getProperty('name');
            $prop->setAccessible(true);
            $prop->setValue($artist, 'AC/DC');
        }
        $em->persist($artist);

        $album = new Album();
        // Set title and artist
        $refAl = new ReflectionClass($album);
        if ($refAl->hasMethod('setTitle')) {
            $album->setTitle('For Those About To Rock We Salute You');
        } else {
            $propT = $refAl->getProperty('title');
            $propT->setAccessible(true);
            $propT->setValue($album, 'For Those About To Rock We Salute You');
        }
        if ($refAl->hasMethod('setArtist')) {
            $album->setArtist($artist);
        } else {
            $propAr = $refAl->getProperty('artist');
            $propAr->setAccessible(true);
            $propAr->setValue($album, $artist);
        }
        $em->persist($album);
        $em->flush();
        $em->clear();

        return [$em, $artist, $album, new Router($em)];
    }

    public function testHealthRouteReturnsOk(): void
    {
        [$em, , , $router] = $this->makeRouterWithFixtures();
        $req = new Swoole\Http\Request(['request_method' => 'GET', 'request_uri' => '/health']);
        $res = new Swoole\Http\Response();
        $router->handle($req, $res);
        $this->assertSame(200, $res->statusCode);
        $data = json_decode($res->body, true);
        $this->assertEquals(['status' => 'ok'], $data);
    }

    public function testArtistsListReturnsData(): void
    {
        [$em, , , $router] = $this->makeRouterWithFixtures();
        $req = new Swoole\Http\Request(['request_method' => 'GET', 'request_uri' => '/artists']);
        $res = new Swoole\Http\Response();
        $router->handle($req, $res);
        $this->assertSame(200, $res->statusCode);
        $json = json_decode($res->body, true);
        $this->assertIsArray($json['data'] ?? null);
        $this->assertArrayHasKey('ArtistId', $json['data'][0]);
        $this->assertArrayHasKey('Name', $json['data'][0]);
    }

    public function testAlbumGetReturnsNestedArtist(): void
    {
        [$em, , $album, $router] = $this->makeRouterWithFixtures();
        $req = new Swoole\Http\Request(['request_method' => 'GET', 'request_uri' => '/albums/' . $album->getId()]);
        $res = new Swoole\Http\Response();
        $router->handle($req, $res);
        $this->assertSame(200, $res->statusCode);
        $json = json_decode($res->body, true);
        $this->assertIsArray($json['data'] ?? null);
        $this->assertArrayHasKey('AlbumId', $json['data']);
        $this->assertArrayHasKey('Artist', $json['data']);
        $this->assertIsArray($json['data']['Artist']);
        $this->assertArrayHasKey('ArtistId', $json['data']['Artist']);
        $this->assertArrayHasKey('Name', $json['data']['Artist']);
    }

    public function testNotFoundReturns404(): void
    {
        [$em, , , $router] = $this->makeRouterWithFixtures();
        $req = new Swoole\Http\Request(['request_method' => 'GET', 'request_uri' => '/nope']);
        $res = new Swoole\Http\Response();
        $router->handle($req, $res);
        $this->assertSame(404, $res->statusCode);
        $json = json_decode($res->body, true);
        $this->assertEquals('not_found', $json['error'] ?? null);
    }
}
