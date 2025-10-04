# Multi-stage build for PHP backend with Swoole
FROM php:8.3-cli-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    $PHPIZE_DEPS \
    linux-headers \
    autoconf \
    gcc \
    g++ \
    make \
    sqlite-dev \
    mysql-client \
    git \
    unzip \
    brotli-dev

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite pdo_mysql

# Install Swoole extension
RUN pecl install --configureoptions 'enable-brotli="no"' swoole && docker-php-ext-enable swoole

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /app

# Copy composer files first for better caching
COPY composer.json composer.lock ./

# Install dependencies (development stage)
FROM base AS development
RUN composer install --no-scripts --no-autoloader
COPY . .
RUN composer dump-autoload --optimize

# Production stage
FROM base AS production
RUN composer install --no-dev --no-scripts --no-autoloader --optimize-autoloader
COPY . .
RUN composer dump-autoload --optimize --classmap-authoritative

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Set proper permissions
RUN chown -R appuser:appgroup /app && \
    chmod +x bin/server.php

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD php -r "file_get_contents('http://127.0.0.1:8080/health') or exit(1);"

# Default command
CMD ["php", "bin/server.php"]
