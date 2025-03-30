import pandas as pd
import os
import numpy as np
import random
from datetime import datetime, timedelta


def gen_new_cols(data_df: pd.DataFrame) -> pd.DataFrame:
    valid_rows_df = data_df[data_df["cst_id"].notna()].copy()
    noisy_rows_df = data_df[data_df["cst_id"].isna()].copy()
    valid_rows_df["cst_id"] = [int(x) for x in valid_rows_df["cst_id"]]

    valid_rows_df.columns = valid_rows_df.columns.str.strip()
    valid_rows_df["cst_firstname"] = valid_rows_df["cst_firstname"].str.strip()
    valid_rows_df["cst_lastname"] = valid_rows_df["cst_lastname"].str.strip()

    start_date = datetime(2008, 12, 1)
    end_date = datetime(2014, 12, 31)

    date_range = [
        start_date + timedelta(days=random.randint(0, (end_date - start_date).days))
        for _ in range(len(valid_rows_df))
    ]
    date_range.sort()
    valid_rows_df["cst_create_date"] = [
        date.strftime("%Y-%m-%d") for date in date_range
    ]

    email_domains = [
        "towels",
        "hostinger",
        "nappa",
        "cappo",
        "fountains",
        "mouse",
        "sticks",
        "circles",
        "papers",
        "winds",
    ]

    valid_rows_df["email"] = (
        valid_rows_df["cst_firstname"]
        .str.lower()
        .str.cat(valid_rows_df["cst_lastname"].str.lower(), sep=".")
        + "@"
        + np.random.choice(email_domains, len(valid_rows_df))
        + ".com"
    )

    cities = [
        "Tokyo",
        "Seoul",
        "Shanghai",
        "Mumbai",
        "Delhi",
        "London",
        "Paris",
        "Berlin",
        "Rome",
        "Madrid",
        "Istanbul",
        "Moscow",
        "Bangkok",
        "Singapore",
        "Jakarta",
    ]
    valid_rows_df["place_of_residence"] = [
        np.random.choice(cities) for _ in range(len(valid_rows_df))
    ]

    valid_rows_df["postal_code"] = np.random.choice(
        [
            code
            for code in range(10001, 59999)
            if code not in {20000, 30000, 40000, 50000}
        ],
        size=len(valid_rows_df),
        replace=True,  # Allows duplicates
    )
    # data_df = pd.concat([valid_rows_df, noisy_rows_df], ignore_index=True)

    return valid_rows_df


def main():
    data_df = pd.read_csv("./docker/input_data/source_crm/cust_info.csv")
    processed_df = gen_new_cols(data_df)
    processed_df.to_csv("./docker/input_data/source_crm/cust_info_new.csv", index=False)


if __name__ == "__main__":
    main()
