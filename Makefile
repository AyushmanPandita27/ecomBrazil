.PHONY: up down logs ps reset venv check

up:        ## Build images and start the whole stack in the background
	docker compose up -d --build

down:      ## Stop everything (data is kept in Docker volumes)
	docker compose down

reset:     ## Stop everything AND delete all data volumes (fresh start)
	docker compose down -v

logs:      ## Follow Airflow logs
	docker compose logs -f airflow

ps:        ## Show container status
	docker compose ps

venv:      ## Create a local Python virtualenv for scripts and tests
	python3 -m venv .venv && . .venv/bin/activate && pip install -r requirements-dev.txt

check:     ## Quick health check of the running stack
	./scripts/check_setup.sh
