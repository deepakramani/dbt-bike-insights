import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
import os
import warnings

warnings.filterwarnings("ignore")

output_dir = "output/ltv/"
os.makedirs(output_dir, exist_ok=True)

# Load LTV data
ltv_quintile_data = pd.read_csv(
    "~/Desktop/educ/dbt-bike-insight/docs/life_time_value.csv"
)

# 1. LTV Distribution Analysis - Quintile Bar Chart
fig1 = px.bar(
    ltv_quintile_data,
    x="ltv_quintile",
    y="avg_ltv",
    color="ltv_quintile",
    labels={
        "ltv_quintile": "Customer Value Quintile (1=Lowest, 5=Highest)",
        "avg_ltv": "Average Lifetime Value ($)",
    },
    title="Customer Lifetime Value by Quintile",
    text=ltv_quintile_data["avg_ltv"].round(0).astype(int),
)
fig1.update_traces(texttemplate="$%{text}", textposition="outside")
fig1.update_layout(showlegend=False)
fig1.show()
fig1.write_image(f"{output_dir}ltv_quintile_bar.png")

# 2. LTV Range Analysis - Box Plot Simulation
fig2 = go.Figure()
for q in ltv_quintile_data["ltv_quintile"]:
    min_val = ltv_quintile_data.loc[
        ltv_quintile_data["ltv_quintile"] == q, "min_ltv"
    ].values[0]
    max_val = ltv_quintile_data.loc[
        ltv_quintile_data["ltv_quintile"] == q, "max_ltv"
    ].values[0]
    avg_val = ltv_quintile_data.loc[
        ltv_quintile_data["ltv_quintile"] == q, "avg_ltv"
    ].values[0]
    q1 = min_val + (avg_val - min_val) * 0.4
    q3 = avg_val + (max_val - avg_val) * 0.4
    fig2.add_trace(
        go.Box(
            y=[min_val, q1, avg_val, q3, max_val],
            name=f"Q{q}",
            boxpoints=False,
            marker_color=px.colors.qualitative.Bold[q - 1],
        )
    )
fig2.update_layout(
    title="Lifetime Value Range by Customer Quintile",
    yaxis_title="Customer Lifetime Value ($)",
    xaxis_title="Customer Quintile (1=Lowest, 5=Highest)",
)
fig2.show()
fig2.write_image(f"{output_dir}ltv_range_box.png")

# 3. LTV vs Orders Relationship
fig3 = px.scatter(
    ltv_quintile_data,
    x="avg_orders",
    y="avg_ltv",
    size="customer_count",
    color="ltv_quintile",
    text="ltv_quintile",
    size_max=60,
    title="Relationship Between Average Orders and Lifetime Value",
    labels={
        "avg_orders": "Average Number of Orders",
        "avg_ltv": "Average Lifetime Value ($)",
    },
)
fig3.update_traces(textposition="top center")
fig3.update_layout(showlegend=False)
fig3.show()
fig3.write_image(f"{output_dir}ltv_vs_orders_scatter.png")

# 4. Customer Annual Value
fig4 = px.bar(
    ltv_quintile_data,
    x="ltv_quintile",
    y=["avg_ltv", "avg_annual_ltv"],
    barmode="group",
    title="Total LTV vs. Annual LTV by Customer Quintile",
    labels={
        "value": "Value ($)",
        "ltv_quintile": "Customer Quintile",
        "variable": "Metric",
    },
    color_discrete_sequence=["#636EFA", "#EF553B"],
)
fig4.update_layout(
    xaxis={"categoryorder": "total ascending"},
    legend_title_text="Metric",
    legend=dict(
        orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1, title=""
    ),
)
fig4.update_traces(hovertemplate="$%{y:.2f}")
fig4.show()
fig4.write_image(f"{output_dir}total_vs_annual_ltv.png")

print("LTV Analysis visualizations completed and saved!")
