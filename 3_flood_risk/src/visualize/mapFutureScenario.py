import os
import yaml
import folium
import geopandas as gpd
import rasterio
from rasterio import features
import numpy as np


def create_flood_risk_map(config):
    """
    Create a Folium map with HAND raster, settlements, and layer controls.
    """

    study_area_geojson = config['projectboundary']
    hand_raster = os.path.join(config['mainprojectfolder'], "hand.tif")
    current_settlements = config['urban_2022']
    future_settlements = config['urban_2028']
    output_html = config['output_html_future']

    
    # Load study area to find centre
    study_gdf = gpd.read_file(study_area_geojson)
    center = study_gdf.unary_union.centroid
    map_center = [center.y, center.x]

    # Initialize Folium map
    m = folium.Map(location=map_center, zoom_start=12, tiles="CartoDB positron")

    #helper
    def raster_to_layer(raster_path, value_colors, layer_name, opacity=0.6, show=True):
        """Convert raster values to polygons and add as a Folium layer."""
        with rasterio.open(raster_path) as src:
            data = src.read(1).astype("float32")
            data = np.where(data == src.nodata, np.nan, data)

            transform = src.transform
            shapes = features.shapes(data.astype("float32"), mask=~np.isnan(data), transform=transform)

            fg = folium.FeatureGroup(name=layer_name, show=show)

            for geom, val in shapes:
                color = None
                try:
                    val = int(val)
                except Exception:
                    continue
                for (low, high), c in value_colors.items():
                    if low <= val <= high:
                        color = c
                        break
                if color is None:
                    continue
                folium.GeoJson(
                    geom,
                    style_function=lambda feature, color=color: {
                        "fillColor": color,
                        "color": color,
                        "weight": 0,
                        "fillOpacity": opacity
                    }
                ).add_to(fg)

            m.add_child(fg)


    # Load color mapping from config
    value_colors = {}
    for entry in config['value_colors']:
        value_colors[(entry['min'], entry['max'])] = entry['color']

    # --- Add rasters as layers ---
    raster_to_layer(hand_raster, value_colors, "Flood Extents", opacity=0.6)
   

     # Settlements: current (single color, orange)
    settlement_colors = {(0, 999999): "#ff9900"}
    raster_to_layer(current_settlements, settlement_colors, "Current Settlements", opacity=0.7, show=False)

    # Future settlements: classify by pixel value
    settlement_colors_future = {
        (-1, -1): "#e63946",   # Negative change
        (0.6, 1):  "#1f77b4",     # New urban# No change
    }


    # Settlements can just be single-color
    # Current settlements (orange)
    settlement_colors = {(0, 999999): "#1f77b4"}
    raster_to_layer(current_settlements, settlement_colors, "Settlements (2022)", opacity=0.7)

    
    raster_to_layer(future_settlements, settlement_colors_future, "Future Settlements (2028)", opacity=0.7)

    # --- Add legend (static example for HAND only) ---
    legend_html = """
     <div style="position: fixed; 
                 bottom: 50px; left: 50px; width: 200px; height: 140px; 
                 background-color: white; z-index:9999; font-size:14px; 
                 border:2px solid grey; border-radius:8px; padding: 8px;">
     <b>Current/Future Flood Boundaries</b><br>
     <i style="background:#7a0177;width:20px;height:20px;float:left;margin-right:8px"></i> Current<br>
     <i style="background:#c51b8a;width:20px;height:20px;float:left;margin-right:8px"></i> Short-term Future<br>
     <i style="background:#f768a1;width:20px;height:20px;float:left;margin-right:8px"></i> Long-term Future<br>
     </div>
    """
    m.get_root().html.add_child(folium.Element(legend_html))

    # --- Add title ---
    title_html = """
     <h3 align="center" style="font-size:20px">
        Hypothetical future flood extents
     </h3>
    """
    m.get_root().html.add_child(folium.Element(title_html))

    # --- Layer control ---
    folium.LayerControl(collapsed=False).add_to(m)

    # --- Add opacity slider (requires Leaflet widget injection) ---
    slider_js = """
    <script>
    function setOpacity(layerName, opacity) {
        map.eachLayer(function(layer) {
            if (layer.options && layer.options.pane === "overlayPane" &&
                layer._leaflet_id && layer.options.name === layerName) {
                if(layer.setStyle){
                    layer.setStyle({fillOpacity: opacity});
                }
            }
        });
    }
    </script>
    """
    # Legend for Future Settlements
    settlements_legend_html = """
    <div style="position: fixed; 
                bottom: 50px; right: 50px; width: 200px; height: 120px; 
                background-color: white; z-index:9999; font-size:14px; 
                border:2px solid grey; border-radius:8px; padding: 8px;">
    <b> Settlements</b><br>
    <i style="background:#e63946;width:20px;height:20px;float:left;margin-right:8px"></i> Negative change (-1)<br>
    <i style="background:#cccccc;width:20px;height:20px;float:left;margin-right:8px"></i> No change (0)<br>
    <i style="background:#1f77b4;width:20px;height:20px;float:left;margin-right:8px"></i> New urban (1)<br>
    </div>
    """
    m.get_root().html.add_child(folium.Element(settlements_legend_html))


    m.get_root().html.add_child(folium.Element(slider_js))

    # Save map
    m.save(output_html)
    print(f"✅ Map saved to {output_html}")
    return m

# --- Run ---
config_file = "D:/g20/src/config/config.yaml"
with open(config_file, 'r') as f:
    config = yaml.safe_load(f)

create_flood_risk_map(config)
