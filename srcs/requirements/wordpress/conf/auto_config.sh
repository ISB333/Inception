#!/bin/bash

# Debugging: Print environment variables
echo "Domain: $DOMAIN_NAME"
echo "Database Host: $MYSQL_HOST"
echo "Database Name: $MYSQL_DATABASE"
echo "Database User: $MYSQL_USER"

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! mariadb -h$MYSQL_HOST -u$MYSQL_USER -p$MYSQL_ROOT_PASSWORD --silent 2>/dev/null; do
    echo "MariaDB is not ready yet... waiting 5 seconds"
    sleep 5
done
echo "MariaDB is ready!"

# Check if wp-config.php already exists
if [ -f /var/www/wordpress/wp-config.php ] && [ -s /var/www/wordpress/wp-config.php ]; then
    echo "wp-config.php already exists, skipping configuration."
else
    echo "wp-config.php does not exist. Creating it manually..."
    
    # More verbose wp config create
    wp config create --allow-root \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_ROOT_PASSWORD" \
        --dbhost="$MYSQL_HOST" \
        --path='/var/www/wordpress' \
        --debug

    echo "wp-config.php has been created."
    
    
    # We'll still use WP-CLI for this part
    echo "Installing WordPress core..."
    wp core install --allow-root \
        --url="$DOMAIN_NAME" \
        --title="$SITE_TITLE" \
        --admin_user="$ADMIN_USER" \
        --admin_password="$ADMIN_PASSWORD" \
        --admin_email="$ADMIN_MAIL" \
        --path='/var/www/wordpress'
    
    if [ $? -eq 0 ]; then
        echo "WordPress core installed successfully!"
        
        echo "Creating additional user..."
        wp user create --allow-root \
            --role=author "$USER1_LOGIN" "$USER1_MAIL" \
            --user_pass="$USER1_PASSWORD" \
            --path='/var/www/wordpress'
        
        if [ $? -eq 0 ]; then
            echo "Additional user created successfully!"
        else
            echo "Failed to create additional user."
        fi
    else
        echo "Failed to install WordPress core."
    fi
fi

# Verify that wp-config.php was created
if [ -f /var/www/wordpress/wp-config.php ]; then
    echo "✅ wp-config.php exists and is ready."
    ls -la /var/www/wordpress/wp-config.php
else
    echo "❌ ERROR: wp-config.php does not exist!"
fi

# Create PHP-FPM runtime directory
mkdir -p /run/php

# Start PHP-FPM
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.3 -F
