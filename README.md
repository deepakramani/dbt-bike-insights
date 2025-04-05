# dbt-bike-insights: From Bike Shop Chaos to Data-Driven Wins

Imagine a bike shop coasting on decent sales, oblivious to untapped potential. Their CRM and ERP data—six scattered CSV files—held the answers, but no one was asking the right questions. I built an ELT pipeline with dbt, PostgreSQL (via Docker), and DuckDB to change that. Raw data flowed into a PostgreSQL warehouse, shaped by a medallion architecture, and polished into insights with DuckDB. From revenue drivers to inventory traps, here’s how I solved real problems with data.

## At a Glance
- **Stack**: dbt (ELT), PostgreSQL (DWH via Docker), DuckDB (analytics), SQL  
- **Pipeline**: CSV ingestion → PostgreSQL (Bronze → Silver → SCD2 Snapshots → Gold) → DuckDB analysis 
- **Data**: 6 CSV files (CRM: customers, products, sales; ERP: customers, locations, categories)  
- **Features**: SCD2 snapshots, data quality checks, advanced analytics (CLV, affinity)  
- **Outcome**: Unified marts and actionable insights   

## Medallion Architecture in Action
- **Bronze**: Raw CSV ingestion into PostgreSQL via Docker. Loaded 6 files (e.g., `crm_sales_details.csv`) with minimal cleaning.
- **Silver**: Cleaned and standardized data. Deduped customers across CRM/ERP, normalized dates, and joined tables (e.g., `customer_id` aligned). Created SCD2 snapshots to track changes (e.g., stock updates).  
- **Gold**: Aggregated into marts—`customers`, `products`, `sales`. Fed by snapshots, these power analytics like revenue rankings and CLV.  
Data flows from PostgreSQL to DuckDB for fast, local analysis.

## dbt Highlights
- **Data Quality**: Custom tests (e.g., `not_null` on `customer_id`, `unique` on `sale_id`) ensure integrity across layers.  
- **SCD2 Snapshots**: Post-silver, tracked historical changes (e.g., `stock` over time) using dbt’s snapshot feature.  
- **Coming Soon**:  
  - *CI/CD*: GitHub Actions to run `dbt test` on push—production-ready automation.  
  - *Dashboarding*: Evidence or Metabase to visualize problems (e.g., revenue by product).  


## Run It Yourself
1. **Clone the Repo**: `git clone https://github.com/deepakramani/dbt-bike-insights.git`  
2. **Install Dependencies**: `make install_conda && make install_docker && make install_duckdb`  
(Optional): Export Postgres and dbt environment variables.
3. **Start the Data Warehouse**: `cd ~/dbt-bike-insights/ && make up`
4. **Set Up dbt**: `conda create -n mydbt python=3.9 dbt-core dbt-postgres -y && conda activate mydbt && && make dbt_setup`
5. **Run the Pipeline**: `dbt run --select bronze silver && dbt snapshot && dbt run --select gold`
6. **Copy to DuckDB**: `make load_gold_tables`  
7. **Analyze in DuckDB**: `make run_analytics`
8. **Bringing down resources**: `make down`

See [detailed setup](./docs/setup.md) for more.
