import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import os
import warnings

warnings.filterwarnings("ignore")

output_dir = "output/loyalty/"
os.makedirs(output_dir, exist_ok=True)

# Load and prepare loyalty data
loyalty_data = pd.read_csv("~/Desktop/educ/dbt-bike-insight/docs/customer_loyalty.csv")
loyalty_data["first_purchase_date"] = pd.to_datetime(
    loyalty_data["first_purchase_date"]
)
loyalty_data["last_purchase_date"] = pd.to_datetime(loyalty_data["last_purchase_date"])
loyalty_data["tenure_days"] = (
    loyalty_data["last_purchase_date"] - loyalty_data["first_purchase_date"]
).dt.days

# 1. Customer Loyalty Segment Distribution
loyalty_counts = loyalty_data["loyalty_segment"].value_counts().reset_index()
loyalty_counts.columns = ["Loyalty Segment", "Count"]
fig1 = px.pie(
    loyalty_counts,
    values="Count",
    names="Loyalty Segment",
    title="Customer Loyalty Segment Distribution",
    color_discrete_sequence=px.colors.qualitative.Dark24,
    hole=0.4,
)
fig1.update_traces(textposition="inside", textinfo="percent+label")
fig1.update_layout(uniformtext_minsize=12, uniformtext_mode="hide")
fig1.show()
fig1.write_image(f"{output_dir}loyalty_segment_distribution.png")

# 2. Loyalty Segment Performance Comparison
loyalty_segment_agg = (
    loyalty_data.groupby("loyalty_segment")
    .agg(
        {
            "customer_key": "count",
            "order_count": "mean",
            "total_spent": "mean",
            "avg_spend_per_order": "mean",
            "tenure_days": "mean",
        }
    )
    .reset_index()
)
loyalty_segment_agg.columns = [
    "Loyalty Segment",
    "Customer Count",
    "Avg Orders",
    "Avg Total Spent",
    "Avg Spend Per Order",
    "Avg Tenure (Days)",
]

fig2 = make_subplots(
    rows=2,
    cols=2,
    subplot_titles=(
        "Average Total Spent",
        "Average Orders",
        "Average Spend Per Order",
        "Average Tenure (Days)",
    ),
)
metrics = ["Avg Total Spent", "Avg Orders", "Avg Spend Per Order", "Avg Tenure (Days)"]
positions = [(1, 1), (1, 2), (2, 1), (2, 2)]
for metric, pos in zip(metrics, positions):
    fig2.add_trace(
        go.Bar(
            x=loyalty_segment_agg["Loyalty Segment"],
            y=loyalty_segment_agg[metric],
            marker_color=["#1f77b4", "#ff7f0e", "#2ca02c"],
            text=round(loyalty_segment_agg[metric], 1),
        ),
        row=pos[0],
        col=pos[1],
    )
fig2.update_layout(
    title="Performance Metrics by Loyalty Segment", showlegend=False, height=700
)
fig2.update_traces(texttemplate="%{text}", textposition="inside")
fig2.show()
fig2.write_image(f"{output_dir}loyalty_performance_metrics.png")

# 3. Order Count vs Total Spent by Loyalty Segment
fig3 = px.scatter(
    loyalty_data,
    x="order_count",
    y="total_spent",
    color="loyalty_segment",
    opacity=0.7,
    size="avg_spend_per_order",
    title="Order Count vs Total Spent by Loyalty Segment",
    labels={
        "order_count": "Number of Orders",
        "total_spent": "Total Spent ($)",
        "loyalty_segment": "Loyalty Segment",
    },
    size_max=20,
    color_discrete_sequence=px.colors.qualitative.G10,
)
fig3.update_layout(legend_title="Loyalty Segment")
fig3.show()
fig3.write_image(f"{output_dir}order_count_vs_total_spent.png")

# 4. Purchase Frequency vs Average Spend
fig4 = px.scatter(
    loyalty_data,
    x="order_count",
    y="avg_spend_per_order",
    color="loyalty_segment",
    size="total_spent",
    hover_data=["customer_key", "unique_purchase_days", "tenure_days"],
    opacity=0.7,
    title="Purchase Frequency vs Average Spend by Loyalty Segment",
    labels={
        "order_count": "Number of Orders",
        "avg_spend_per_order": "Average Spend per Order ($)",
        "loyalty_segment": "Loyalty Segment",
    },
    color_discrete_sequence=px.colors.qualitative.Dark24,
    size_max=30,
)
fig4.update_layout(legend_title="Loyalty Segment")
fig4.show()
fig4.write_image(f"{output_dir}purchase_freq_vs_avg_spend.png")

# 5. Purchase Consistency Analysis
loyalty_data["purchase_consistency"] = (
    loyalty_data["unique_purchase_days"] / loyalty_data["order_count"]
)
fig5 = px.box(
    loyalty_data,
    x="loyalty_segment",
    y="purchase_consistency",
    color="loyalty_segment",
    title="Purchase Consistency by Loyalty Segment",
    labels={
        "purchase_consistency": "Purchase Consistency Ratio",
        "loyalty_segment": "Loyalty Segment",
    },
    points="all",
)
fig5.update_layout(
    showlegend=False,
    yaxis_title="Purchase Consistency Ratio (1.0 = All Orders on Different Days)",
)
fig5.show()
fig5.write_image(f"{output_dir}purchase_consistency.png")

print("Customer Loyalty Analysis visualizations completed and saved!")
