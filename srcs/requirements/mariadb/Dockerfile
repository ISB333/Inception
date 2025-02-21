FROM debian:buster

RUN apt update -y
RUN apt upgrade -y
RUN apt-get install mariadb-server -y

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY conf/script.sh /script.sh

ENTRYPOINT ["bash", "script.sh"]

# RUN service mysql start && mysql < ./script.sql
