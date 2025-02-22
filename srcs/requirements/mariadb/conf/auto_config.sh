#!/bin/sh

# Create necessary directories
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld
chmod 777 /var/run/mysqld

# Start MySQL service properly
service mysql start

# Wait for MySQL to be ready
while ! mysqladmin ping -h"localhost" --silent; do
    sleep 2
done

# Create database and users
mysql -e "CREATE DATABASE IF NOT EXISTS ${SQL_DATABASE};"
mysql -e "CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON ${SQL_DATABASE}.* TO '${SQL_USER}'@'%';"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
mysql -e "FLUSH PRIVILEGES;"

mysqladmin -u root -p$SQL_ROOT_PASSWORD shutdown

# Keep MySQL running
exec mysqld_safe
