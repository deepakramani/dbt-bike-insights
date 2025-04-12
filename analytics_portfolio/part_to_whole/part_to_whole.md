# Sales Analytics Dashboard

## Project Overview
This analytics dashboard processes data from the gold layer of our data warehouse to provide comprehensive sales analysis across product categories and subcategories. The analysis examines part-to-whole relationships, product performance, customer behavior, and product affinity to support data-driven business decisions.

## Key Insights

### Revenue Distribution
- **Bikes** drive 96% of revenue but represent only 25% of orders
- **Accessories** generate 2.64% of revenue but account for 54.52% of orders
- **Clothing** contributes 1.35% of revenue and 20.47% of orders

### Subcategory Performance
- **Road Bikes** and **Mountain Bikes** are dominant revenue generators (87% combined)
- **Tires and Tubes** drive the highest order volume (19.85%) but low revenue share (0.56%)
- **Helmets** engage the most customers after bikes

### Customer Behavior
- Higher-priced items (Bikes) have lower purchase frequency but higher transaction values
- Lower-priced items (Accessories) have higher purchase frequency and customer count
- Average transaction values range dramatically from $8 (Cleaners) to $3,598 (Mountain Bikes)

## Business Recommendations
1. Implement bundling strategies to increase accessory attachment rates with bike purchases
2. Develop premium options for high-traffic accessory categories to increase average order values
3. Optimize inventory management focusing on high-revenue subcategories
4. Create targeted cross-selling strategies based on product affinity analysis
5. Apply differential pricing strategies based on category price elasticity

## Technical Implementation
This dashboard uses:
- SQL for data extraction from the gold layer
- Python (Pandas, Matplotlib, Seaborn, Plotly) for data manipulation and visualization
- Advanced analysis techniques including part-to-whole analysis, correlation studies, and clustering

## Next Steps
- Implement basket analysis for improved product affinity insights
- Integrate time-series analysis to identify seasonal trends
- Add customer segmentation to refine marketing strategies