SHELL:=/bin/bash

.PHONY: help install_docker setup_bronze_tables populate_bronze_tables setup_silver_tables populate_silver_tables setup_gold_layer test_silver_layer test_gold_layer

help:
	@echo "Usage: make [target]"
	@echo
	@echo "Recommended order to run commands:"
	@echo "  1. make install_docker         # Install Docker and prerequisites"
	@echo "  2. make pg                        # Connect to PostgreSQL using pgcli"
	@echo "  3. make up                        # Start the ETL DWH environment"
	@echo "  4. make down                      # Stop and remove the ETL DWH environment"
	@echo "  5. make dbt_setup                 # Setup dbt environment"
	@echo "  6. make run_silver                # Run dbt models for the silver layer"
	@echo "  7. make run_gold                  # Run dbt models for the gold layer"
	@echo "  8. make test_silver               # Test dbt models for the silver layer"
	@echo "  9. make test_gold                 # Test dbt models for the gold layer"
	@echo "Run 'make <target>' to execute a specific step."


install_docker:
	source ./scripts/install_docker.sh 

pg:
	pgcli -h localhost -p 5432 -U ${POSTGRES_USER} -d ${POSTGRES_DB}

up:
	docker-compose up -d

down:
	docker-compose down -v

dbt_setup:
	dbt clean && dbt debug && dbt deps

run_silver:
	dbt run --select silver

run_gold:
	dbt run --select gold 

test_silver:
	dbt compile
	@sleep 1
	dbt test --select silver

test_gold:
	dbt compile
	@sleep 1
	dbt test --select gold
