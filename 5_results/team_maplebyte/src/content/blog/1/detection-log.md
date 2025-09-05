---
title: Stream 1 Settlement Detection - Hackathon Activity Log
description: Settlement Detection process, tools, outputs, and the challenges and issues we faced in this workstream.

date: 2025-09-04
---

## Workstream Goal
Change Detection – Identify recent growth in informal settlements using Earth observation imagery and algorithms from [Digital Earth Africa](https://digitalearthafrica.org/en_za/).
such as GeoMAD, Sentinel 2, urban change detection as described in [DEA Sandbox](https://docs.digitalearthafrica.org/en/latest/sandbox/notebooks/Datasets/index.html)

## Activities
- For timeline, our main flood (our test baseline): 8 to 18 April 2022, so we want to do settlement detection from 2022 onwards and try to align our flood predictions to that one.
Other recent floods: May  22 2022; 17 to 21 Nov 2020; 8 to 12 March 201
- We used [ESRI Land Use / Land Cover](https://livingatlas.arcgis.com/landcoverexplorer/#mapCenter=30.98671%2C-29.71158%2C11.00&mode=step&timeExtent=2017%2C2024&year=2018&animation=true&animationData=2017%2C2024) maps at highest level of detail for years 2017 to 2023. They display land use/land cover (LULC) timeseries layer derived from ESA Sentinel-2 imagery at 10m resolution.
- We use Enhanced Normalized Difference Index ([ENDISI](https://ui.adsabs.harvard.edu/abs/2019JARS...13a6502C/abstract)) algorithm  
- We found a workaround for missing labels for 2025, we calculate the ENDISI directly from the S2-L2A image
- Recreated the binary masks because in the original algorithm, it takes a common threshold for both images, thus, for the same year it can be thresholded differently. for example for years 2019-2020 and 2020-2021, 2020 binary map can look different because of the coupling year. 
- We split 2022 into two periods, before and after the baseline flood event (in April 2022)
- We create also difference maps between each year to see where the growth happened but we don't think that total urban area information will be useful for the entire AOI, more accurate will be local data for a specific area.
- Using Jupyter notebook with modified GeoMAD algorithm.
- Change Map output: 1 = unban growth; 0 = changes, -1 = urban decline
- refined binary maps by applying water layer from the ESRI landcover maps (ESRI lulc maps are available only until 2023, so we applied 2023 lulc to 2024 and 2025 binary maps).

## Related reading
- View the [Settlement Detection detailed results](/posts/1/detection-results).