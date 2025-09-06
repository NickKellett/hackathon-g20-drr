---
title: Stream 3 Flood Risk Prediction - Results
description: Flood risk prediction results

date: 2025-09-05
---

## Workstream Goal
Risk Classification – Overlay forecasts with flood hazard maps using imagery and algorithms from [Digital Earth Africa](https://digitalearthafrica.org/en_za/).

## Flood Mapping Approach
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

## Running the Notebook
To run the *FloodMapping.ipynb* Jupyter notebook in *"\3_flood_risk\src\"* folder, you will need:
1. A Jupyter notebook server such as Digital Earth Africa
2. geojson of your study area (preferably in WGS84). One place to easily create one is from [GeoJson.io](https://geojson.io/) from MapBox. 
3. config.yaml file. update it to the file paths/parameters of your choosing. (existing config file in config folder)
4. GeoTIF: urban settlements present day and for future scenario
5. GeoTIF of MWDWI

We summarize the notebook steps below:

## Get Digital Elevation Data
- The dtm.py script in the dtm folder extracts a Digital Elevation Model (DEM) for a specified area using the Copernicus GLO-30 dataset. It:
    - Loads a project boundary from a GeoJSON file.
    - Connects to an Open Data Cube (ODC) instance.
    - Loads the DEM data for the area of interest at ~30m resolution.
    - Masks the DEM to the project boundary.
    - Saves the clipped DEM as a GeoTIFF file.
    - Uses libraries like os, yaml, geopandas, datacube, rasterio, and numpy.
- The script reads configuration from a YAML file and runs the extraction automatically when executed.
 ![Flood Digital Elevation Model within the project boundary](/flood_digital_elevation_model.png)

## Hydro condition elevation model
- The hydrocondition.py script prepares a digital elevation model (DEM) for hydrological analysis and generates a Height Above Nearest Drainage (HAND) raster. 
Steps include: 
    - Hydrological Conditioning: Fills pits, depressions, and missing data in the DEM using WhiteboxTools to create a hydrologically conditioned DEM.
    - Stream Network Extraction: Calculates flow accumulation, flow direction, and extracts stream networks based on a threshold.
    - Stream Ordering & Vectorization: Assigns stream order (Hack, Topological, Horton, or Strahler), reclassifies streams, and converts them to vector format.
    - HAND Calculation: Computes the HAND raster, representing elevation above the nearest stream.
    - Clipping & Masking: Clips rasters to the study area boundary and ensures correct spatial reference.
    - Utility Functions: Includes helpers for saving CRS, extracting stream endpoints, quantile calculations, and mosaicking/clipping rasters.
    - Workflow: The main_hydrocondition function orchestrates the above steps using configuration from a YAML file.
- For details on tHAND model, some publications include: https://www.sciencedirect.com/science/article/pii/S003442570800120X, 

## Exposure 
- This script downloads and saves OpenStreetMap (OSM) data for a given area of interest (AOI) defined by a GeoJSON file. It:
    - Loads the AOI boundary and ensures it is in the correct coordinate system.
    - Downloads three types of OSM data within the AOI:
        - Streets (roads and highways)
        - Facilities (hospitals, clinics, police, fire stations, etc.)
        - Parks/Greenspaces (parks, gardens, playgrounds, etc.)
    - Saves each dataset as a GeoJSON file in a specified output folder.
    - Prints a message if no features are found for any category.
- In short, it automates the extraction of key infrastructure and greenspace data from OSM for a project area.

## Flood Map
- This section processes geospatial raster data to help map flood risk using satellite and elevation data. 
- The script takes satellite and elevation data, identifies current and potential future flooded areas, and saves new raster files showing these flood extents. 
- It also outputs statistics about the flooded areas for further analysis 
- Reclassifies a satellite raster (A): 
    - It loads a raster (like an MNDWI water index image), and marks pixels as “1” if they are below a certain threshold (indicating water), and as “nodata” otherwise. This creates a binary water mask. 
- Masks a HAND raster (B) using the water mask:
    - It aligns the water mask with a HAND (Height Above Nearest Drainage) raster and keeps HAND values only where the water mask is “1”. All other pixels are set to nodata.
- Computes statistics:
    -Calculates the minimum, maximum, mean, and median of the HAND values in the flooded (water) areas.
- Creates a flood scenario raster:
    - Creates a new raster where only HAND values less than or equal to the median are kept (representing a plausible flood extent), and all others are set to nodata.
- Creates a short-term future flood scenario:
    - It increases the flood threshold by a configurable amount and repeats the masking process to simulate a possible near-future flood.

## Evacuation sites
- Find safe areas: It reads a flood map and identifies dry land by converting safe (non-flooded) areas into polygons. split these polygons into 100 individual polygons. 
- Check road access: It keeps only those dry areas that are close enough to roads, making sure people can reach them.
- Filter by elevation: It removes sites that are too low, keeping only those above a certain elevation to avoid future flooding.
- Check proximity to services: It further filters sites to make sure they are near important services like hospitals and parks.
- Score sites: It ranks the remaining sites based on how close they are to these services.
- Save results: The final list of ideal evacuation sites is saved as a GeoJSON file for use in maps or other tools.
 ![Parks / Facilities / Evacuation Spots Map](/flood_parks_facilities_evacuation_layer_map.png)


## View Short Term Flood Extents Map
- Short Term Flood extents prediction map:
![Flood Risk Short Term Prediction Map](/flood_risk_short_term_map.png)
 [Interactive HTML Version - 285 kb](/flood_risk_short_term_map.html)
 

## View Longer Term Flood Predictions Map
- Longer Term Flood extents prediction map (to 2028), with current and predicted future settlement:
![Flood Risk Long Term Prediction Map with Settlement](/flood_risk_long_term_map.png)
[Interactive HTML Version](/flood_risk_long_term_map.html) __Note__: Large file! 92.2MB
 
## Potential Flood Risk Areas
- Below we have manually added callouts to make it easier to spot areas that could be potential flood risks under current and future settlement growth scenarios.
 ![Flood Risk Map with callout sections](/flood_risk_map_with_callout_areas_compressed.webp)

## Related reading
- View the [Flood Risk Hackathon Activity Log](/posts/3/flood-risk-log).
- View the [overall results](/posts/0/results).