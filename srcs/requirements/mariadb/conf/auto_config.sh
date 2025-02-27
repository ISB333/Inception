#!/bin/sh

# Create necessary directories
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld
chmod 777 /var/run/mysqld

echo "Checking if Database is initialized\n"
# WE ENTER WELL IN THE CONDITION BELOW, IF WE REMOVE VOLUMES AND IMAGES, WE CAN SEE IT

# Check if database is already initialized
if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    # Initialize MySQL data directory
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

	echo "Initializing mariadb database\n"
    # Create a temporary file with SQL commands
    cat > /tmp/init.sql << EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
ALTER USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
FLUSH PRIVILEGES;
EOF

    # Start MySQL server in the background, run initialization, then stop it
    mysqld --user=mysql --bootstrap < /tmp/init.sql
    rm /tmp/init.sql
fi

# Keep MySQL running
exec mysqld_safe
