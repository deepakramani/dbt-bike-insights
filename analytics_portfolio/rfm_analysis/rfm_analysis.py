import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import os
import warnings

warnings.filterwarnings("ignore")

output_dir = "output/rfm/"
os.makedirs(output_dir, exist_ok=True)

# Load RFM data
rfm_data = pd.read_csv("~/Desktop/educ/dbt-bike-insight/docs/RFM_analysis.csv")

# 1. RFM Segment Analysis - Distribution of RFM Scores
r_counts = rfm_data["r_score"].value_counts().sort_index().reset_index()
r_counts.columns = ["R Score", "Count"]
f_counts = rfm_data["f_score"].value_counts().sort_index().reset_index()
f_counts.columns = ["F Score", "Count"]
m_counts = rfm_data["m_score"].value_counts().sort_index().reset_index()
m_counts.columns = ["M Score", "Count"]

fig1 = make_subplots(
    rows=1,
    cols=3,
    subplot_titles=("Recency Score", "Frequency Score", "Monetary Score"),
)
fig1.add_trace(
    go.Bar(
        x=r_counts["R Score"],
        y=r_counts["Count"],
        name="Recency",
        marker_color="#1f77b4",
    ),
    row=1,
    col=1,
)
fig1.add_trace(
    go.Bar(
        x=f_counts["F Score"],
        y=f_counts["Count"],
        name="Frequency",
        marker_color="#ff7f0e",
    ),
    row=1,
    col=2,
)
fig1.add_trace(
    go.Bar(
        x=m_counts["M Score"],
        y=m_counts["Count"],
        name="Monetary",
        marker_color="#2ca02c",
    ),
    row=1,
    col=3,
)
fig1.update_layout(title="Distribution of RFM Scores", showlegend=False, height=400)
for i in range(1, 4):
    fig1.update_yaxes(title_text="Number of Customers", row=1, col=i)
    fig1.update_xaxes(title_text="Score (1=Worst, 5=Best)", row=1, col=i)
fig1.write_image(f"{output_dir}rfm_score_distribution.png")

# 2. 3D RFM Visualization
fig2 = px.scatter_3d(
    rfm_data,
    x="r_score",
    y="f_score",
    z="m_score",
    color="monetary",
    size="frequency",
    opacity=0.7,
    title="3D RFM Customer Segmentation",
    labels={
        "r_score": "Recency Score",
        "f_score": "Frequency Score",
        "m_score": "Monetary Score",
        "monetary": "Customer Value ($)",
    },
    color_continuous_scale=px.colors.sequential.Viridis,
)
fig2.update_layout(
    scene=dict(
        xaxis_title="Recency Score (5=Recent)",
        yaxis_title="Frequency Score (5=Frequent)",
        zaxis_title="Monetary Score (5=High Value)",
    )
)
# fig2.show()
fig2.write_html(f"{output_dir}rfm_3d_scatter.html")


heatmap_data = (
    rfm_data.groupby(["r_score", "f_score"]).agg({"monetary": "mean"}).reset_index()
)
heatmap_pivot = heatmap_data.pivot(
    index="r_score", columns="f_score", values="monetary"
).fillna(0)

fig_alt = px.imshow(
    heatmap_pivot,
    labels=dict(x="Frequency Score", y="Recency Score", color="Avg Monetary Value ($)"),
    title="RFM Heatmap (Recency vs Frequency)",
    color_continuous_scale="fall",
    text_auto=True,
)
fig_alt.update_layout(
    xaxis_title="Frequency Score (1=Low, 5=High)",
    yaxis_title="Recency Score (1=Old, 5=Recent)",
)
fig_alt.update_traces(texttemplate="$%{z:.0f}")
fig_alt.write_image(f"{output_dir}rfm_heatmap.png")


print("RFM Analysis visualizations completed and saved!")
