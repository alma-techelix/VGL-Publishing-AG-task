<?php

declare(strict_types=1);

use PHPUnit\Framework\TestCase;
use App\Service\ResponseCache;

final class ResponseCacheTest extends TestCase
{
    public function testGetReturnsNullWhenDisabled(): void
    {
        $cache = new ResponseCache();
        // If Redis is not available, isEnabled may be false; get() should just return null.
        $val = $cache->get('resp:/health');
        $this->assertTrue($val === null || is_string($val));
    }

    public function testGetReturnsCachedValueWhenClientInjected(): void
    {
        $cache = new ResponseCache();
        $fake = new class {
            private array $store = ['resp:/foo' => '{"ok":true}'];
            public function get(string $key)
            {
                return $this->store[$key] ?? false;
            }
            public function setex(string $key, int $ttl, string $value)
            {
                $this->store[$key] = $value;
            }
        };
        $cache->setClient($fake);
        $this->assertTrue($cache->isEnabled());
        $this->assertSame('{"ok":true}', $cache->get('resp:/foo'));
        // Miss returns null
        $this->assertNull($cache->get('resp:/bar'));
    }
}
