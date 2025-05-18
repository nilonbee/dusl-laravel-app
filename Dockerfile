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
    && docker-php-ext-install pdo pdo_mysql mbstring zip opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set working directory
WORKDIR /var/www

# Copy app code FIRST
COPY . .

# Copy installed vendor directory from builder stage AFTER app code
COPY --from=vendor /app/vendor /var/www/vendor

# Permissions - ensure storage and bootstrap/cache are writable by www-data
RUN chown -R www-data:www-data /var/www \
    && chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Expose port 9000 for FPM (Render will likely use this internally)
EXPOSE 9000

# Command to run PHP-FPM (standard for production PHP containers)
# Render's web service will then communicate with FPM
CMD ["php-fpm"]