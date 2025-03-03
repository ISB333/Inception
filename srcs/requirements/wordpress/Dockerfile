FROM debian:buster

RUN apt update -y 
RUN apt upgrade -y
RUN apt install -y php7.3 \
    php-fpm \
    php-mysql \
    mariadb-client \
    wget \
    sudo \
	tini

# Download and extract WordPress
RUN wget https://wordpress.org/wordpress-6.0.tar.gz -P /var/www
RUN cd /var/www && tar -xzf wordpress-6.0.tar.gz && rm wordpress-6.0.tar.gz
COPY ./conf/php.conf /etc/php/7.3/fpm/pool.d/www.conf

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
