all: build up

build:
	mkdir -p /home/adesille/data/mariadb
	mkdir -p /home/adesille/data/wordpress
	chmod 777 /home/adesille/data/mariadb
	chmod 777 /home/adesille/data/wordpress
	docker-compose -f srcs/docker-compose.yml build

up:
	docker-compose -f srcs/docker-compose.yml up -d

down:
	docker-compose -f srcs/docker-compose.yml down

clean:
	docker system prune -af

re: down clean build up

.PHONY: all build up down clean re