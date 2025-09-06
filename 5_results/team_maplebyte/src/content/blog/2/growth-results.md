---
title: Stream 2 Settlement Growth Prediction - Detailed Results
description: Settlement Growth Prediction results

date: 2025-09-05
---

## Workstream Goal
Forecast Expansion – Predict development over 1–3 years using imagery and algorithms from [Digital Earth Africa](https://digitalearthafrica.org/en_za/).

## Results
- We split the growth forecasts into two scenarios because the 2022 flood was a unique event, it caused a sharp drop in settlement expansion that does not follow the natural trend. If we forced all years into one model, the results would either ignore the flood's impact or distort the forecast with unrealistic negative growth.
- Here is a hotspot probability map for informal settlement growth generated for 2022–2025.
![Hotspot probability map for 2022-2025](/growth_hotspot_probability_map_2022_to_2025.png)
- A heat map is a good way to summarize the growth areas spatially. It shows areas with consistent settlement expansion, the brighter the color, the higher the probability of growth. Notice the river also shows up, that is because of the 2022 flood event, which altered its spectral signature and got picked up as change. This highlights how sensitive the analysis is to environmental events.
![Heat map for projected growth](/settlement_growth_heat_map.png)
- Growth Forecast Scenarios:
    - *Flood-aware (Scenario A)*: captures the disruption; useful to show what happens if floods continue to shape expansion.
    - *Flood-free (Scenario B)*: removes the anomaly; useful to show the "natural" growth path without disasters.
- Related, our findings clearly indicate two distinct futures:
    - Flooding is a strong disrupter of settlement growth and changes (see also [Flood Risk Results](/posts/3/flood-risk-results)).
    - Better adaptation and resilience measures are in place (see also [Policy, Awareness & Outreach Results](/posts/4/policy-awareness-outreach-results)).
- We built a slope mask (restricted slopes >30°) and combined it with the water mask from MNDWI. The result is our final constraint layer to feed into MOLUSCE showing only areas potentially suitable for settlement growth.
BLUE marks an area available for settlement and RED shows the presence of geographic constraints that would likely prevent settlement. 
- Note this does not incorporate any private or government land or other land use constraints.
![Growth Constraint Map](/settlement_growth_constraints.png)
- We can now project informal settlement growth to 2028:
    - ![Heatmap of Observed Growth (2019–2025) vs Heatmap of Forecasted Growth (2025–2028)](/settlement_growth_story.png)[Heatmap of Observed Growth (2019–2025) vs Heatmap of Forecasted Growth (2025–2028)](/settlement_growth_story.png)
    - ![Projected Settlement Footprint by 2028](/settlement_growth_projected_footprint_by_2028.png)[Projected Settlement Footprint by 2028](/settlement_growth_projected_footprint_by_2028.png)

## Model Validation
- Detailed validation numbers are included in [Settlement Growth Model Validation Results.pdf](/settlement_growth_model_validation_results.pdf).

## Related reading
- View the [Settlement Growth Hackathon Activity Log](/posts/2/growth-log).
- View the [overall results](/posts/0/results).