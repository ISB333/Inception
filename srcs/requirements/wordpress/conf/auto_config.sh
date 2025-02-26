#!/bin/bash

# Debugging: Print environment variables
echo "Domain: $DOMAIN_NAME"
echo "Database Host: $MYSQL_HOST"
echo "Database Name: $MYSQL_DATABASE"
echo "Database User: $MYSQL_USER"

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
for i in {1..10}; do
    if mariadb -h"$MYSQL_HOST" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1" >/dev/null 2>&1; then
        echo "MariaDB is ready!"
        break
    fi
    echo "MariaDB is not ready yet... waiting (attempt $i/30)"
    sleep 5
    
    # If we've tried 30 times and still not connected, create a manual config
    if [ $i -eq 10 ]; then
        echo "Could not connect to MariaDB after multiple attempts. Creating manual config."
    fi
done

# Check if wp-config.php already exists
if [ -f /var/www/wordpress/wp-config.php ] && [ -s /var/www/wordpress/wp-config.php ]; then
    echo "wp-config.php already exists, skipping configuration."
else
    echo "wp-config.php does not exist. Creating it manually..."
    
#     # Create wp-config.php manually rather than using WP-CLI
#     cat > /var/www/wordpress/wp-config.php << EOF
# <?php
# // ** MySQL settings - You can get this info from your web host ** //
# /** The name of the database for WordPress */
# define( 'DB_NAME', '$MYSQL_DATABASE' );

# /** MyMYSQL database username */
# define( 'DB_USER', '$MYSQL_USER' );

# /** MyMYSQL database password */
# define( 'DB_PASSWORD', '$MYSQL_PASSWORD' );

# /** MyMYSQL hostname */
# define( 'DB_HOST', '$MYSQL_HOST' );

# /** Database Charset to use in creating database tables. */
# define( 'DB_CHARSET', 'utf8' );

# /** The Database Collate type. Don't change this if in doubt. */
# define( 'DB_COLLATE', '' );

# /** Authentication Unique Keys and Salts. */
# define('AUTH_KEY',         '$(openssl rand -base64 64)');
# define('SECURE_AUTH_KEY',  '$(openssl rand -base64 64)');
# define('LOGGED_IN_KEY',    '$(openssl rand -base64 64)');
# define('NONCE_KEY',        '$(openssl rand -base64 64)');
# define('AUTH_SALT',        '$(openssl rand -base64 64)');
# define('SECURE_AUTH_SALT', '$(openssl rand -base64 64)');
# define('LOGGED_IN_SALT',   '$(openssl rand -base64 64)');
# define('NONCE_SALT',       '$(openssl rand -base64 64)');

# /** WordPress Database Table prefix. */
# \$table_prefix = 'wp_';

# /** For developers: WordPress debugging mode. */
# define( 'WP_DEBUG', false );

# /** Absolute path to the WordPress directory. */
# if ( ! defined( 'ABSPATH' ) ) {
# 	define( 'ABSPATH', __DIR__ . '/' );
# }

# /** Sets up WordPress vars and included files. */
# require_once ABSPATH . 'wp-settings.php';
# EOF

    # More verbose wp config create
    wp config create --allow-root \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=$MYSQL_HOST \
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
