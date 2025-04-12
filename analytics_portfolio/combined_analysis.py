import pandas as pd
import plotly.express as px
import numpy as np
import os
import warnings

warnings.filterwarnings("ignore")

output_dir = "output/combined/"
os.makedirs(output_dir, exist_ok=True)

# Load and prepare loyalty data (since it’s used in combined analysis)
loyalty_data = pd.read_csv("~/Desktop/educ/dbt-bike-insight/docs/customer_loyalty.csv")
loyalty_data["first_purchase_date"] = pd.to_datetime(
    loyalty_data["first_purchase_date"]
)
loyalty_data["last_purchase_date"] = pd.to_datetime(loyalty_data["last_purchase_date"])
loyalty_data["tenure_days"] = (
    loyalty_data["last_purchase_date"] - loyalty_data["first_purchase_date"]
).dt.days

# Simulate LTV quintiles for combined analysis
np.random.seed(42)
loyalty_data["ltv_quintile"] = np.random.randint(1, 6, size=len(loyalty_data))
loyalty_data.loc[loyalty_data["loyalty_segment"] == "Loyal", "ltv_quintile"] = (
    np.random.choice(
        [3, 4, 5],
        size=sum(loyalty_data["loyalty_segment"] == "Loyal"),
        p=[0.2, 0.3, 0.5],
    )
)
loyalty_data.loc[loyalty_data["loyalty_segment"] == "Occasional", "ltv_quintile"] = (
    np.random.choice(
        [2, 3, 4],
        size=sum(loyalty_data["loyalty_segment"] == "Occasional"),
        p=[0.4, 0.4, 0.2],
    )
)
loyalty_data.loc[loyalty_data["loyalty_segment"] == "One-Time", "ltv_quintile"] = (
    np.random.choice(
        [1, 2], size=sum(loyalty_data["loyalty_segment"] == "One-Time"), p=[0.7, 0.3]
    )
)

# 1. Combined Segmentation - Value vs Loyalty
segment_matrix = pd.crosstab(
    loyalty_data["loyalty_segment"],
    loyalty_data["ltv_quintile"],
    values=loyalty_data["total_spent"],
    aggfunc="mean",
).fillna(0)

fig1 = px.imshow(
    segment_matrix,
    labels=dict(x="LTV Quintile", y="Loyalty Segment", color="Avg Total Spent ($)"),
    x=["Q1 (Lowest)", "Q2", "Q3", "Q4", "Q5 (Highest)"],
    y=["One-Time", "Occasional", "Loyal"],
    color_continuous_scale="Viridis",
    title="Average Customer Value by Loyalty-LTV Matrix",
    text_auto=True,
)
fig1.update_layout(xaxis_title="Customer Value Quintile", yaxis_title="Loyalty Segment")
fig1.update_traces(texttemplate="$%{z:.0f}")
fig1.show()
fig1.write_image(f"{output_dir}loyalty_ltv_heatmap.png")

print("Combined Analysis visualization completed and saved!")
