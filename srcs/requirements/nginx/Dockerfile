FROM debian:bookworm

RUN apt update -y
RUN apt upgrade -y
RUN apt install nginx -y
RUN apt install openssl -y

RUN mkdir -p /etc/nginx/ssl

# TSL Certificate
RUN openssl req -newkey rsa:4096 -days 42 -nodes -x509 \
-subj "/C=FR/ST=Haut-Rhin/L=Mulhouse/O=42/OU=42/CN=adesille.42.fr/UID=adesille" \
-out /etc/ssl/certs/inception.crt \
-keyout /etc/ssl/private/inception.key

COPY conf/nginx.conf /etc/nginx/nginx.conf

# Give rights to the user to edit html folder
RUN mkdir -p /var/www/wordpress
RUN chmod 755 /var/www/wordpress
RUN chown -R www-data:www-data /var/www/wordpress

EXPOSE 443

CMD [ "nginx", "-g", "daemon off;" ]
