.PHONY: down run broadcast_tvshow

down:
	docker-compose down -v

run: down
	docker-compose run --rm --service-ports edge

lint:
	docker-compose run --rm lint

broadcast_tvshow:
	docker-compose run --rm origin

