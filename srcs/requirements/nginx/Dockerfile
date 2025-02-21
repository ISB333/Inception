FROM debian:buster

RUN apt update -y
RUN apt upgrade -y
RUN apt install nginx -y
RUN apt install vim -y
RUN apt install curl -y
RUN apt install openssl -y

# To Stock certificate & key TSL
RUN mkdir -p /etc/nginx/ssl
# To Stock config files
RUN mkdir -p /var/run/nginx
# TSL Certificate
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=Haut-Rhin/L=Mulhouse/O=42/OU=42/CN=${DOMAIN_NAME}/UID=${LOGIN}"

# Replace NGINX conf file by our conf file
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Principal Root
RUN chmod 755 /var/www/html 
# Principal User
RUN chown -R www-data:www-data /var/www/html
# Run NGINX
CMD [ "nginx", "-g", "daemon off;" ]
