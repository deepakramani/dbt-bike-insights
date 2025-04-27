# Detailed instructions to setup the project

This project is tested with AWS/GCP linux machine running Ubuntu 20.04 and Mac M1. Since the focus is on building an ETL pipeline, the user is advised patience if the setup has bugs or problems.

## Install Docker and Conda

```{.bash filename="Clone, install docker and conda"}
cd ~
sudo apt update && sudo apt install git make -y
git clone https://github.com/deepakramani/dbt-bike-insights.git
cd ~/dbt-bike-insights
make install_conda
make install_docker
source ~/.bashrc
```

Logout and log in back to the instance. To test docker if it is working, run
```
docker run --rm hello-world # should return "Hello from Docker!" without errors
```

```{.bash filename="install dbt, duckdb and astronomer CLI"}
cd ~/dbt-bike-insights
make install_dbt
make install_duckdb
```

**(optional) - terraform instructions**

These instructions require one to have active GCP account, appropriate service account with sufficient privileges(resource manager, storage, compute APIs). A GCS bucket needs to be created for terraform remote backend state file.

```{.bash filename="Terraform instructions"}
cd ~/dbt-bike-insights/terraform
terraform init # sets up terraform and remote backend
terraform plan # should see 4 number of resources to be installed
terraform apply -auto-approve # allocate resources and install docker and conda
```

Now we can log into the VM and continue to setup our project environment

```{.bash filename="install dbt, duckdb and astronomer CLI"}
cd ~/dbt-bike-insights
make install_dbt
make install_duckdb
make install_astro_CLI

```

After this, the VM is ready for the project. Continue with below instructions.

## Set environment variables

```{.bash filename="export env variables"}
export POSTGRES_USER=postgres                             
export POSTGRES_PASSWORD=postgres 
export POSTGRES_HOST=localhost 
export POSTGRES_DB=sql_dwh_db 
export POSTGRES_PORT=5432 
export DBT_PROJECT_DIR=$(pwd)/dbt_transform 
export DBT_PROFILES_DIR=$(pwd)/dbt_transform 
export DUCKDB_PATH=$(pwd)/dwh.duckdb
```

Now we're ready start our project

```
cd ~/dbt-bike-insights
make up # runs the postgres docker container, creates raw schema tables and loads data from csv files into it.
conda create -n mydbt python=3.9 dbt-core dbt-postgres -y # install conda env with dbt-core and dbt-postgres packages.
conda activate mydbt

```

Before we start `dbt`, make sure the `dbt_project.yml` is no errors, `macros` directory has the three generic tests, `tests` directory has one custom test file, in DB raw data tables are present inside `bronze` schema. 

```{.bash filename="run dbt commands"}
cd ~/dbt-bike-insights 
make dbt_setup # clears dbt target cache, debugs dbt project for errors and installs dependencies
make run_bronze # loads data into the bronze layer with minimal cleaning
make test_bronze # tests bronze layer tables
make run_silver # runs only silver layer model. Data is cleaned, transformed and enriched.
make test_silver # tests silver layer tables
make run_snapshot # builds SCD2 tables on the silver layer tables
make test_snapshot # runs basic tests on the generated snapshot tables
make run_gold # runs only gold layer model using snapshot as source. Data is ready for business.
make test_gold # data quality tests for gold layer tables
make load_gold_tables # copies gold layer data into duckDB for analytics
make run_analytics # builds and runs analytics model
make run_analyses # compiles ad-hoc analytic SQL queries.

make docgen # generates and serves documentation
make down #shutdown resources
```