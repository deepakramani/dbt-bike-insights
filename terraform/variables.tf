variable "project_id" {
  description = "GCP project ID"
  type        = string
  default     = "learn-apache-443615"
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-west1"
}

variable "zone" {
  description = "GCP zone for the compute instance"
  type        = string
  default     = "us-west1-a"
}

variable "instance_name" {
  description = "Name of the compute instance"
  type        = string
  default     = "my-elt-gcp-vm"
}

variable "machine_type" {
  description = "Machine type for the compute instance"
  type        = string
  default     = "e2-medium"
}

variable "boot_disk_size" {
  description = "Size of the boot disk in GB"
  type        = number
  default     = 10
}

variable "data_bucket_name" {
  description = "Name of the GCP bucket for CSV files"
  type        = string
  default     = "learn-apache-443615-dbt-bike-insights-data"
}

variable "tfstate_bucket_name" {
  description = "Name of the GCP bucket for Terraform state"
  type        = string
  default     = "learn-apache-443615-tfstate"
}

variable "csv_files" {
  description = "Mapping of CSV file names to their local source paths"
  type        = map(string)
  default = {
    "crm_cust_info.csv"     = "../warehouse/input_data/source_crm/cust_info_new.csv",
    "crm_prd_info.csv"      = "../warehouse/input_data/source_crm/prd_info.csv",
    "crm_sales_details.csv" = "../warehouse/input_data/source_crm/sales_details.csv",
    "erp_cust_az12.csv"     = "../warehouse/input_data/source_erp/cust_az12.csv",
    "erp_loc_a101.csv"      = "../warehouse/input_data/source_erp/loc_a101.csv",
    "erp_px_cat_g1v2.csv"   = "../warehouse/input_data/source_erp/px_cat_g1v2.csv"
  }
}

