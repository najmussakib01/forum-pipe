# Use PHP 7.4 with FPM
FROM php:7.4-fpm

# Set working directory
WORKDIR /var/www

# Install required dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    curl \
    libonig-dev \
    netcat-openbsd \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd mbstring pdo pdo_mysql opcache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy application files
COPY . /var/www

# Set correct permissions
RUN chown -R www-data:www-data /var/www

# Set Laravel permissions for storage and cache
RUN chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Copy and set up the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Install PHP dependencies and optimize autoloader
RUN composer install --no-dev --optimize-autoloader

# Expose PHP-FPM port
EXPOSE 9000

# Use custom entrypoint script
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Start PHP-FPM as the main process
CMD ["php-fpm"]

