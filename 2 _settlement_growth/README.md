# Workstream 2_Settlement Growth

## Overview
- This project models and predicts settlement growth in Durban, South Africa from 2019 to 2028 using the MOLUSCE plugin in QGIS. 
- We analyzed observed changes between 2019 and 2025 and projected settlement expansion for 2025–2028, presenting results as heatmaps for clear visualization.
- The study highlights how the 2022 Durban floods disrupted informal settlement expansion, and how projected growth in the coming years is expected to cluster in areas such as Clermont and along major transportation corridors.

## Tools & Libraries
- [QGIS] 3.30+ (https://qgis.org/)
- [Python](https://www.python.org/)
- Urban Change Detection script on DEA
- [MOLUSCE plugin for QGIS](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://plugins.qgis.org/plugins/molusce/) (Modules for Land Use Change Evaluation)
- [SAGA NextGen plugin for QGIS](https://www.google.com/url?sa=t&source=web&rct=j&opi=89978449&url=https://plugins.qgis.org/plugins/processing_saga_nextgen/) (for raster filtering/smoothing)
- Carto Positron basemap

## Data Inputs
- Settlement Maps (binary rasters: 2019, 2025).
- Spatial Drivers: Slope (derived from DEM), Distance to water, Distance to road.   Constraints mask tested but excluded due to high correlation.
- CRS: WGS 84 / UTM Zone 36S

## Workflow (Step-by-Step)
1.	Data Preparation
- Clean classified settlement rasters for 2019 and 2025.
- Derived slope, distance to road and distance-to-water rasters.
2.	Change Detection
- Ran change detection in MOLUSCE (2019 → 2025).
- Found sparse, scattered growth due to the 2022 flood disruption.
3.	Model Training (MOLUSCE)
- Used Artificial Neural Network (ANN) as the learning algorithm.
- Dependent variable: settlement change map.
- Independent variables: slope, distance to road & distance to water.
4.	Prediction (2025 → 2028)
- Used trained ANN to simulate growth over 3 years.
- Generated prediction raster for 2028.
5.	Visualization
- Applied Gaussian filter for smoothing.
- Styled as heatmaps.
     
## Results
1. Observed Growth (2019 → 2025) Limited, scattered growth.Expansion disrupted by the 2022 Durban floods.
2. Forecasted Growth (2025 → 2028) Strong clustering around Clermont and along transport corridors. Indicates accelerated rebound post-flood.
3. Full Footprint by 2028 cumulative projection of settlements visible on the ground by 2028. Shows significant spread, highlighting pressure on land and infrastructure.
4. Maps Produced
    - [Heatmap of Observed Growth (2019–2025) vs Heatmap of Forecasted Growth (2025–2028)](settlement_growth_story.png)
    - [Projected Settlement Footprint by 2028](settlement_growth_projected_footprint_by_2028.png)

## Model Validation
- Model validation was carried out in MOLUSCE using Kappa, ROC, and accuracy statistics.
- Detailed numbers are included in [Settlement Growth Model Validation Results.pdf](settlement_growth_model_validation_results.pdf).

## License
Copyright 2025 Team MapleByte 

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
