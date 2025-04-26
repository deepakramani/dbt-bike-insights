SHELL := /bin/bash

.PHONY: help install_docker install_dbt install_duckdb pg up down dbt_setup \
	    run_silver run_gold run_analytics load_gold_tables \
	    test_silver test_gold compile_analyses

help:
	    @echo "Usage: make [target]"
	    @echo
	    @echo "Recommended order to run commands:"
	    @echo "  1. make install_docker          # Install Docker and prerequisites"
	    @echo "  2. make install_dbt             # Install dbt-core and others"
	    @echo "  3. make install_duckdb          # Install duckdb cli"
	    @echo "  4. make dbt_setup               # Setup dbt environment"
	    @echo "  5. make up                      # Start the ETL DWH environment"
	    @echo "  6. make pg                      # Connect to PostgreSQL using pgcli"
	    @echo "  7. make down                    # Stop and remove the ETL DWH environment"
		@echo "  8. make run_bronze              # Run dbt models for the bronze layer"
	    @echo "  9. make run_silver              # Run dbt models for the silver layer"
		@echo " 10. make run_snapshot            # Run dbt snapshots on the silver layer"
	    @echo " 11. make run_gold                # Run dbt models for the gold layer"
	    @echo " 12. make load_gold_tables        # Load gold tables to DuckDB"
		@echo " 13. make run_analytics           # Run analytics models"
		@echo " 14. make test_bronze             # Test Bronze layer"
	    @echo " 15. make test_silver             # Test Silver layer"
		@echo " 16. make test_snapshots			 # Test SCD2 Snapshots"
	    @echo " 17. make test_gold               # Test Gold layer"
	    @echo " 18. make compile_analyses        # Compile Analyses queries"
		@echo " 19. make docgen					 # Generates and serves documentation"
	    @echo "Run 'make <target>' to execute a specific step."

install_docker:
	    source ./warehouse/scripts/install_docker.sh

install_conda:
	    source ./warehouse/scripts/install_conda.sh

install_dbt:
		{HOME}/soft/miniforge3/bin/conda activate base
	    pip install --upgrade pip
	    pip install pipenv
		pipenv install
	    # pipenv install dbt-core dbt-postgres dbt-duckdb

install_duckdb:
	    source ./warehouse/scripts/install_duckdb.sh
	    @sleep 2

pg:
	    pgcli -h localhost -p 5432 -U ${POSTGRES_USER} -d ${POSTGRES_DB}

up:
	    docker-compose -f warehouse/docker-compose.yml up -d

down:
	    docker-compose -f warehouse/docker-compose.yml down -v

dbt_setup:
	    dbt clean
	    @echo -n "checking postgres DB connections... "
	    @sleep 2
	    dbt debug --profile dbt_transform_postgres
	    @echo -n "checking duckdb connections... "
	    @sleep 1
	    dbt debug --profile dbt_duckdb
	    @echo -n "installing dependencies. "
	    @sleep 1
	    dbt deps

run_bronze:
		dbt compile --select bronze --profile dbt_transform_postgres
	    @sleep 2
	    dbt run --select bronze

run_silver:
	    dbt compile --select silver --profile dbt_transform_postgres
	    @sleep 2
	    dbt run --select silver

run_snapshot:
		dbt snapshot
		@sleep 1

run_gold:
	    dbt compile --select gold --profile dbt_transform_postgres
	    @sleep 2
	    dbt run --select gold

load_gold_tables:
	    dbt compile --select copy_gold_tables_to_duckdb --profile dbt_duckdb
	    @sleep 1
	    dbt run --select copy_gold_tables_to_duckdb --profile dbt_duckdb

run_analytics:
		dbt compile --select analytics --profile dbt_duckdb
		@sleep 1
		dbt run --select analytics --profile dbt_duckdb	
	   

test_bronze:
	    dbt test --select bronze --profile dbt_transform_postgres

test_silver:
	    dbt test --select silver --profile dbt_transform_postgres

test_snapshots:
		dbt test --select customers_snapshot
		@sleep 1
		dbt test --select products_snapshot

test_gold:
	    dbt test --select gold --profile dbt_transform_postgres

compile_analyses:
	    dbt compile --select analyses/** --profile dbt_duckdb

docgen:
		dbt docs generate --profile dbt_duckdb 
		@sleep 2
		dbt docs serve