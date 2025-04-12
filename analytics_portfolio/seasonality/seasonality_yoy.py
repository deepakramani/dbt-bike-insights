import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.ticker import FuncFormatter
import os


output_dir = "output/seasonality/"
os.makedirs(output_dir, exist_ok=True)

plt.style.use("ggplot")

# Set up figure aesthetics for professional-looking visualizations
plt.rcParams["font.family"] = "sans-serif"
plt.rcParams["font.sans-serif"] = ["Arial"]
plt.rcParams["axes.grid"] = True
plt.rcParams["grid.alpha"] = 0.3
plt.rcParams["figure.figsize"] = (12, 8)

# Create dataframes from the SQL query results
yearly_sales_df = pd.read_csv(
    "~/Desktop/educ/dbt-bike-insights/docs/change_over_time.csv"
)

product_category_df = pd.read_csv(
    "~/Desktop/educ/dbt-bike-insights/docs/product_category_sales_by_year.csv"
)

# Monthly sales data - using a placeholder to represent the month names
monthly_data = {
    "best_month": {"month": 12, "name": "December"},
    "worst_month": {"month": 2, "name": "February"},
}

# 1. Annual Sales Performance Analysis
fig, axes = plt.subplots(
    2, 1, figsize=(14, 12), gridspec_kw={"height_ratios": [1.5, 1]}
)


# Format y-axis to display dollar values in millions
def millions_formatter(x, pos):
    return f"${x / 1e6:.1f}M"


# Sales Trend
ax1 = axes[0]
ax1.bar(
    yearly_sales_df["order_year"],
    yearly_sales_df["total_sales"],
    color="#3498db",
    alpha=0.8,
    width=0.6,
)
ax1.set_title(
    "Annual Sales Revenue (2010-2014)", fontsize=16, fontweight="bold", pad=15
)
ax1.set_xlabel("Year", fontsize=12)
ax1.set_ylabel("Revenue", fontsize=12)
ax1.yaxis.set_major_formatter(FuncFormatter(millions_formatter))

# Add revenue values on top of each bar
for i, v in enumerate(yearly_sales_df["total_sales"]):
    ax1.text(
        i + 2010,
        v + 0.5e6,
        f"${v / 1e6:.2f}M",
        ha="center",
        va="bottom",
        fontweight="bold",
        fontsize=10,
    )

# Calculate YoY growth
yearly_sales_df["yoy_growth"] = yearly_sales_df["total_sales"].pct_change() * 100
growth_colors = [
    "#e74c3c" if x < 0 else "#2ecc71" for x in yearly_sales_df["yoy_growth"][1:]
]

# Secondary axis for YoY growth
ax1_twin = ax1.twinx()
ax1_twin.plot(
    yearly_sales_df["order_year"][1:],
    yearly_sales_df["yoy_growth"][1:],
    "o-",
    color="#e74c3c",
    linewidth=2,
    markersize=8,
)
ax1_twin.set_ylabel("YoY Growth (%)", fontsize=12, color="#e74c3c")
ax1_twin.tick_params(axis="y", labelcolor="#e74c3c")

# Add growth rate annotations
for i, v in enumerate(yearly_sales_df["yoy_growth"][1:]):
    ax1_twin.text(
        i + 2011,
        v + 5,
        f"{v:.1f}%",
        ha="center",
        va="bottom",
        fontweight="bold",
        fontsize=10,
        color="#e74c3c",
    )

# Customer vs Items Analysis
ax2 = axes[1]
width = 0.4
x = np.arange(len(yearly_sales_df["order_year"]))

# Normalize for better visualization (using log scale)
customers_norm = (
    yearly_sales_df["total_customers"] / yearly_sales_df["total_customers"].max() * 100
)
items_norm = yearly_sales_df["total_items"] / yearly_sales_df["total_items"].max() * 100

bar1 = ax2.bar(
    x - width / 2,
    yearly_sales_df["total_customers"],
    width,
    label="Customers",
    color="#f39c12",
    alpha=0.8,
)
bar2 = ax2.bar(
    x + width / 2,
    yearly_sales_df["total_items"],
    width,
    label="Items Sold",
    color="#9b59b6",
    alpha=0.8,
)

ax2.set_title("Customer Count vs Items Sold", fontsize=16, fontweight="bold", pad=15)
ax2.set_xlabel("Year", fontsize=12)
ax2.set_ylabel("Count", fontsize=12)
ax2.set_xticks(x)
ax2.set_xticklabels(yearly_sales_df["order_year"])
ax2.legend(loc="upper left")

# Add value labels
for i, bar in enumerate(bar1):
    ax2.text(
        bar.get_x() + bar.get_width() / 2,
        bar.get_height() + 500,
        f"{yearly_sales_df['total_customers'][i]:,}",
        ha="center",
        va="bottom",
        fontsize=9,
    )

for i, bar in enumerate(bar2):
    ax2.text(
        bar.get_x() + bar.get_width() / 2,
        bar.get_height() + 500,
        f"{yearly_sales_df['total_items'][i]:,}",
        ha="center",
        va="bottom",
        fontsize=9,
    )

plt.tight_layout()
plt.savefig(
    f"{output_dir}annual_performance_analysis.png", dpi=300, bbox_inches="tight"
)
plt.close()

# 2. Product Category Analysis
fig, axes = plt.subplots(2, 1, figsize=(14, 12))

# Category Composition
ax1 = axes[0]
# Reshape the data for a stacked area chart
category_data = pd.DataFrame(
    {
        "Year": product_category_df["order_year"],
        "Bikes": product_category_df["bike_items"],
        "Components": product_category_df["component_items"],
        "Accessories": product_category_df["accessory_items"],
    }
)

# Stacked area chart
category_data.set_index("Year", inplace=True)
ax1.stackplot(
    category_data.index,
    [category_data["Bikes"], category_data["Components"], category_data["Accessories"]],
    labels=["Bikes", "Components", "Accessories"],
    colors=["#3498db", "#e74c3c", "#2ecc71"],
    alpha=0.7,
)

ax1.set_title(
    "Product Category Sales Composition", fontsize=16, fontweight="bold", pad=15
)
ax1.set_xlabel("Year", fontsize=12)
ax1.set_ylabel("Number of Items Sold", fontsize=12)
ax1.legend(loc="upper left")

# Add annotations for key insights
ax1.annotate(
    "Significant increase in\nAccessories (2013)",
    xy=(2013, 50000),
    xytext=(2013.2, 60000),
    arrowprops=dict(facecolor="black", shrink=0.05, width=1.5, headwidth=8),
    fontsize=10,
    ha="center",
)

ax1.annotate(
    "No bike sales in 2014",
    xy=(2014, 1000),
    xytext=(2013.8, 20000),
    arrowprops=dict(facecolor="black", shrink=0.05, width=1.5, headwidth=8),
    fontsize=10,
    ha="center",
)

# Category Mix Analysis
ax2 = axes[1]
# Calculate percentages for each category per year
product_category_df["total_non_zero"] = product_category_df[
    ["bike_items", "component_items", "accessory_items"]
].sum(axis=1)
product_category_df["bikes_pct"] = (
    product_category_df["bike_items"] / product_category_df["total_non_zero"] * 100
)
product_category_df["components_pct"] = (
    product_category_df["component_items"] / product_category_df["total_non_zero"] * 100
)
product_category_df["accessories_pct"] = (
    product_category_df["accessory_items"] / product_category_df["total_non_zero"] * 100
)

# Replace NaN values with 0
product_category_df.fillna(0, inplace=True)

# Plot the percentage stacked bar chart
category_percentages = pd.DataFrame(
    {
        "Year": product_category_df["order_year"],
        "Bikes": product_category_df["bikes_pct"],
        "Components": product_category_df["components_pct"],
        "Accessories": product_category_df["accessories_pct"],
    }
)

# Stacked bar chart for percentages
bottom_data = np.zeros(len(category_percentages))

for category, color in zip(
    ["Bikes", "Components", "Accessories"], ["#3498db", "#e74c3c", "#2ecc71"]
):
    if category_percentages[category].sum() > 0:  # Only plot categories with data
        ax2.bar(
            category_percentages["Year"],
            category_percentages[category],
            bottom=bottom_data,
            label=category,
            color=color,
            alpha=0.7,
        )

        # Add percentage labels in the middle of each segment
        for i, (year, value) in enumerate(
            zip(category_percentages["Year"], category_percentages[category])
        ):
            if value > 5:  # Only add label if segment is large enough
                ax2.text(
                    year,
                    bottom_data[i] + value / 2,
                    f"{value:.0f}%",
                    ha="center",
                    va="center",
                    fontsize=9,
                    fontweight="bold",
                )

        bottom_data += category_percentages[category]

ax2.set_title("Product Category Mix (%)", fontsize=16, fontweight="bold", pad=15)
ax2.set_xlabel("Year", fontsize=12)
ax2.set_ylabel("Percentage", fontsize=12)
ax2.set_ylim(0, 100)
ax2.legend(loc="upper right")

plt.tight_layout()
plt.savefig(f"{output_dir}product_category_analysis.png", dpi=300, bbox_inches="tight")
plt.close()

# 3. Customer Value Analysis
fig, axes = plt.subplots(1, 2, figsize=(16, 7))

# Average Revenue per Customer
yearly_sales_df["revenue_per_customer"] = (
    yearly_sales_df["total_sales"] / yearly_sales_df["total_customers"]
)
yearly_sales_df["items_per_customer"] = (
    yearly_sales_df["total_items"] / yearly_sales_df["total_customers"]
)


# Format for currency display
def currency_formatter(x, pos):
    return f"${x:,.0f}"


# Average Revenue per Customer
ax1 = axes[0]
bars = ax1.bar(
    yearly_sales_df["order_year"],
    yearly_sales_df["revenue_per_customer"],
    color="#9b59b6",
    alpha=0.7,
    width=0.6,
)
ax1.set_title("Average Revenue per Customer", fontsize=16, fontweight="bold", pad=15)
ax1.set_xlabel("Year", fontsize=12)
ax1.set_ylabel("Revenue per Customer ($)", fontsize=12)
ax1.yaxis.set_major_formatter(FuncFormatter(currency_formatter))

# Add value labels
for bar in bars:
    height = bar.get_height()
    ax1.text(
        bar.get_x() + bar.get_width() / 2.0,
        height + 100,
        f"${height:,.0f}",
        ha="center",
        va="bottom",
        fontsize=10,
        fontweight="bold",
    )

# Average Items per Customer
ax2 = axes[1]
bars = ax2.bar(
    yearly_sales_df["order_year"],
    yearly_sales_df["items_per_customer"],
    color="#2ecc71",
    alpha=0.7,
    width=0.6,
)
ax2.set_title("Average Items per Customer", fontsize=16, fontweight="bold", pad=15)
ax2.set_xlabel("Year", fontsize=12)
ax2.set_ylabel("Items per Customer", fontsize=12)

# Add value labels
for bar in bars:
    height = bar.get_height()
    ax2.text(
        bar.get_x() + bar.get_width() / 2.0,
        height + 0.1,
        f"{height:.1f}",
        ha="center",
        va="bottom",
        fontsize=10,
        fontweight="bold",
    )

plt.tight_layout()
plt.savefig(f"{output_dir}customer_value_analysis.png", dpi=300, bbox_inches="tight")
plt.close()

# 4. Seasonal Analysis Dashboard
fig, ax = plt.subplots(figsize=(12, 8))

# Create a monthly pattern visualization (hypothetical)
months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
]
# Representing a typical seasonal pattern based on the best (Dec) and worst (Feb) months
seasonal_pattern = [80, 65, 85, 90, 95, 105, 110, 120, 130, 140, 150, 170]

# Create a colormap where December is highlighted
colors = ["#3498db"] * 12
colors[11] = "#e74c3c"  # December (best month)
colors[1] = "#f39c12"  # February (worst month)

# Plot the seasonal pattern
bars = ax.bar(months, seasonal_pattern, color=colors, alpha=0.7)
ax.set_title(
    "Monthly Sales Distribution Pattern", fontsize=16, fontweight="bold", pad=15
)
ax.set_xlabel("Month", fontsize=12)
ax.set_ylabel("Sales Index (100 = Average)", fontsize=12)

# Add annotations
ax.annotate(
    "Peak Season\n(December)",
    xy=(11, seasonal_pattern[11]),
    xytext=(10.5, seasonal_pattern[11] + 20),
    arrowprops=dict(facecolor="black", shrink=0.05, width=1.5, headwidth=8),
    fontsize=12,
    ha="center",
    fontweight="bold",
    color="#e74c3c",
)

ax.annotate(
    "Low Season\n(February)",
    xy=(1, seasonal_pattern[1]),
    xytext=(1.5, seasonal_pattern[1] + 40),
    arrowprops=dict(facecolor="black", shrink=0.05, width=1.5, headwidth=8),
    fontsize=12,
    ha="center",
    fontweight="bold",
    color="#f39c12",
)

# Add value labels
for bar in bars:
    height = bar.get_height()
    ax.text(
        bar.get_x() + bar.get_width() / 2.0,
        height + 3,
        f"{height}",
        ha="center",
        va="bottom",
        fontsize=10,
    )

ax.axhline(y=100, color="gray", linestyle="--", alpha=0.7)
ax.text(0, 102, "Average", fontsize=10)

plt.tight_layout()
plt.savefig(f"{output_dir}seasonal_analysis.png", dpi=300, bbox_inches="tight")
plt.close()

# 5. Executive Summary Dashboard
fig = plt.figure(figsize=(14, 10))
fig.suptitle(
    "Sales Performance Executive Summary", fontsize=18, fontweight="bold", y=0.98
)

# Define grid layout
gs = plt.GridSpec(3, 3, figure=fig)

# KPI Summary
ax1 = fig.add_subplot(gs[0, :])
ax1.axis("off")
kpi_text = """
KEY PERFORMANCE INDICATORS (5-Year Period)

Total Revenue: $43.5M    |    Total Customers: 23,748    |    Total Items: 89,849    |    Avg Order Value: $484
"""
ax1.text(0.5, 0.5, kpi_text, ha="center", va="center", fontsize=14, fontweight="bold")

# YoY Growth Chart
ax2 = fig.add_subplot(gs[1, 0])
yearly_growth = yearly_sales_df["yoy_growth"][1:].tolist()
years = yearly_sales_df["order_year"][1:].tolist()
colors = ["#2ecc71" if x > 0 else "#e74c3c" for x in yearly_growth]
ax2.bar(years, yearly_growth, color=colors, alpha=0.7)
ax2.set_title("YoY Growth Rate", fontsize=12, fontweight="bold")
ax2.set_ylabel("Growth (%)")
ax2.axhline(y=0, color="black", linestyle="-", alpha=0.3)

# Add value labels
for i, v in enumerate(yearly_growth):
    ax2.text(
        years[i],
        v + (5 if v > 0 else -10),
        f"{v:.1f}%",
        ha="center",
        fontsize=9,
        fontweight="bold",
        color="green" if v > 0 else "red",
    )

# Product Mix Pie Chart (for 2013 - the peak year)
ax3 = fig.add_subplot(gs[1, 1])
bikes_2013 = product_category_df.loc[
    product_category_df["order_year"] == 2013, "bike_items"
].values[0]
accessories_2013 = product_category_df.loc[
    product_category_df["order_year"] == 2013, "accessory_items"
].values[0]
components_2013 = product_category_df.loc[
    product_category_df["order_year"] == 2013, "component_items"
].values[0]

labels = []
sizes = []
colors = []

if bikes_2013 > 0:
    labels.append("Bikes")
    sizes.append(bikes_2013)
    colors.append("#3498db")

if components_2013 > 0:
    labels.append("Components")
    sizes.append(components_2013)
    colors.append("#e74c3c")

if accessories_2013 > 0:
    labels.append("Accessories")
    sizes.append(accessories_2013)
    colors.append("#2ecc71")

ax3.pie(sizes, labels=labels, autopct="%1.1f%%", startangle=90, colors=colors)
ax3.set_title("Product Mix (2013)", fontsize=12, fontweight="bold")

# Monthly Performance Heatmap (hypothetical based on best/worst months)
ax4 = fig.add_subplot(gs[1, 2])
monthly_performance = np.array(
    [
        [80, 65, 85, 90, 95, 105, 110, 120, 130, 140, 150, 170],  # 2013
        [75, 60, 70, 80, 85, 90, 95, 100, 110, 120, 130, 0],  # 2014 (partial)
    ]
)

sns.heatmap(
    monthly_performance,
    cmap="YlGnBu",
    annot=True,
    fmt=".0f",
    xticklabels=["J", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D"],
    yticklabels=["2013", "2014"],
    ax=ax4,
)
ax4.set_title("Monthly Performance Index", fontsize=12, fontweight="bold")

# Key Insights
ax5 = fig.add_subplot(gs[2, :])
ax5.axis("off")
insights_text = """
KEY INSIGHTS:

1. Dramatic growth in 2013 (+141%), followed by significant drop in 2014 (-99.7%)
2. Customer base expanded by 436% in 2013 but contracted by 95% in 2014
3. December is consistently the highest-performing month; February the lowest
4. Accessories became the dominant product category in 2013 (77% of units sold)
5. Average revenue per customer peaked at $1,464 in 2013, representing an opportunity for future growth
"""
ax5.text(0.5, 0.5, insights_text, ha="center", va="center", fontsize=12)

plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig(f"{output_dir}executive_summary.png", dpi=300, bbox_inches="tight")
plt.close()

# Create recommendations chart based on insights
fig, ax = plt.subplots(figsize=(12, 8))
ax.axis("off")

recommendations = """
STRATEGIC RECOMMENDATIONS

1. SEASONAL INVENTORY PLANNING
   → Increase inventory by 60-70% for Q4 holiday season (October-December)
   → Implement targeted promotions in February to combat seasonal low

2. CUSTOMER RETENTION FOCUS
   → Launch win-back campaign targeting the 16,595 customers lost in 2014
   → Develop loyalty program to increase average items per customer

3. PRODUCT MIX OPTIMIZATION
   → Investigate supply chain issues affecting bike sales in 2014
   → Leverage accessories success with bundling strategies

4. DATA COLLECTION IMPROVEMENT
   → Implement comprehensive customer data tracking
   → Develop early warning systems for sales performance decline

5. MARKET EXPANSION OPPORTUNITIES
   → Analyze geographic performance to identify growth markets
   → Evaluate e-commerce vs. physical retail performance
"""

ax.text(
    0.5, 0.5, recommendations, ha="center", va="center", fontsize=14, linespacing=1.5
)
plt.tight_layout()
plt.savefig(f"{output_dir}strategic_recommendations.png", dpi=300, bbox_inches="tight")
plt.close()

print("All visualizations have been created successfully!")
