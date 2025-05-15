# Stage 1: Composer build
FROM composer:2 AS vendor

WORKDIR /app

# Copy only necessary files for dependency resolution
COPY composer.json composer.lock ./
COPY packages/ ./packages/

RUN composer install --no-dev --prefer-dist --optimize-autoloader

# Stage 2: Laravel runtime
FROM php:8.2-fpm

# Install system dependencies & PHP extensions
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libpq-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

# Set working directory
WORKDIR /var/www

# Copy app code
COPY . .

# Copy installed vendor directory from builder stage
COPY --from=vendor /app/vendor /var/www/vendor

# Permissions
RUN chown -R www-data:www-data /var/www \
    && chmod -R 755 storage bootstrap/cache

EXPOSE 8000

CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]