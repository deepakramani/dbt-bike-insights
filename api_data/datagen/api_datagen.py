import csv
import json
from faker import Faker
import random

# Initialize Faker
fake = Faker()

# --- 1. Process crm_cust_info.csv ---
print("Processing cust_info.csv...")

# File paths
cust_info_path = "cust_info_all.csv"
sales_details_path = "sales_details_all.csv"

# Output JSON paths
cust_info_output = "../cust_info_with_attributes.json"
sales_details_output = "../sales_details_with_attributes.json"

# --- Extract cst_id from cust_info.csv ---
cst_ids = []
try:
    with open(cust_info_path, "r", newline="", encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            cst_ids.append(row["cst_id"])
    print(f"Extracted {len(cst_ids)} cst_ids from cust_info_new.csv")
except FileNotFoundError:
    print(f"Error: File {cust_info_path} not found.")
    exit(1)

# --- Generate fake data for cust_info ---
print("Generating fake data for cust_info...")
cust_attributes_data = []
for cst_id in cst_ids:
    # Generate consistent fake data based on cst_id hash for repeatability (optional)
    # fake.seed_instance(hash(cst_id)) # Uncomment for deterministic results per ID

    personality_traits = [
        "Adventurous",
        "Analytical",
        "Creative",
        "Disciplined",
        "Easygoing",
        "Impulsive",
        "Organized",
        "Outgoing",
        "Reserved",
        "Spontaneous",
    ]
    locations = ["Urban", "Suburban", "Rural"]

    attributes = {
        "cst_id": cst_id,
        "personality": fake.random_element(elements=personality_traits),
        "average_income": round(
            random.uniform(30000, 150000), 2
        ),  # Income between 30k and 150k
        "credit_score": fake.random_int(
            min=300, max=850
        ),  # Standard credit score range
        "urban_rural": fake.random_element(elements=locations),
    }
    cust_attributes_data.append(attributes)

# --- Save cust_info attributes to JSON ---
try:
    with open(cust_info_output, "w", encoding="utf-8") as jsonfile:
        json.dump(cust_attributes_data, jsonfile, indent=4)
    print(f"Saved cust_info attributes to {cust_info_output}")
except Exception as e:
    print(f"Error saving cust_info JSON: {e}")
    exit(1)

# --- 2. Process sales_details.csv ---
print("\nProcessing sales_details.csv...")

# --- Extract sls_ord_num from crm_sales_details.csv ---
sls_ord_nums = []
try:
    with open(sales_details_path, "r", newline="", encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile)
        # Read all rows and extract sls_ord_num
        rows = list(reader)
        for row in rows:
            sls_ord_nums.append(row["sls_ord_num"])
    print(f"Extracted {len(sls_ord_nums)} sls_ord_nums from sales_details.csv")
except FileNotFoundError:
    print(f"Error: File {sales_details_path} not found.")
    exit(1)

# --- Generate fake data for sales_details ---
print("Generating fake data for sales_details...")
sales_attributes_data = []
carriers = ["FedEx", "UPS", "DHL", "USPS", "Amazon Logistics", "Regional Carrier"]

for i, sls_ord_num in enumerate(sls_ord_nums):
    # Generate consistent fake data based on index or ID hash for repeatability (optional)
    # fake.seed_instance(hash(sls_ord_num) + i) # Uncomment for deterministic results

    attributes = {
        "sls_ord_num": sls_ord_num,  # Keep the ID for joining downstream
        "sls_quantity": fake.random_int(min=1, max=4),
        "tracking_id": fake.bothify(
            text="TRK-########"
        ),  # Generates a tracking ID like TRK-A1B2C3D4
        "carrier": fake.random_element(elements=carriers),
        "shipping_fee": round(
            random.uniform(5.99, 45.99), 2
        ),  # Shipping fee between $5.99 and $45.99
    }
    sales_attributes_data.append(attributes)

# --- Save sales_details attributes to JSON ---
try:
    with open(sales_details_output, "w", encoding="utf-8") as jsonfile:
        json.dump(sales_attributes_data, jsonfile, indent=4)
    print(f"Saved sales_details attributes to {sales_details_output}")
except Exception as e:
    print(f"Error saving sales_details JSON: {e}")
    exit(1)

print("\nData generation and JSON export completed successfully.")
