A small-scale ETL project to demonstrate the capabilities of dbt in adding flexibility to data transformations. This is a portfolio project that takes a small dataset and follows some of the industry standards of developing an ETL pipeline and maintaining it. Feel free to suggest improvements or point out mistake from me to learn. 

# Instructions to run the ETL pipeline and bring data to data warehouse

This project is tested with AWS/GCP linux machine running Ubuntu 20.04 and Mac M1. Since the focus is on building an ETL pipeline, the user is advised patience if the setup has bugs or problems.

## Install Docker and Conda

```{.bash filename="Clone, install docker and conda"}
cd ~
sudo apt update && sudo apt install git make -y
git clone https://github.com/deepakramani/etl_with_dbt_dwh.git
cd etl_with_dbt_dwh
make install_conda
make install_docker
source ~/.bashrc
```

Logout and log in back to the instance. To test docker if it is working, run
```
docker run --rm hello-world # should return "Hello from Docker!" without errors
```
**Set environment variables:**

```{.bash filename="export env variables"}
export POSTGRES_USER=postgres                                            
export POSTGRES_PASSWORD=postgres
export POSTGRES_HOST=localhost
export POSTGRES_DB=sql_dwh_db
export DBT_PROFILES_DIR=$(pwd)
```

Now we're ready start our project

```
cd ~/etl_with_dbt_dwh 
make up # runs the postgres docker container, creates bronze layer tables and loads data from csv files into it.
conda create -n mydbt python=3.9 dbt-core dbt-postgres -y # install conda env with dbt-core and dbt-postgres packages.
conda activate mydbt

```

Before we start `dbt`, make sure the `dbt_project.yml` is no errors, `macros` directory has the three generic tests, `tests` directory has one custom test file, in DB raw data tables are present inside `bronze` schema. 

```{.bash filename="run dbt commands"}
cd ~/etl_with_dbt_dwh  
make dbt_setup # cleans, debugs dbt project for errors and installs dependencies
make run_silver # runs only silver layer model
make run_gold # runs only gold layer model
make test_silver # data quality tests for silver layer tables
make test_gold # data quality tests for gold layer tables
```

# Explanation
Keen observers following or read my other project using SQL, will realise the ingestion into postgres DB is done independent of the data transformation. Indeed, it is so. dbt allows `dbt seed` capability to seed `raw_data` into DB. However, I find this method slower than `bulk insert` mode with `COPY` command in postgres. 

Now that the `raw_data` is in the DB, the process is little simpler with just two layers -- staging and serving layer. Here we use `silver` for staging and `gold` for serving.

**NOTE:** Since the `gold` layer is materialised as `view`, having issues with dbt execution order -- dbt executes the dependent `fact_sales` view before `dim_customers` and `dim_produts` view are fully materialised. Hence the split `dbt run` command. 

DBT also offers flexibility interms of writing tests -- generic or specific test cases. DBT provide a host of built-in functions that enable faster testing capability than long,cumbersome, repetitive SQL script. 

## dbt transformations


## dbt data quality checks

Wherever possible dbt's built-in generic tests are used. 

Common checks used are - 
- unique, not_null, expression_check, date_range_check, accepted_values_check, whitespaces_check.

When built-in tests are available, custom test macro is implemented inside `macros` directory. This way allows testing to be flexible, extensible and non-repetitive.
These checks are written inside `schema.yml` allowing schema standardisation and possible evolution. 

Singular/specific test come under `tests` directory. We place a test that checks the gold layer view `fact_sales` which depends on `dim_customers` and `dim_products` forming a star schema inside the data warehouse. 




Try running the following commands:
- dbt run
- dbt test


### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
