# Workstream 2_Settlement Growth

Settlement Growth Prediction in Durban (2019–2028)

Project Overview

This project models and predicts settlement growth in Durban, South Africa from 2019 to 2028 using the MOLUSCE plugin in QGIS. We analyzed observed changes between 2019 and 2025 and projected settlement expansion for 2025–2028, presenting results as heatmaps for clear visualization. The study highlights how the 2022 Durban floods disrupted settlement expansion, and how projected growth in the coming years is expected to cluster in areas such as Clermont and along major transport corridors. 

Tools & Libraries
•	QGIS 3.30+
•	MOLUSCE (Modules for Land Use Change Evaluation) plugin
•	SAGA NextGen (for raster filtering/smoothing)
•	Carto Positron basemap

 Data Inputs
•	Settlement Maps (binary rasters: 2019, 2025).
•	Spatial Drivers: Slope (derived from DEM), Distance to water, Distance to road.     Constraints mask tested but excluded due to high correlation.
•	CRS: WGS 84 / UTM Zone 36S

Workflow (Step-by-Step)

1.	Data Preparation
•	Clean classified settlement rasters for 2019 and 2025.
•	Derived slope, distance to road and distance-to-water rasters.

2.	Change Detection
•	Ran change detection in MOLUSCE (2019 → 2025).
•	Found sparse, scattered growth due to the 2022 flood disruption.

3.	Model Training (MOLUSCE)
•	Used Artificial Neural Network (ANN) as the learning algorithm.
•	Dependent variable: settlement change map.
•	Independent variables: slope, distance to road & distance to water.

4.	Prediction (2025 → 2028)
•	Used trained ANN to simulate growth over 3 years.
•	Generated prediction raster for 2028.

5.	Visualization
•	Applied Gaussian filter for smoothing.
•	Styled as heatmaps.
     
 Results
    1. Observed Growth (2019 → 2025) Limited, scattered growth.Expansion disrupted by the 2022 Durban floods.
    2. Forecasted Growth (2025 → 2028) Strong clustering around Clermont and along transport corridors. Indicates accelerated rebound post-flood.
    3. Full Footprint by 2028 umulative projection of settlements visible on the ground by 2028. Shows significant spread, highlighting pressure on       land and infrastructure.
 
 Model Validation
•	Model validation was carried out in MOLUSCE using Kappa, ROC, and accuracy statistics.
•	Detailed numbers are included in the Results Document.


Maps Produced
•	Heatmap of Observed Growth (2019–2025)
•	Heatmap of Forecasted Growth (2025–2028)
•	Projected Settlement Footprint (2028)


