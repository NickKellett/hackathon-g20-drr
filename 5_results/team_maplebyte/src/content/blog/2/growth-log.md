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
- Issue: after the event in 2022, the river changed its color and now is detected as urban area, it can contribute to extra settlement pixels.
- initially did not consider the event that happened in 2022, instead of considering the before and the after periods in 2022
- When considering before and after periods in 2022:
    - data was showing new settlement growth per year from 2019 up to 2025, but the x-axis is aligned to the ending year/event.
    - That’s why the first point is 2020, because it represents change from 2019 to 2020. Nothing flows into 2019 since it’s the baseline.
    - In 2022, things split: 2022_before shows growth leading up to the flood event. 2022_event shows the spike caused by the flood misclassification (the river being detected as settlement).
    - After that, the trend goes back to “normal” with 2023, 2024, and 2025.
    - As already established, The “jump” in 2022_event is not natural growth, it’s an artifact of the flood changing the river’s appearance in the imagery. That’s why it peaks unusually high.
    The drop in 2024 shows much less new growth that year, then it rises again in 2025.
- revised growth plot:
 ![Revised Growth Plot](/change_map_growth_plot_revised.png)
- Now there's no need to fit the regression line anymore so will use this to continue with the analysis.
- Here’s the hotspot probability map generated for 2022–2025, we didn't add the previous years because their changes were minimal. 
![Hotspot probability map](/growth_hotspot_probability_map.png)
- It shows areas with consistent settlement expansion, the brighter the color, the higher the probability of growth. You’ll notice the river also shows up, that’s because of the 2022 flood event, which altered its spectral signature and got picked up as change. This isn’t settlement growth but highlights how sensitive the analysis is to environmental events. This would be a good way to summarize the growth areas spatially. 
- Split the forecasts into two scenarios because the 2022 flood was a unique event, it caused a sharp drop in settlement expansion that doesn’t follow the natural trend. If we forced all years into one model, the results would either ignore the flood's impact or distort the forecast with unrealistic negative growth, we initially did that and saw this trend.
    - Flood-aware (Scenario A): captures the disruption; useful to show what happens if floods continue to shape expansion.
    - Flood-free (Scenario B): removes the anomaly; useful to show the “natural” growth path without disasters.
- We can clearly present two futures:
    - One if flooding remains a strong driver.
    - One if better measures are in place.
- We also compared the 2025 observed TIFF with the forecast and, while the growth isn't major, it is visible.
- Finally, we've uploaded the forecast GeoTIFFs, each scenario has three outcomes (2026–2028). These should help with the flood overlays.
- What we plan on doing next is not anything major, just making the forecast visualizations more appealing. If the separation is accepted, then this can be used to begin the overlay work in Flood Risk.

## Related reading
- View the [Settlement Growth Prediction results](/posts/2/growth-results).