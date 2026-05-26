.PHONY: up down restart etl reports all logs-csv

up:
	docker compose up -d

down:
	docker compose down -v


etl:
	docker exec spark /opt/spark/bin/spark-submit \
		--master "local[*]" \
		--jars /opt/jars/postgresql-42.7.3.jar \
		/opt/spark_jobs/etl_to_star_schema.py

reports:
	docker exec spark /opt/spark/bin/spark-submit \
		--master "local[*]" \
		--jars /opt/jars/postgresql-42.7.3.jar,/opt/jars/clickhouse-jdbc-0.6.3-all.jar \
		/opt/spark_jobs/reports_to_clickhouse.py

all:
	docker compose up -d
	@echo "ждеи CSV"
	@while ! docker inspect --format='{{.State.Status}}' csv-loader 2>/dev/null | grep -q "exited"; do sleep 3; done
	@if ! docker inspect --format='{{.State.ExitCode}}' csv-loader | grep -q "^0$$"; then \
		echo "ОШИБКА: csv-loader с ошибкой"; docker logs csv-loader; exit 1; fi
	@docker logs csv-loader 2>&1 | grep "строк в mock_data"
	@echo "ждем ClickHouse"
	@until docker exec clickhouse clickhouse-client --user spark --password spark123 --query "SELECT 1" >/dev/null 2>&1; do sleep 3; done
	$(MAKE) etl
	$(MAKE) reports

logs-csv:
	docker logs csv-loader
