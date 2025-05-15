# File: Dockerfile

FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libpq-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# Copy composer files first for better Docker caching
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --optimize-autoloader --no-dev

# Copy application files
COPY . .

# Set correct permissions
RUN chown -R www-data:www-data /var/www && chmod -R 755 storage bootstrap/cache

# Expose port
EXPOSE 8000

# Entrypoint
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]