---
title: Stream 2 Settlement Growth Prediction - Results
description: Settlement Growth Prediction results
duration: 5min
date: 2025-09-02
---

## Workstream Goal
Forecast Expansion – Predict development over 1–3 years using imagery and algorithms from [Digital Earth Africa](https://digitalearthafrica.org/en_za/).

## Results
- We split the growth forecasts into two scenarios because the 2022 flood was a unique event, it caused a sharp drop in settlement expansion that does not follow the natural trend. If we forced all years into one model, the results would either ignore the flood's impact or distort the forecast with unrealistic negative growth, as we saw in our initial work.
- Here is a hotspot probability map for informal settlement growth generated for 2022–2025. We did not include the preceding years because their changes were minimal. 
![Hotspot probability map for 2022-2025](/growth_hotspot_probability_map_2022_to_2025.png)
- The heat map is a good way to summarize the growth areas spatially. 
- It shows areas with consistent settlement expansion, the brighter the color, the higher the probability of growth. Notice the river also shows up, that is because of the 2022 flood event, which altered its spectral signature and got picked up as change. This highlights how sensitive the analysis is to environmental events. 
- Growth Forecast Scenarios:
    - *Flood-aware (Scenario A)*: captures the disruption; useful to show what happens if floods continue to shape expansion.
    - *Flood-free (Scenario B)*: removes the anomaly; useful to show the "natural" growth path without disasters.
- Related, our findings clearly indicate two distinct futures:
    - Flooding is a strong disrupter of settlement growth and changes (see also [Flood Risk Results](/posts/3/flood-risk-results)).
    - Better adaptation and resilience measures are in place (see also [Policy, Awareness & Outreach Results](/posts/4/policy-awareness-outreach-results)).
- We built a slope mask (restricted slopes >30°) and combined it with the water mask from MNDWI. The result is our final constraint layer to feed into MOLUSCE showing only areas suitable for settlement growth.
BLUE, good for settlement and RED shows the constraint.

## Related reading
- View the [Settlement Growth Hackathon Activity Log](/posts/2/growth-log).