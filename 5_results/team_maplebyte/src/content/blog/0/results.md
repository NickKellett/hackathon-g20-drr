---
title: Our Team Results
description: The final output our team produced.

date: 2025-09-05
---

## Results

### Area of Interest
- We selected an informal settlement centred on [Quarry Road / N2 Interchange Umgeni in Durban, South Africa](https://maps.app.goo.gl/7fadAFBqjgFrtHAX9). 
![View on Google Maps](/google_map_quarry_road_aoi_compressed.webp)
- We used this as our baseline because an excellent article, "A Perfect Storm" published in the Outlier gave us great insight into the suffering and issues caused by a historic April 2022 flood. 
- We could therefore compare our research efforts and findings against this real world example, in the hopes that future refinements of our results might one day help people living in informal settlements and affected by flooding - like those near Quarry Road.

### Detected current settlements
- Produced binary maps of settlements using Sentinel-2 imagery over Durban, South Africa.
- Developed change maps of settlements comparing the maps from previous years to identify areas where there were settlement gains, losses, or no changes.

### Predicted future growth
- We used the settlement detection data to help project future growth.
- Here is a hotspot probability map for informal settlement growth generated for 2022–2025. 
![Hotspot probability map for 2022-2025](/growth_hotspot_probability_map_2022_to_2025.png)
- The heat map is a good way to summarize the growth areas spatially. 
- It shows areas with consistent settlement expansion, the brighter the color, the higher the probability of growth. Notice the river also shows up, that is because of the 2022 flood event, which altered its spectral signature and got picked up as change. This highlights how sensitive the analysis is to environmental events.
![Heat map for projected growth](/settlement_growth_heat_map.png)
- We built a slope mask (restricted slopes >30°) and combined it with the water mask from MNDWI. The result is our final constraint layer to feed into MOLUSCE showing only areas potentially suitable for settlement growth.
BLUE marks an area available for settlement and RED shows the presence of geographic constraints that would likely prevent settlement. 
- Note this does not incorporate any private or government land or other land use constraints.
![Growth Constraint Map](/settlement_growth_constraints.png)
- We can now project informal settlement growth to 2028:
    - ![Heatmap of Observed Growth (2019–2025) vs Heatmap of Forecasted Growth (2025–2028)](/settlement_growth_story.png)[Heatmap of Observed Growth (2019–2025) vs Heatmap of Forecasted Growth (2025–2028)](/settlement_growth_story.png)
    - ![Projected Settlement Footprint by 2028](/settlement_growth_projected_footprint_by_2028.png)[Projected Settlement Footprint by 2028](/settlement_growth_projected_footprint_by_2028.png)

### Identified flood extents and risks
- Generated a Hydro condition elevation model script which prepares a digital elevation model (DEM) for hydrological analysis and generates a Height Above Nearest Drainage (HAND) raster
- Identified high level exposure by automating the extraction of key infrastructure and greenspace data from [OpenStreetMap (OSM)](https://www.openstreetmap.org) for our AOI.
- We then processed geospatial raster data to help map flood risk using satellite and elevation data. The script takes satellite and elevation data, identifies current and potential future flooded areas, and saves new raster files showing these flood extents. It also outputs statistics about the flooded areas for further analysis
- Identify suitable evacuation sites, by finding safe areas (non flooded/dry land), checking road access, filtering by elevation, checking proximity to important services like hospitals. We then ranked the filtered list of safe sites based on how close they are to these services. The final list of ideal evacuation sites is saved as a GeoJSON file for use in maps or other tools. 

### View Short Term Flood Extents Map
- Short Term Flood extents prediction map:
![Flood Risk Short Term Prediction Map](/flood_risk_short_term_map.png)
 [Interactive HTML Version - 285 kb](/flood_risk_short_term_map.html)

### View Longer Term Flood Predictions Map
- Longer Term Flood extents prediction map (to 2028), with current and predicted future settlement:
![Flood Risk Long Term Prediction Map with Settlement](/flood_risk_long_term_map.png)
[Interactive HTML Version](/flood_risk_long_term_map.html) __Note__: Large file! 92.2MB

### Determined Relevant Policies and Communications for Community Leaders and Policy Makers
Due to hackathon time constraints we have only considered two main groups of stakeholders:
1. __"Community Leaders"__ - authoritative members of the public residing in the informal settlements, who are or may be affected by disasters such as flooding
2. __"Policy Makers"__ - government, NGO and related organizations who wish to develop effective policies to better inform and empower the community leaders and settlement inhabitants about the disaster risks and how to adapt and become more resilient.

### Created Policy Decision Trees
- We decided to turn the settlement growth and flood risk content into relevant policy and communications material via "policy decision trees", which are affected by whether the flood risk is imminent or a future danger.
- Divided into two categories
1. Government-led decisions
2. Community-led decisions (with or without government support)
- These are a work in progress and reflect a high-level understanding of potential relevant policy actions, and are not likely comprehensive nor given the hackathon time constraints can they account for the actual government and collaborating organizations, projects, policies, and procedures.
- We note that certain government-led policies that could apply - such as those relating to mandatory evacuations and resettlements - are controversial and may well be resisted by informal settlement community leaders and members.
- Government-led Decision Tree:
 ![Government-led Decision Tree](/flood_decision_trees_government_led.drawio.png) 
- Community-led Decision Tree:
 ![Community-led Decision Tree](/flood_decision_trees_community_led.drawio.png)

### Created Focused Websites to Communicate with Target Audiences
- These audiences have different needs and so we created two static websites to focus on each type of audience separately. 
- We chose web templates that are mostly static but allow some dynamic elements to improve usability and allow data refreshing. We chose the Astro framework for this purpose. 
- In addition, we focused on very low-tech, streamlined themes to ensure they loaded quickly and properly on a variety of mobile and desktop devices, and in low bandwidth settings.
- You can view a live version of the websites here:
1. ["Community Leaders" live microsite](https://g20hack-user-resident.climatechange.ca/). We partially translated the content into isiZulu in recognition that in our use case the Durban population speaks English and isiZulu. You can toggle between the languages on the top righthand corner.
2. ["Policy Makers" live microsite](https://g20hack-user-policy.climatechange.ca/)

### Detailed Results by Workstream
- View the [Settlement Detection detailed results](/posts/1/detection-results).
- View the [Settlement Growth Prediction detailed results](/posts/2/growth-results).
- View the [Flood Risk detailed results](/posts/3/flood-risk-results).
- View the [Policy Awareness & Outreach detailed results](/posts/4/policy-awareness-outreach-results).

## In Conclusion
- The hackathon was a multi-day event and we worked from afar. 
- We recognize there are inevitably gaps in our understanding, our data, and our models.
- As well, many people and organizations have no doubt been working hard with the settlement residents since the April 2022 flood to improve matters, and at least some of the conclusions of our work may already be outdated.
- Having said that, we are glad to have participated in this hackathon, proud of what we accomplished in a short period, and we hope the work is of use to others, in that area and beyond!

## Related reading
- [If we had more time...](/posts/0/more-time).
- [G20 DRR Hackathon Background](/posts/0/hackathon-background).
- [Our Team Hackathon Approach](/posts/0/hackathon-approach).
- [Our Team Hackathon Data and Software Tools](/posts/0/data-software-tools).