# Workstream 3_Flood Risk
## Background. 

This notebook has been created for G20 DRR Hackathon for Team MapleByte (Canada). This works towards the 'Flood Risk' portion of the challenge.  
Project/team site: [g20hack-maplebyte.climatechange.ca](https://g20hack-maplebyte.climatechange.ca/)
*** please note these outputs are simulations and do not represent real results - but instead represent an approach that could be explored to simulate/estimate flooding extents. 
*** the results have not been validated or confirmed. 


## Flood Mapping
For flood mapping we've broken the task into two components;
1. Current flood and short-term flood extents
2. Longer term flood
Both scenarios are mostly hypothetical/synthetic.
In Scenario 1, we combine satellite data and HAND model to estimate flood boundaries. Satellite data was used to identify water. The image used is from 2022-04-14, using LandSat8 and computing MNDWI. This was then thresholded to estimate water and non-water. From the 'water' we then analyzed it with the Height Above Nearest Drainage (HAND) dataset, built from the Copernicus Glo 30 DEM. The intersection of the MNDWI and the associated HAND values was explored and statistics of those HAND values were recorded. We combined this HAND and MNDWI to be a "currently occurring" (hypothetical) flood scenario. We then added an artificial adjustment to estimate additional (hypothetical) short-term potential flood. e.g. in the next 24hrs what might the water level change to.
We then explored vector data from OSM, streets, emergency facilities (hospital, police, firestations, etc.) parks in combination with the flood extents to estimate where probable evacuation points could be for citizens in/near flood zones.
*for the current and short-term future flood scenarios, using near-by river gauges, synthetic rating curves or manual estimates could aid in creating a more realistic extent map.
In Scenario 2, we made use of the HAND Model again, setting differnt thresholds for potential future flood extents. These again are hypothetical, but could represent changing flood zones due to climate change, increased urbanization, etc. This is then overlaid by the urban pixels identified in task1, and the estimated growth from task 2


To run this notebook, you will need:
1. geojson of your study area (preferably in WGS84). One place to easily create one is from https://geojson.io/ from MapBox. 
2. config.yaml file. update it to the file paths/parameters of your choosing. (existing config file in config folder)
3. GeoTIF: urban settlements present day and for future scenario
4. GeoTIF of MWDWI


