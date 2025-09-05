---
title: Stream 3 Flood Risk Prediction - Results
description: Flood risk prediction results
duration: 5min
date: 2025-09-02
---

## Workstream Goal
Risk Classification – Overlay forecasts with flood hazard maps using imagery and algorithms from [Digital Earth Africa](https://digitalearthafrica.org/en_za/).

## Results
- For flood mapping we've broken the task into two components;
    1. Current flood and short-term flood extents
    2. Longer term floodBoth scenarios are mostly hypothetical.
- In Scenario 1, we combine satellite data and HAND model to estimate flood boundaries. Satellite data was used to identify water. The image used is from 2022-04-14, using LandSat8 and computing MNDWI. 
- This was then thresholded to estimate water and non-water. From the 'water' we then analyzed it with the Height Above Nearest Drainage (HAND) dataset, built from the Copernicus Glo 30 DEM. 
- The intersection of the MNDWI and the associated HAND values was explored and statistics of those HAND values were recorded. 
- We combined this HAND and MNDWI to be a 'current' flood scenario. 
- We then added an artificial adjustment to estimate short-term potential flood. e.g. in the next 24hrs how might the water level change.
- We then explored vector data from OSM, streets, emergency facilities (hospital, police, firestations, etc.) parks in combination with the flood extents to estimate where probable evacuation points could be for citizens in/near flood zones.*for the current and short-term future flood scenarios, using near-by river gauges, synthetic rating curves or manual estimates could aid in creating a more realistic extent map.
- In Scenario 2, we made use of the HAND Model again, setting differnt thresholds for potential future flood extents. These again are hypothetical, but could represent changing flood zones due to climate change, increased urbanization, etc. This is then overlaid by the urban pixels identified in task1, and the estimated growth from task 2.
- Flood extents prediction map:
 ![Flood Extents Map](/flood_extents_layer_map.png)
- Flood risk prediction map (extents with current and potential future settlement overlay):
 ![Flood Risk Map](/flood_risk_map.png)
- Below we have manually added callouts to make it easier to spot areas that could be potential flood risks under current and future settlement growth scenarios.
 ![Flood Risk Map with callout sections](/flood_risk_map_with_callout_areas.png)
 
## Running the Notebook
To run the *FloodMapping.ipynb* Jupyter notebook in *"\3_flood_risk\src\"* folder, you will need:
1. A Jupyter notebook server such as Digital Earth Africa
2. geojson of your study area (preferably in WGS84). One place to easily create one is from [GeoJson.io](https://geojson.io/) from MapBox. 
3. config.yaml file. update it to the file paths/parameters of your choosing. (existing config file in config folder)
4. GeoTIF: urban settlements present day and for future scenario
5. GeoTIF of MWDWI

## Related reading
- View the [Flood Risk Hackathon Activity Log](/posts/3/flood-risk-log).