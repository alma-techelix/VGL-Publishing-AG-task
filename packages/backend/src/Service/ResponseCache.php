<?php

declare(strict_types=1);

namespace App\Service;

/**
 * Naive response cache backed by Redis (if available).
 */
class ResponseCache
{
    private bool $enabled = false;
    /** @var \Redis|null */
    private $redis = null;

    public function __construct()
    {
        // Redis Response Cache, only needs to work in Production
        try {
            // TODO: currently only works on prod, move to config / env vars
            $r = new \Redis();
            $r->connect('192.168.1.100', 6379, 0.05);
            try {
                $r->auth('devpass');
            } catch (\Throwable $__) {
            }
            $this->redis = $r;
            $this->enabled = true;
        } catch (\Throwable $__) {
            $this->enabled = false;
            $this->redis = null;
        }
    }

    public function isEnabled(): bool
    {
        return $this->enabled && $this->redis !== null;
    }

    /**
     * Testing hook: inject a Redis-like client (must implement get() and setex()).
     * Enables the cache when a client is provided.
     */
    public function setClient(object $client): void
    {
        $this->redis = $client;
        $this->enabled = true;
    }

    /**
     * Get a raw cached payload, or null on miss/error/disabled.
     */
    public function get(string $key): ?string
    {
        if (!$this->isEnabled()) {
            return null;
        }
        try {
            $val = $this->redis->get($key);
            if ($val === false) {
                return null;
            }
            return is_string($val) ? $val : null;
        } catch (\Throwable $__) {
            return null;
        }
    }

    /**
     * Optional setter (not used by server). Ignored on failure.
     */
    public function set(string $key, string $value, int $ttlSeconds = 60): void
    {
        if (!$this->isEnabled()) {
            return;
        }
        try {
            $this->redis->setex($key, $ttlSeconds, $value);
        } catch (\Throwable $__) {
            // ignore
        }
    }
}
