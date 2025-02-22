FROM debian:buster

RUN apt update -y
RUN apt upgrade -y
RUN apt install -y mariadb-server \
					procps \
					netcat

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY conf/auto_config.sh /auto_config.sh

EXPOSE 3306

ENTRYPOINT ["bash", "auto_config.sh"]
