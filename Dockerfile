# Dockerfile
FROM php:8.2-fpm

# System packages
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libpq-dev \
    && docker-php-ext-install pdo pdo_mysql mbstring zip

# Composer install
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working dir
WORKDIR /var/www

# Copy app files
COPY . .

# Install dependencies
RUN composer install --optimize-autoloader --no-dev

# Set permissions
RUN chown -R www-data:www-data /var/www && chmod -R 755 storage

# Generate app key
RUN php artisan config:clear

# Expose port
EXPOSE 8000

CMD php artisan serve --host=0.0.0.0 --port=8000
