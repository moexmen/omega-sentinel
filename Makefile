up:
	docker-compose up -d --remove-orphans

down:
	docker-compose down

clean:
	docker-compose down --volumes --remove-orphans

update:
	docker-compose pull
	sleep 2
	docker-compose up -d --force-recreate
	docker image prune

rebuild:
	docker-compose up -d --remove-orphans --build
