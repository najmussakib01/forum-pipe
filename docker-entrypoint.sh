#!/bin/sh

# Exit immediately if any command fails
set -e

# Wait for MySQL to be ready
echo "Waiting for database connection..."
until nc -z -v -w30 db 3306; do
  echo "Waiting for database..."
  sleep 5
done
echo "Database is up!"

# Ensure .env file exists, copy from .env.example if not present
if [ ! -f ".env" ]; then
    echo "Creating .env file from .env.example..."
    cp .env.example .env
fi

# Generate application key if not already set
if ! grep -q "APP_KEY=base64" .env; then
    echo "Generating application key..."
    php artisan key:generate
fi

# Run database migrations
echo "Running migrations..."
php artisan migrate --force

# Set correct permissions for storage and cache
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Execute the container's main process (PHP-FPM)
exec "$@"

