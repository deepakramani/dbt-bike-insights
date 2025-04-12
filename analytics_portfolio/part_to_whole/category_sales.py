import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import os
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots

# For better-looking plots
plt.style.use("ggplot")
sns.set_palette("viridis")


output_dir = "output/part_to_whole/"

# Create the directory if it doesn't exist
os.makedirs(output_dir, exist_ok=True)

# Assuming you've exported your SQL results to CSV files
# Let's load them

category_data = pd.read_csv("~/Desktop/educ/dbt-bike-insight/docs/category_summary.csv")
subcategory_data = pd.read_csv(
    "~/Desktop/educ/dbt-bike-insight/docs/subcategory_details.csv"
)

# Clean up percentage columns by removing % and converting to float
for df in [category_data, subcategory_data]:
    for col in df.columns:
        if "percentage" in col:
            df[col] = df[col].str.rstrip("%").astype("float")

# Now let's create visualizations

# 1. Sales Distribution by Category - Pie Chart
fig = px.pie(
    category_data,
    values="total_sales",
    names="product_category",
    title="Sales Distribution by Product Category",
    color_discrete_sequence=px.colors.qualitative.Bold,
    hole=0.4,
)
fig.update_traces(textposition="inside", textinfo="percent+label")
fig.update_layout(uniformtext_minsize=12, uniformtext_mode="hide")
static_path = os.path.join(output_dir, "sales_dist_cat.png")
fig.write_image(static_path)
print(f"Static pie chart saved to {static_path}")


# 2. Orders Distribution by Category - Pie Chart
fig = px.pie(
    category_data,
    values="total_orders",
    names="product_category",
    title="Orders Distribution by Product Category",
    color_discrete_sequence=px.colors.qualitative.Safe,
    hole=0.4,
)
fig.update_traces(textposition="inside", textinfo="percent+label")
fig.update_layout(uniformtext_minsize=12, uniformtext_mode="hide")
static_path = os.path.join(output_dir, "order_dist_cat.png")
fig.write_image(static_path)
print(f"Static pie chart saved to {static_path}")

# 3. Contrast between Sales and Orders - Bar Chart
fig = make_subplots(rows=1, cols=2, specs=[[{"type": "domain"}, {"type": "domain"}]])
fig.add_trace(
    go.Pie(
        labels=category_data["product_category"],
        values=category_data["total_sales"],
        name="Sales",
    ),
    1,
    1,
)
fig.add_trace(
    go.Pie(
        labels=category_data["product_category"],
        values=category_data["total_orders"],
        name="Orders",
    ),
    1,
    2,
)
fig.update_traces(hole=0.4, hoverinfo="label+percent+name")
fig.update_layout(
    title_text="Comparison of Sales vs Orders by Category",
    annotations=[
        dict(text="Sales", x=0.18, y=0.5, font_size=20, showarrow=False),
        dict(text="Orders", x=0.82, y=0.5, font_size=20, showarrow=False),
    ],
)
static_path = os.path.join(output_dir, "sales_vs_order.png")
fig.write_image(static_path)
print(f"Static bar chart saved to {static_path}")


# Subcategory Analysis vis

# 4. Top Subcategories by Sales - Horizontal Bar Chart
top_subcategories = subcategory_data.sort_values("total_sales", ascending=False).head(
    10
)
fig = px.bar(
    top_subcategories,
    x="total_sales",
    y="product_subcategory",
    color="product_category",
    orientation="h",
    title="Top 10 Subcategories by Sales",
    labels={
        "total_sales": "Total Sales ($)",
        "product_subcategory": "Product Subcategory",
    },
    text="percentage_of_total_sales",
)
fig.update_traces(texttemplate="%{text:.1f}%", textposition="outside")
fig.update_layout(yaxis={"categoryorder": "total ascending"})

static_path = os.path.join(output_dir, "top_sales_sub_cat.png")
fig.write_image(static_path)
print(f"Static bar chart saved to {static_path}")

# 5. Subcategory Sales vs. Order Volume - Bubble Chart
fig = px.scatter(
    subcategory_data,
    x="total_orders",
    y="total_sales",
    size="total_items",
    color="product_category",
    hover_name="product_subcategory",
    text="product_subcategory",
    size_max=60,
    title="Sales vs. Orders by Subcategory (Size = Item Volume)",
)
fig.update_traces(textposition="top center")
fig.update_layout(
    xaxis_title="Number of Orders",
    yaxis_title="Total Sales ($)",
)
static_path = os.path.join(output_dir, "sub_sales_vs_order_volume.png")
fig.write_image(static_path)
print(f"Static scatter chart saved to {static_path}")

# 6. Average Price vs. Sales Volume - Scatter Plot
fig = px.scatter(
    subcategory_data,
    x="avg_price_per_item",
    y="total_items",
    color="product_category",
    size="total_sales",
    hover_name="product_subcategory",
    log_y=True,
    log_x=True,
    size_max=50,
    title="Price vs. Volume Analysis (Size = Total Sales)",
)
fig.update_layout(
    xaxis_title="Average Price per Item (log scale)",
    yaxis_title="Total Items Sold (log scale)",
)

static_path = os.path.join(output_dir, "price_vs_sales_volume.png")
fig.write_image(static_path)
print(f"Static scatter chart saved to {static_path}")

# customer analysis vis

# 7. Customer Engagement by Subcategory
fig = px.bar(
    subcategory_data.sort_values("total_customers", ascending=False),
    x="product_subcategory",
    y=["total_customers", "total_orders"],
    barmode="group",
    color_discrete_sequence=["#636EFA", "#EF553B"],
    title="Customer Engagement by Subcategory",
    labels={
        "value": "Count",
        "product_subcategory": "Product Subcategory",
        "variable": "Metric",
    },
)
fig.update_layout(xaxis={"categoryorder": "total descending"})
fig.update_xaxes(tickangle=45)

static_path = os.path.join(output_dir, "cust_sub_cat.png")
fig.write_image(static_path)
print(f"Static bar chart saved to {static_path}")

# 8. Average Sales per Order by Subcategory
fig = px.bar(
    subcategory_data.sort_values("avg_sales_per_order", ascending=False),
    x="product_subcategory",
    y="avg_sales_per_order",
    color="product_category",
    title="Average Sales per Order by Subcategory",
    labels={
        "avg_sales_per_order": "Avg Sales per Order ($)",
        "product_subcategory": "Product Subcategory",
    },
)
fig.update_layout(xaxis={"categoryorder": "total descending"})
fig.update_xaxes(tickangle=45)
static_path = os.path.join(output_dir, "avgsales_per_order.png")
fig.write_image(static_path)
print(f"Static bar chart saved to {static_path}")
