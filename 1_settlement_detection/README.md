# Workstream 1_Settlement Detection
# Binary maps of settlements
=============================

The binary maps of settlements were generated using Sentinel-2 satellite imagery available on the Digital Earth Africa (DEA) platform and the Urban Change Detection script, also available on the DEA.
<br>The process involved several key steps:
1. **AOI selection**:
A GeoJSON file delineating the area of interest (AOI) was used to focus the analysis on a specific geographic region, specifically, Durban, South Africa.
2. **Data Acquisition**: Sentinel-2 imagery was accessed through the DEA platform. For the analysis, we acquired images from 2019 to 2025, with a focus on 2022 when a major flood event occurred from 8 – 18 April 2022.
For the pre-flood period, the image from 29 March 2022 was used, while for the post-flood period, the image from 28 April 2022 was utilized, as these were the closest cloud-free images available around the event.
We used the swir_1, swir_2, blue, green, and red bands and set a spatial resolution of 10 meters.
For the years 2019–2021 and 2023–2024, we used annual geomedians; for 2025, we used the image from 8 March 2025, because a geomedian was not available for that year.
3. **Preprocessing**: The acquired images were used to calculate the Enhanced Normalized Difference Impervious Surfaces Index (ENDISI), and Otsu thresholding was applied to classify pixels into urban and non-urban areas.
4. **Post-processing**: Because large amounts of sediment were deposited in the river after the flood event, the river was misidentified as a settlement area. To correct this misclassification, we masked out the river using a water mask derived from the ESRI annual classification map for 2022. We applied corresponding water masks for other years as well to ensure consistency across the time series.
As ESRI doesn’t have a classification map for 2024 and 2025, we used the 2023 water mask for those years.
The refining script can be found in the `1_settlement_detection folder`, specifically in the `refine_binary_maps.py` file.

Change maps of settlements
================================
To generate change maps of settlements, we used the binary settlement maps created in the previous step. Each map was compared to the map from the previous year to identify changes in settlement areas. The changes were categorized into three classes:
- No Change (0): Areas where there was no change in settlement status between the two years.
- Settlement Gain (1): Areas that were classified as non-settlement in the previous year but were classified as settlement in the current year.
- Settlement Loss (−1): Areas that were classified as settlement in the previous year but were classified as non-settlement in the current year.
The script can be found in the `1_settlement_detection folder`, specifically in the `generate_change_maps.py` file.
