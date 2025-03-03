#!/bin/sh

# Create necessary directories
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld
chmod 777 /var/run/mysqld

echo "Checking if Database is initialized\n"

# Check if database is already initialized
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    # Initialize MySQL data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MySQL server without networking for initialization
    mysqld --user=mysql --skip-networking &
    pid="$!"
    
    # Wait for MySQL to become available
    until mysqladmin ping >/dev/null 2>&1; do
        echo "Waiting for database server to accept connections..."
        sleep 2
    done
    
    # Create users and databases
    mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'wp-php.srcs_inception_net' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'wp-php.srcs_inception_net';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO 'root'@'wp-php.srcs_inception_net';
FLUSH PRIVILEGES;
EOF
    
    # Stop the temporary MySQL server
    kill "$pid"
    wait "$pid"
fi

# Keep MySQL running
exec mysqld --user=mysql --console
