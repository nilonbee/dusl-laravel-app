# Stage 1: Build dependencies
FROM composer:2 AS vendor

WORKDIR /app

# Copy only what's needed to install dependencies
COPY composer.json composer.lock ./
COPY packages/ ./packages/

RUN composer install --no-dev --prefer-dist --optimize-autoloader

# Stage 2: Build application
FROM php:8.2-fpm

# Install system packages
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libpq-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www

# Copy only Laravel source code and configs
COPY . .

# Copy installed vendor deps from build stage
COPY --from=vendor /app/vendor /var/www/vendor

# Set correct permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 storage bootstrap/cache

# Expose Laravel dev port
EXPOSE 8000

# Run Laravel dev server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]