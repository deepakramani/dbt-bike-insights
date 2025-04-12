# Import the necessary libraries
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import networkx as nx
import os
import plotly.express as px
import plotly.graph_objects as go
from pyvis.network import Network


# Set plot style
plt.style.use("seaborn-v0_8-whitegrid")
sns.set_palette("Blues_r")

# Create a DataFrame with your query results
data = pd.read_csv("~/Desktop/educ/dbt-bike-insights/docs/product_affinity.csv")

print("Product affinity analysis data:")
print(data)
print("\n")

# Create output directory if it doesn't exist
if not os.path.exists("output/product_affinity"):
    os.makedirs("output/product_affinity/")


# ------ Visualization 1: Network Graph for Product Affinity ------
def create_network_graph(df):
    """
    Creates an interactive network graph showing product category relationships.
    Thicker edges represent stronger affinity between categories.
    """
    print("Creating network graph visualization...")

    # Create a directed graph
    G = nx.Graph()

    # Add nodes (product categories)
    unique_categories = set(df["category_1"].tolist() + df["category_2"].tolist())
    for category in unique_categories:
        G.add_node(category)

    # Add edges with weights based on affinity
    for _, row in df.iterrows():
        G.add_edge(
            row["category_1"], row["category_2"], weight=row["affinity_percentage"]
        )

    # Create an interactive network visualization
    net = Network(height="600px", width="800px", bgcolor="#ffffff", font_color="black")

    # Add nodes from networkx graph
    for node in G.nodes():
        net.add_node(node, label=node, title=node, size=30)

    # Add edges with scaling for visibility
    for source, target, attr in G.edges(data=True):
        width = attr["weight"] * 0.5  # Scale for better visibility
        tooltip = f"{source} - {target}: {attr['weight']}% of orders"
        net.add_edge(source, target, value=width, title=tooltip, color="#4285F4")

    # Configure physics for better layout
    net.barnes_hut(gravity=-80000, central_gravity=0.3, spring_length=250)

    # Save the network visualization
    output_path = "output/product_affinity/product_affinity_network.html"
    net.save_graph(output_path)
    print(f"Network graph saved to {output_path}")

    # Create a static version for non-interactive environments
    plt.figure(figsize=(10, 8))
    pos = nx.spring_layout(G, seed=42)  # Set seed for reproducibility

    # Draw the nodes
    nx.draw_networkx_nodes(G, pos, node_size=2000, node_color="lightblue", alpha=0.8)

    # Draw node labels
    nx.draw_networkx_labels(G, pos, font_size=12)

    # Draw edges with width proportional to affinity percentage
    edge_widths = [G[u][v]["weight"] * 0.2 for u, v in G.edges()]
    nx.draw_networkx_edges(G, pos, width=edge_widths, alpha=0.7, edge_color="navy")

    # Add edge labels (affinity percentages)
    edge_labels = {(u, v): f"{G[u][v]['weight']}%" for u, v in G.edges()}
    nx.draw_networkx_edge_labels(G, pos, edge_labels=edge_labels, font_size=10)

    plt.title("Product Category Affinity Network", fontsize=16)
    plt.axis("off")  # Turn off axis

    # Save the static version
    static_path = "output/product_affinity/product_affinity_network_static.png"
    plt.savefig(static_path, dpi=300, bbox_inches="tight")
    plt.close()
    print(f"Static network graph saved to {static_path}")

    return G


# Create the network graph
affinity_graph = create_network_graph(data)

# ------ Visualization 2: Bar Chart for Clear Comparison ------


def create_bar_chart(df):
    """
    Creates a bar chart showing affinity percentages between product categories.
    """
    print("\nCreating bar chart visualization...")

    # Create category pair labels for x-axis
    df["category_pair"] = df["category_1"] + " & " + df["category_2"]

    # Sort by affinity percentage
    sorted_df = df.sort_values("affinity_percentage", ascending=False)

    # Create bar chart with Plotly
    fig = px.bar(
        sorted_df,
        x="category_pair",
        y="affinity_percentage",
        color="affinity_percentage",
        color_continuous_scale="YlGnBu",
        text="affinity_percentage",
        labels={
            "category_pair": "Product Category Pair",
            "affinity_percentage": "Affinity (% of Orders)",
        },
        title="Product Category Affinity Analysis",
    )

    # Update layout for better appearance
    fig.update_layout(
        xaxis_title="Product Category Pairs",
        yaxis_title="Affinity (% of Orders)",
        yaxis_tickformat=".1f",
        yaxis_range=[0, max(df["affinity_percentage"]) * 1.1],  # Add headroom
        template="plotly_white",
    )

    # Format text labels
    fig.update_traces(texttemplate="%{text:.1f}%", textposition="outside")

    # Save as interactive HTML and static image
    plotly_path = "output/product_affinity/product_affinity_barchart.html"
    fig.write_html(plotly_path)
    print(f"Interactive bar chart saved to {plotly_path}")

    static_path = "output/product_affinity/product_affinity_barchart.png"
    fig.write_image(static_path)
    print(f"Static bar chart saved to {static_path}")

    # Create a similar visualization with matplotlib for comparison
    plt.figure(figsize=(12, 6))

    bars = plt.bar(
        sorted_df["category_pair"],
        sorted_df["affinity_percentage"],
        color=sns.color_palette("YlOrBr", len(sorted_df)),
    )

    # Add labels on top of bars
    for bar in bars:
        height = bar.get_height()
        plt.text(
            bar.get_x() + bar.get_width() / 2.0,
            height + 0.5,
            f"{height:.1f}%",
            ha="center",
            va="bottom",
        )

    plt.xlabel("Product Category Pair")
    plt.ylabel("Affinity (% of Orders)")
    plt.title("Product Category Affinity Analysis")
    plt.ylim(0, max(sorted_df["affinity_percentage"]) * 1.15)
    plt.grid(axis="y", alpha=0.3)

    # Save the matplotlib version
    mpl_path = "output/product_affinity/product_affinity_barchart_mpl.png"
    plt.savefig(mpl_path, dpi=300, bbox_inches="tight")
    plt.close()
    print(f"Matplotlib bar chart saved to {mpl_path}")

    return sorted_df


# Create bar chart visualization
sorted_data = create_bar_chart(data)

# ------ Visualization 3: Heatmap for Category Relationships ------


def create_heatmap(df):
    """
    Creates a heatmap showing relationship strengths between product categories.
    """
    print("\nCreating heatmap visualization...")

    # Prepare data for heatmap
    labels = list(set(df["category_1"].tolist() + df["category_2"].tolist()))
    n_categories = len(labels)

    # Create a matrix for the heatmap
    matrix = np.zeros((n_categories, n_categories))

    # Fill the matrix with affinity percentages
    for _, row in df.iterrows():
        i = labels.index(row["category_1"])
        j = labels.index(row["category_2"])
        matrix[i][j] = row["affinity_percentage"]
        matrix[j][i] = row["affinity_percentage"]  # Make it symmetrical

    # Create heatmap with Plotly
    fig = go.Figure(
        go.Heatmap(
            z=matrix,
            x=labels,
            y=labels,
            colorscale="YlOrBr",
            showscale=True,
            colorbar=dict(title="Affinity %"),
        )
    )

    fig.update_layout(
        title="Product Category Affinity Heatmap",
        width=700,
        height=600,
        template="plotly_white",
    )

    # Save as interactive HTML and static image
    plotly_path = "output/product_affinity/product_affinity_heatmap.html"
    fig.write_html(plotly_path)
    print(f"Interactive heatmap saved to {plotly_path}")

    static_path = "output/product_affinity/product_affinity_heatmap.png"
    fig.write_image(static_path)
    print(f"Static heatmap saved to {static_path}")

    # Create a similar visualization with seaborn for comparison
    plt.figure(figsize=(10, 8))

    # Create the heatmap with annotations
    ax = sns.heatmap(
        matrix,
        annot=True,
        fmt=".1f",
        cmap="YlOrBr",
        xticklabels=labels,
        yticklabels=labels,
        cbar_kws={"label": "Affinity %"},
    )

    plt.title("Product Category Affinity Heatmap")
    plt.tight_layout()

    # Save the seaborn version
    sns_path = "output/product_affinity/product_affinity_heatmap_sns.png"
    plt.savefig(sns_path, dpi=300, bbox_inches="tight")
    plt.close()
    print(f"Seaborn heatmap saved to {sns_path}")

    return matrix, labels


# Create heatmap visualization
affinity_matrix, category_labels = create_heatmap(data)

# ------ Business Analysis and Insights ------


def generate_business_insights(df):
    """
    Generates business insights from the affinity data.
    """
    print("\nGenerating business insights...")

    # Find the strongest pair
    strongest_pair_idx = df["affinity_percentage"].idxmax()
    strongest_pair = df.loc[strongest_pair_idx]

    # Calculate average affinity
    avg_affinity = df["affinity_percentage"].mean()

    # Generate insights
    insights = {
        "strongest_pair": f"{strongest_pair['category_1']} & {strongest_pair['category_2']}",
        "strongest_affinity": strongest_pair["affinity_percentage"],
        "average_affinity": avg_affinity,
        "key_findings": [
            f"The strongest product affinity is between {strongest_pair['category_1']} and "
            f"{strongest_pair['category_2']} at {strongest_pair['affinity_percentage']}% of orders.",
            f"On average, product categories show {avg_affinity:.2f}% affinity across orders.",
            "All three main product categories (Accessories, Bikes, Clothing) show significant "
            "cross-purchase behavior, suggesting opportunities for strategic merchandising.",
            "The relationship between Accessories and Bikes is more than twice as strong as "
            "the relationship between Bikes and Clothing, indicating where cross-selling "
            "efforts may be most effective.",
        ],
        "business_recommendations": [
            "Store Layout: Position accessories displays near bike showcases to capitalize on "
            "the strong natural affinity between these categories.",
            "Bundled Promotions: Create promotional bundles of bikes with popular accessories "
            "to increase average order value.",
            "Online Recommendations: Implement 'Frequently Bought Together' suggestions based "
            "on these affinity patterns in the e-commerce platform.",
            "Sales Training: Train staff to suggest clothing items during accessory purchases, "
            "as this shows a stronger relationship than Bikes-Clothing.",
        ],
    }

    # Print insights to console
    print("\n----- BUSINESS INSIGHTS -----")
    print(
        f"Strongest Category Pair: {insights['strongest_pair']} ({insights['strongest_affinity']}%)"
    )
    print(f"Average Category Affinity: {insights['average_affinity']:.2f}%")

    print("\nKey Findings:")
    for i, finding in enumerate(insights["key_findings"], 1):
        print(f"  {i}. {finding}")

    print("\nBusiness Recommendations:")
    for i, recommendation in enumerate(insights["business_recommendations"], 1):
        print(f"  {i}. {recommendation}")

    # Save insights to text file
    insights_path = "output/product_affinity/product_affinity_insights.txt"
    with open(insights_path, "w") as f:
        f.write("PRODUCT AFFINITY ANALYSIS - BUSINESS INSIGHTS\n")
        f.write("===========================================\n\n")

        f.write(
            f"Strongest Category Pair: {insights['strongest_pair']} ({insights['strongest_affinity']}%)\n"
        )
        f.write(f"Average Category Affinity: {insights['average_affinity']:.2f}%\n\n")

        f.write("Key Findings:\n")
        for i, finding in enumerate(insights["key_findings"], 1):
            f.write(f"  {i}. {finding}\n")

        f.write("\nBusiness Recommendations:\n")
        for i, recommendation in enumerate(insights["business_recommendations"], 1):
            f.write(f"  {i}. {recommendation}\n")

    print(f"\nInsights saved to {insights_path}")

    return insights


# Generate business insights
business_insights = generate_business_insights(data)

print(
    "\nProduct affinity analysis complete! All visualizations and insights have been saved to the 'output' directory."
)
