---
title: Stream 2 Settlement Growth Prediction - Hackathon Activity Log
description: Settlement Growth prediction process, tools, outputs, and the challenges and issues we faced in this workstream.
duration: 5min
date: 2025-09-02
---
## Workstream Goal
Forecast Expansion – Predict development over 1–3 years using imagery and algorithms from [Digital Earth Africa](https://digitalearthafrica.org/en_za/).

## Approach
-  processed the change maps (2019–2025) and computed annual new settlement growth.
- Growth varies year to year, but averages around 500 ha per year, with a big spike in 2022→23 (780 ha). Plot shows the trend:
 ![Growth Plot](/change_map_growth_plot.png)
- biggest question now is why the drop from 2023 - 2024? Some possibilities:     
    - people might relocated after the flood event in 2022
    - threshold method didn't work out well enough
- Going to do the following to prevent the unusual year distorting the results:
    - Keep the raw yearly numbers for context, but
    - Fit a linear trend to smooth the growth pattern, and
    - Use that to generate forecasts for 2026–2028.
    - This way our projections are more stable and reliable for overlaying with the flood risk maps.

## Results
- View the [Settlement Growth Prediction results](/posts/2/growth-results).