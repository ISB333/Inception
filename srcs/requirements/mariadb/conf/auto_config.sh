#!/bin/sh

mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld
chmod 777 /var/run/mysqld

echo "Checking if Database is initialized\n"

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Start MariaDB/MySQL daemon in background with networking disabled for security.
    # The skip-networking flag prevents external connections during initialization,
    # allowing only local socket-based access. Process ID is captured for later management.
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
    
    # Terminates the process with the specified PID and waits for it to complete.
    # This is important because:
    # 1. kill() sends a termination signal to gracefully shut down the process
    # 2. wait() ensures the process has fully exited before continuing
    # 3. Together, they prevent zombie processes and resource leaks
    kill "$pid"
    wait "$pid"
fi

exec mysqld --user=mysql --console
