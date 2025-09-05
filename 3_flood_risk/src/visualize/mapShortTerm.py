import os
import yaml
import folium
import geopandas as gpd
import rasterio
from rasterio import features
import numpy as np
from folium import FeatureGroup, Icon, Marker, LayerControl, Map, Element


def gdf_for_folium(gdf):
    """Convert datetime columns to strings so Folium can consume the GeoDataFrame."""
    gdf = gdf.copy()
    for col in gdf.columns:
        if col == gdf.geometry.name:
            continue  # skip geometry column
        if np.issubdtype(gdf[col].dtype, np.datetime64):
            gdf[col] = gdf[col].astype(str)
    return gdf

from folium.raster_layers import ImageOverlay
import matplotlib.pyplot as plt


def add_raster_layer(m, raster_path, colormap, layer_name, opacity=0.6, show=True):
    """Add a raster to a Folium map as an image overlay, masking nodata completely transparent."""
    with rasterio.open(raster_path) as src:
        data = src.read(1).astype(float)

        # Mask nodata
        nodata_mask = (data == src.nodata)
        data[nodata_mask] = np.nan

        # Normalize values
        vmin, vmax = np.nanmin(data), np.nanmax(data)
        if vmin == vmax:
            normed = np.zeros_like(data)
        else:
            normed = (data - vmin) / (vmax - vmin)

        # Apply matplotlib colormap
        cmap = plt.get_cmap(colormap)
        rgba_img = cmap(normed)  # shape (H, W, 4)

        # Force nodata pixels fully transparent
        rgba_img[nodata_mask, 3] = 0.0  

        # Bounds for overlay
        bounds = [[src.bounds.bottom, src.bounds.left],
                  [src.bounds.top, src.bounds.right]]

        # Add to folium
        ImageOverlay(
            image=rgba_img,
            bounds=bounds,
            opacity=opacity,
            name=layer_name,
            show=show
        ).add_to(m)

def add_geojson_layer(m, geojson_path, layer_name, color="#3388ff", point_symbol=None, show=True):
    gdf = gpd.read_file(geojson_path)
    
    # Filter geometries by layer type
    if layer_name.lower() == "streets":
        gdf = gdf[gdf.geometry.type.isin(["LineString", "MultiLineString"])]
    elif layer_name.lower() == "parks":
        gdf = gdf[gdf.geometry.type.isin(["Polygon", "MultiPolygon"])]
    
    fg = FeatureGroup(name=layer_name, show=show)
    
    for geom in gdf.geometry:
        if geom is None or geom.is_empty:
            continue
        if geom.geom_type in ["Point", "MultiPoint"] and point_symbol:
            folium.CircleMarker(
                location=[geom.y, geom.x] if geom.geom_type=="Point" else [geom.centroid.y, geom.centroid.x],
                radius=5,
                color=point_symbol,
                fill=True,
                fill_color=point_symbol,
                fill_opacity=0.7
            ).add_to(fg)
        else:
            folium.GeoJson(
                geom,
                style_function=lambda x, color=color: {"color": color, "weight": 2, "fillColor": color, "fillOpacity": 0.6}
            ).add_to(fg)
    
    fg.add_to(m)

def create_flood_risk_map(config):
    """Create interactive flood risk map with multiple layers."""
    # Paths
    study_area_geojson = config['projectboundary']
    depth_raster_current = os.path.join(config['riskfolder'], "HAND_raster_Flood.tif")
    depth_raster_future = os.path.join(config['riskfolder'], "hand_shortterm.tif")
    #streets_geojson = os.path.join(config['intermedieatefiles'], "streets.geojson")
    parks_geojson = os.path.join(config['intermedieatefiles'], "parks.geojson")
    facilities_geojson = os.path.join(config['intermedieatefiles'], "facilities.geojson")
    #evacuation_site_geojson = os.path.join(config['intermedieatefiles'], "evacuation_sites.geojson")
    ideal_evacuation_site_geojson = os.path.join(config['intermedieatefiles'], "ideal_evacuation_sites.geojson")

    output_html = config['output_html']

    # Map center
    study_gdf = gpd.read_file(study_area_geojson)
    center = study_gdf.unary_union.centroid
    map_center = [center.y, center.x]
    m = Map(location=map_center, zoom_start=12, tiles="CartoDB positron")

    # Add raster layers
    add_raster_layer(m, depth_raster_current, "Reds", "Current Flood Extent", opacity=0.5)
    add_raster_layer(m, depth_raster_future, "Blues", "Short Term Future Flood", opacity=0.5)
    # Add vector layers
    
    #add_geojson_layer(m, streets_geojson, "Streets", color="black", show=True)
    add_geojson_layer(m, parks_geojson, "Parks", color="green", point_symbol="green")
    add_geojson_layer(m, facilities_geojson, "Facilities", color="red", point_symbol="red")
    #add_geojson_layer(m, evacuation_site_geojson, "Evacuation Sites", color="orange", point_symbol="orange")
    add_geojson_layer(m, ideal_evacuation_site_geojson, "Ideal Evacuation Sites", color="purple", point_symbol="purple")

    # Add LayerControl
    LayerControl(collapsed=False).add_to(m)

    # Legend
    legend_html = """
    <div style="position: fixed; 
                bottom: 50px; left: 50px; width: 200px; height: 200px; 
                background-color: white; border:2px solid grey; z-index:9999; font-size:14px;
                padding: 10px;">
    <b>Legend</b><br>
    <i style="background:#e63946;width:12px;height:12px;float:left;margin-right:5px;opacity:0.6"></i> Current Flood<br>
    <i style="background:#3331bd;width:12px;height:12px;float:left;margin-right:5px;opacity:0.6"></i> Short Term Future Flood<br>
    <i style="background:green;width:12px;height:12px;float:left;margin-right:5px;opacity:0.8"></i> Parks<br>
    <i style="background:red;width:12px;height:12px;float:left;margin-right:5px;opacity:0.8"></i> Facilities<br>
    <i style="background:purple;width:12px;height:12px;float:left;margin-right:5px;opacity:0.8"></i> Ideal Evacuation Sites
    </div>
    """
    m.get_root().html.add_child(Element(legend_html))

    # Save map
    m.save(output_html)
    print(f"✅ Map saved to {output_html}")
    return m


# Example usage
config_file = "D:/g20/src/config/config.yaml"
with open(config_file, 'r') as f:
    config = yaml.safe_load(f)

create_flood_risk_map(config)
