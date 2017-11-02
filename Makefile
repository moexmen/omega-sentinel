up: build
	docker-compose up -d --remove-orphans

build:
	docker-compose build

down:
	docker-compose down

clean:
	docker-compose down --volumes --remove-orphans
