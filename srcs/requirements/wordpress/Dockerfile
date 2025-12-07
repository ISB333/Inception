FROM debian:bookworm

RUN apt update -y 
RUN apt upgrade -y
RUN apt install -y php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client \
    wget \
    sudo \
	tini

# Download and extract WordPress
RUN wget https://wordpress.org/wordpress-6.0.tar.gz -P /var/www
RUN cd /var/www && tar -xzf wordpress-6.0.tar.gz && rm wordpress-6.0.tar.gz
COPY ./conf/php.conf /etc/php/8.2/fpm/pool.d/www.conf

# Set proper permissions
RUN chown -R www-data:www-data /var/www/wordpress
RUN chmod -R 755 /var/www/wordpress

# Install WP-CLI the correct way
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp
RUN wp --info

COPY conf/auto_config.sh /auto_config.sh
RUN chmod +x /auto_config.sh

EXPOSE 9000

ENTRYPOINT ["/usr/bin/tini", "--", "/auto_config.sh"]
