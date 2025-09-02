---
title: Stream 3 Flood Risk Prediction - Hackathon Activity Log
description: Flood risk predictions for identified or predicted settlements. Describes the process, tools, outputs, and the challenges and issues we faced in this workstream.
duration: 5min
date: 2025-09-02
---

## Workstream Goal
Risk Classification – Overlay forecasts with flood hazard maps using imagery and algorithms from [Digital Earth Africa](https://digitalearthafrica.org/en_za/).

## Approach
- Exploring DSM & DTM:
    - Digital Surface Model: ESA Copernicus glo 30 (this is technically a surface model,not terrain model)
    - Digital Terrain Model: [DeltaDTM v1.1](https://data.4tu.nl/datasets/1da2e70f-6c4d-4b03-86bd-b53e789cc629)
    - but no river data in deltadtm, so need to either merge in w/. copernicus, or fill na's.
    
- Modelling:
    - working to create hand model, which can be useful with riverine flooding (not necessarily coastal flooding or flash floods). [HAND](https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2ahUKEwjb3MOqzrqPAxXN1skDHZ8jK2gQFnoECB0QAQ&url=https%3A%2F%2Fnhess.copernicus.org%2Fpreprints%2Fnhess-2019-82%2Fnhess-2019-82-AR1.pdf&usg=AOvVaw3LAo4oXDR0-X02TveEjatj&opi=89978449)
    - starting with hydro condition of models: filling pits to make sure flow doesn't just pool falsely, breaching, etc. to create hydro conditioned DTM.
    - then compute streams from DTM and select only mainstem streams. 
    - then finally a HAND raster. this can be linked to river gauge readings to estimate flood based on terrain.
    - getting building footprints from [HOTOSM](https://data.humdata.org/dataset/hotosm_zaf_buildings). Doesn't have attributes we want, looking for category (single family house, residential...and maybe height), so will keep looking for alternatives.

- Scripting
    - creating local python script which can be read into a notebook

## Related reading
- View the [Flood Risk results](/posts/3/flood-risk-results).