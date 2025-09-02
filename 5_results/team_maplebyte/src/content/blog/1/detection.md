---
title: Stream 1 - Settlement Detection
description: Settlement Detection process, tools, outputs, and the challenges and issues we faced in this workstream.
duration: 5min
date: 2025-09-02
---
Identify recent growth in informal settlements using GeoMAD, Sentinel 2, urban change detection as described in [DEA Sandbox](https://docs.digitalearthafrica.org/en/latest/sandbox/notebooks/Datasets/index.html)

For timeline, our main flood (our test baseline): 8 to 18 April 2022, so we want to do settlement detection from 2022 onwards and try to align our flood predictions to that one.
Other recent floods: May  22 2022; 17 to 21 Nov 2020; 8 to 12 March 201

We used [ESRI Land Use / Land Cover](https://livingatlas.arcgis.com/landcoverexplorer/#mapCenter=30.98671%2C-29.71158%2C11.00&mode=step&timeExtent=2017%2C2024&year=2018&animation=true&animationData=2017%2C2024) maps at highest level of detail for years 2017 to 2023. They display land use/land cover (LULC) timeseries layer derived from ESA Sentinel-2 imagery at 10m resolution. 
We found a workaround for missing labels for 2025, I calculate the ENDISI directly from the S2-L2A image