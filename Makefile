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
        @echo "  8. make run_silver              # Run dbt models for the silver layer"
        @echo "  9. make run_gold                # Run dbt models for the gold layer"
        @echo " 10. make run_analytics           # Run analytics models"
        @echo " 11. make load_gold_tables        # Load gold tables to DuckDB"
        @echo " 12. make test_silver             # Test Silver layer"
        @echo " 13. make test_gold               # Test Gold layer"
        @echo " 14. make compile_analyses        # Compile Analyses queries"
        @echo "Run 'make <target>' to execute a specific step."

install_docker:
        source ./docker/scripts/install_docker.sh

install_dbt:
        source ./docker/scripts/install_conda.sh
        @sleep 2
        pip install --upgrade pip
        pip install pipenv
        pipenv install dbt-core dbt-postgres dbt-duckdb

install_duckdb:
        source ./docker/scripts/install_duckdb.sh
        @sleep 2

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

test_silver:
        dbt test --select silver --profile dbt_transform_postgres

test_gold:
        dbt test --select gold --profile dbt_transform_postgres

compile_analyses:
        dbt compile --select analyses/** --profile dbt_duckdb