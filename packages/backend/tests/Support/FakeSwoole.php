<?php

// Minimal polyfills for Swoole classes used by Router in unit tests
// Only defined if the real classes are not available.

namespace Swoole\Http;

if (!class_exists(Request::class)) {
    class Request
    {
        /** @var array<string,mixed> */
        public array $server = [];
        public function __construct(array $server = [])
        {
            $this->server = $server;
        }
    }
}

if (!class_exists(Response::class)) {
    class Response
    {
        public int $statusCode = 200;
        /** @var array<string,string> */
        public array $headers = [];
        public string $body = '';

        public function status(int $code): void
        {
            $this->statusCode = $code;
        }
        public function header(string $name, string $value): void
        {
            $this->headers[$name] = $value;
        }
        public function end(string $content = ''): void
        {
            $this->body = $content;
        }
    }
}
