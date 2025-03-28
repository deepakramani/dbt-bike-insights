SHELL:=/bin/bash

.PHONY: help install_docker pg up down dbt_setup \
        setup_bronze_tables populate_bronze_tables \
        setup_silver_tables populate_silver_tables \
        setup_gold_tables populate_gold_tables \
        run_silver run_gold run_analytics load_gold_tables \
        test_bronze test_silver test_gold compile_analyses

help:
	@echo "Usage: make [target]"
	@echo
	@echo "Recommended order to run commands:"
	@echo "  1. make install_docker          # Install Docker and prerequisites"
	@echo "  2. Install dbt                  # Install dbt-core and others"
	@echo "  3. make dbt_setup               # Setup dbt environment"
	@echo "  4. make pg                       # Connect to PostgreSQL using pgcli"
	@echo "  5. make up                       # Start the ETL DWH environment"
	@echo "  6. make down                     # Stop and remove the ETL DWH environment"
	@echo "  7. make setup_bronze_tables      # Create Bronze tables"
	@echo "  8. make populate_bronze_tables   # Populate Bronze tables"
	@echo "  9. make setup_silver_tables      # Create Silver tables"
	@echo " 10. make populate_silver_tables  # Populate Silver tables"
	@echo " 11. make setup_gold_tables        # Create Gold tables"
	@echo " 12. make populate_gold_tables    # Populate Gold tables"
	@echo " 13. make run_silver              # Run dbt models for the silver layer"
	@echo " 14. make run_gold                # Run dbt models for the gold layer"
	@echo " 15. make run_analytics           # Run analytics models"
	@echo " 16. make load_gold_tables        # Load gold tables to DuckDB"
	@echo " 17. make test_bronze             # Test Bronze layer"
	@echo " 18. make test_silver             # Test Silver layer"
	@echo " 19. make test_gold               # Test Gold layer"
	@echo " 20. make compile_analyses         # Compile Analyses queries"
	@echo "Run 'make <target>' to execute a specific step.""

install_docker:
	source ./scripts/install_docker.sh 

install_dbt:
	source ./scripts/install_conda.sh
	@sleep 2
	pip install --upgrade pip
	pip install pipenv
	pipenv install dbt-core dbt-postgres dbt-duckdb

pg:
	pgcli -h localhost -p 5432 -U ${POSTGRES_USER} -d ${POSTGRES_DB}

up:
	docker-compose -f docker/docker-compose.yml up -d

down:
	docker-compose -f docker/docker-compose.yml down -v



dbt_setup:
	dbt clean
	@echo -n "checking postgres DB connections..."
	@sleep 2
	dbt debug --profile dbt_transform_postgres
	@echo -n "checking duckdb connections..."
	@sleep 1
	dbt debug --profile dbt_duckdb
	@echo -n "installing dependencies"
	@sleep 1
	dbt deps

setup_bronze_tables:
	dbt run --select setup_bronze --profile dbt_transform_postgres

populate_bronze_tables:
	dbt run --select populate_bronze --profile dbt_transform_postgres

setup_silver_tables:
	dbt run --select setup_silver --profile dbt_transform_postgres

populate_silver_tables:
	dbt run --select populate_silver --profile dbt_transform_postgres

setup_gold_tables:
	dbt run --select setup_gold --profile dbt_transform_postgres

populate_gold_tables:
	dbt run --select populate_gold --profile dbt_transform_postgres

run_silver:
	dbt compile --model silver --profile dbt_transform_postgres
	@sleep 2
	dbt run --select silver

run_gold:
	dbt compile --model gold --profile dbt_transform_postgres
	@sleep 2
	dbt run --select gold 

run_analytics:
	dbt compile --model analytics --profile dbt_duckdb
	@sleep 1
	dbt run --select analytics --profile dbt_duckdb

load_gold_tables:
	dbt compile --select copy_gold_tables --profile dbt_duckdb
	@sleep 1
	dbt run --select copy_gold_tables --profile dbt_duckdb

test_bronze:
	dbt test --select bronze --profile dbt_transform_postgres

test_silver:
	dbt test --select silver --profile dbt_transform_postgres

test_gold:
	dbt test --select gold --profile dbt_transform_postgres

compile_analyses:
	dbt compile --select analyses/** --profile dbt_duckdb
