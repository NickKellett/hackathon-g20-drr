---
title: Stream 3 - Flood Risk Prediction
description: Flood risk predictions for identified or predicted settlements. Describes the process, tools, outputs, and the challenges and issues we faced in this workstream.
duration: 5min
date: 2025-09-02
---

Exploring DSM & DTM,
DSM: copernicus glo 30 (as this is technically a surface model - not terrain model)
dtm: deltadtm: https://data.4tu.nl/datasets/1da2e70f-6c4d-4b03-86bd-b53e789cc629
*but no river data in deltadtm, so need to either merge in w/. copernicus, or fill na's.working to create hand model, which can be useful with riverine flooding (not necessarily coastal flooding or flash floods). HAND : https://www.google.com/url?sa=t&rct=j&q=&esrc=s&source=web&cd=&cad=rja&uact=8&ved=2a[…]2019-82-AR1.pdf&usg=AOvVaw3LAo4oXDR0-X02TveEjatj&opi=89978449
starting with hydro condition of models: filling pits to make sure flow doesn't just pool falsely, breaching, etc. to create hydro conditioned dtm.
then compute streams from dtm and select only mainstem streams. then finally a HAND raster.
this can be linked to river gauge readings to estimate flood based on terrain.
-creating local python script which can be read into a notebook
