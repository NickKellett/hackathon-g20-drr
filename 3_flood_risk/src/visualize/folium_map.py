import os
import yaml
import folium
import geopandas as gpd
import rasterio
from rasterio import features
import numpy as np
import branca.colormap as cm
from shapely.geometry import box
from folium import Map, Html, Element


def create_flood_risk_map(study_area_geojson, depth_raster_path, buildings_geojson, output_html):
    """
    Create a Folium map with water depth raster and buildings colored by risk_index.

    Parameters
    ----------
    study_area_geojson : str or Path
        GeoJSON of the study area (for centering the map).
    depth_raster_path : str or Path
        Water depth raster path.
    buildings_geojson : str or Path
        GeoJSON of buildings with 'risk_index'.
    output_html : str or Path
        Path to save the interactive map.
    """
    # Load study area to find centre
    study_gdf = gpd.read_file(study_area_geojson)
    center = study_gdf.unary_union.centroid
    map_center = [center.y, center.x]

    # Initialize Folium map
    m = folium.Map(location=map_center, zoom_start=12, tiles="CartoDB positron")

    # Load depth raster
    with rasterio.open(depth_raster_path) as src:
        depth_data = src.read(1)
        depth_data = np.where(depth_data == src.nodata, np.nan, depth_data)
        bounds = src.bounds
        transform = src.transform

        # Normalize depth for color mapping
        max_val = np.nanmax(depth_data)
        colormap = cm.linear.Blues_09.scale(0, max_val)

        # Convert raster to polygons for Folium
        shapes = features.shapes(depth_data, mask=~np.isnan(depth_data), transform=transform)
        for geom, val in shapes:
            folium.GeoJson(
                geom,
                style_function=lambda feature, val=val: {
                    "fillColor": colormap(val),
                    "color": colormap(val),
                    "weight": 0,
                    "fillOpacity": 0.6
                }
            ).add_to(m)
        colormap.caption = "Water Depth"
        m.add_child(colormap)

    # Load buildings GeoJSON
    buildings_gdf = gpd.read_file(buildings_geojson)

    # Risk color mapping: 1-4
    risk_colors = {
        1: "#b7e4c7",  # light green
        2: "#fff3b0",  # yellow
        3: "#ffb347",  # orange
        4: "#e63946"   # red
    }

   # Add buildings to map with outline matching fill
    folium.GeoJson(
        buildings_gdf,
        style_function=lambda feature: {
            "fillColor": risk_colors.get(feature["properties"]["risk_index"], "#808080"),
            "color": risk_colors.get(feature["properties"]["risk_index"], "#808080"),  # outline same as fill
            "weight": 1,
            "fillOpacity": 0.7
        },
        tooltip=folium.GeoJsonTooltip(
            fields=["current_water_depth", "risk_index"],
            aliases=["Water Depth", "Risk Index"]
        )
    ).add_to(m)

    
    # Compute counts of each risk index
    risk_counts = buildings_gdf['risk_index'].value_counts().sort_index()
    # e.g., {1: 15, 2: 8, 3: 4, 4: 2}

    # Build a summary string
    title_text = "Building Risk Summary:<br>"
    for risk_level in sorted(risk_counts.index):
        title_text += f"Risk {risk_level}: {risk_counts[risk_level]} buildings<br>"

    # Build a styled HTML string
    title_html = '<div style="position: fixed; top: 10px; left: 50px; width: 300px; background-color: white; z-index:9999; padding: 10px; border:2px solid grey; font-size:14px;">'
    title_html += '<b>Building Damagage Categories Summary: Current Scenario</b><br>'

    for risk_level in sorted(risk_counts.index):
        color = risk_colors.get(risk_level, "#808080")
        count = risk_counts[risk_level]
        # Create a small colored box next to the text
        title_html += f'<div style="display:flex; align-items:center; margin-bottom:3px;">'
        title_html += f'<div style="width:15px; height:15px; background-color:{color}; margin-right:5px; border:1px solid #000;"></div>'
        title_html += f'Damage Level {risk_level}: {count} buildings'
        title_html += '</div>'

    title_html += '</div>'
    m.get_root().html.add_child(folium.Element(title_html))

    # Example thresholds from config
    thresholds = config['depth_thresholds']  # e.g., [0.5, 1.0, 2.0]

    # Build HTML for thresholds
    threshold_html = '<div style="position: fixed; bottom: 10px; left: 50px; width: 300px; background-color: white; z-index:9999; padding: 10px; border:2px solid grey; font-size:14px;">'
    threshold_html += '<b>Flood Damage Level Thresholds (Water Depth in meters):</b><br>'

    for i, threshold in enumerate(thresholds):
        color = risk_colors.get(i+1, "#808080")
        threshold_html += f'<div style="display:flex; align-items:center; margin-bottom:3px;">'
        threshold_html += f'<div style="width:15px; height:15px; background-color:{color}; margin-right:5px; border:1px solid #000;"></div>'
        threshold_html += f'Damage Level {i+1}: ≤ {threshold} m'
        threshold_html += '</div>'

    # Add the last risk (greater than highest threshold)
    color = risk_colors.get(len(thresholds)+1, "#808080")
    threshold_html += f'<div style="display:flex; align-items:center; margin-bottom:3px;">'
    threshold_html += f'<div style="width:15px; height:15px; background-color:{color}; margin-right:5px; border:1px solid #000;"></div>'
    threshold_html += f'Damage Level {len(thresholds)+1}: > {thresholds[-1]} m'
    threshold_html += '</div>'

    threshold_html += '</div>'

    # Add to Folium map
    m.get_root().html.add_child(folium.Element(threshold_html))

    # Save map
    m.save(output_html)

##temp:
config_file = "D:/g20/src/config/config.yaml"
with open(config_file, 'r') as f: 
    config = yaml.safe_load(f)

study_area_geojson = config['projectboundary']
depth_raster_path = os.path.join(config['riskfolder'], "depth.tif" )
buildings_geojson = os.path.join(config['riskfolder'], "building_risk_output.geojson")
output_html = config['output_html']

create_flood_risk_map(study_area_geojson, depth_raster_path, buildings_geojson, output_html)