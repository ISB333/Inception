#!/bin/bash

# Debugging: Print environment variables
echo "Domain: $DOMAIN_NAME"
echo "Database Host: $MYSQL_HOST"
echo "Database Name: $MYSQL_DATABASE"
echo "Database User: $MYSQL_USER"

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! mysql -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" -e "SELECT 1" >/dev/null 2>&1; do
    echo "MariaDB is not ready yet... waiting 5 seconds"
    sleep 5
done
echo "MariaDB is ready!"

# Check if wp-config.php already exists
if [ -f /var/www/wordpress/wp-config.php ] && [ -s /var/www/wordpress/wp-config.php ]; then
    echo "wp-config.php already exists, skipping configuration."
else
    echo "wp-config.php does not exist. Creating it manually..."
    
	  cat > /var/www/wordpress/wp-config.php << EOF
<?php
define('DB_NAME', '$MYSQL_DATABASE');
define('DB_USER', '$MYSQL_USER');
define('DB_PASSWORD', '$MYSQL_PASSWORD');
define('DB_HOST', '$MYSQL_HOST');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');

define('AUTH_KEY',         '$(openssl rand -base64 48)');
define('SECURE_AUTH_KEY',  '$(openssl rand -base64 48)');
define('LOGGED_IN_KEY',    '$(openssl rand -base64 48)');
define('NONCE_KEY',        '$(openssl rand -base64 48)');
define('AUTH_SALT',        '$(openssl rand -base64 48)');
define('SECURE_AUTH_SALT', '$(openssl rand -base64 48)');
define('LOGGED_IN_SALT',   '$(openssl rand -base64 48)');
define('NONCE_SALT',       '$(openssl rand -base64 48)');

define('WP_HOME', 'https://adesille.42.fr:8443');
define('WP_SITEURL', 'https://adesille.42.fr:8443');

\$table_prefix = 'wp_';

define('WP_DEBUG', false);

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
EOF

    echo "wp-config.php has been created."
    
    # Install WordPress
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

mkdir -p /run/php

# Start PHP-FPM
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm8.2 -F
