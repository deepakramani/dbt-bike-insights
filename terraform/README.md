## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | 6.8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 6.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.static_ip](https://registry.terraform.io/providers/hashicorp/google/6.8.0/docs/resources/compute_address) | resource |
| [google_compute_firewall.allow_ports](https://registry.terraform.io/providers/hashicorp/google/6.8.0/docs/resources/compute_firewall) | resource |
| [google_compute_instance.elt_vm](https://registry.terraform.io/providers/hashicorp/google/6.8.0/docs/resources/compute_instance) | resource |
| [google_compute_network.elt_network](https://registry.terraform.io/providers/hashicorp/google/6.8.0/docs/resources/compute_network) | resource |
| [google_storage_bucket.data_bucket](https://registry.terraform.io/providers/hashicorp/google/6.8.0/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_object.csv_files](https://registry.terraform.io/providers/hashicorp/google/6.8.0/docs/resources/storage_bucket_object) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_boot_disk_size"></a> [boot\_disk\_size](#input\_boot\_disk\_size) | Size of the boot disk in GB | `number` | `10` | no |
| <a name="input_csv_files"></a> [csv\_files](#input\_csv\_files) | Mapping of CSV file names to their local source paths | `map(string)` | <pre>{<br/>  "crm_cust_info.csv": "../warehouse/input_data/source_crm/cust_info_new.csv",<br/>  "crm_prd_info.csv": "../warehouse/input_data/source_crm/prd_info.csv",<br/>  "crm_sales_details.csv": "../warehouse/input_data/source_crm/sales_details.csv",<br/>  "erp_cust_az12.csv": "../warehouse/input_data/source_erp/cust_az12.csv",<br/>  "erp_loc_a101.csv": "../warehouse/input_data/source_erp/loc_a101.csv",<br/>  "erp_px_cat_g1v2.csv": "../warehouse/input_data/source_erp/px_cat_g1v2.csv"<br/>}</pre> | no |
| <a name="input_data_bucket_name"></a> [data\_bucket\_name](#input\_data\_bucket\_name) | Name of the GCP bucket for CSV files | `string` | `"learn-apache-443615-dbt-bike-insights-data"` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Name of the compute instance | `string` | `"my-elt-gcp-vm"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | Machine type for the compute instance | `string` | `"e2-micro"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP project ID | `string` | `"learn-apache-443615"` | no |
| <a name="input_region"></a> [region](#input\_region) | GCP region for resources | `string` | `"us-central1"` | no |
| <a name="input_tfstate_bucket_name"></a> [tfstate\_bucket\_name](#input\_tfstate\_bucket\_name) | Name of the GCP bucket for Terraform state | `string` | `"learn-apache-443615-tfstate"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | GCP zone for the compute instance | `string` | `"us-central1-a"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_static_ip"></a> [instance\_static\_ip](#output\_instance\_static\_ip) | n/a |
