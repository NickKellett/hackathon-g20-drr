#1. threshold hand - manual or by satellite derived
#get water depth
#intersect buildings, and extract raster value.
# compute risk matrix attribute table, create map

import json
import os
import yaml
import rasterio
import numpy as np
import geopandas as gpd
from rasterio.mask import mask
from shapely.geometry import mapping
from pathlib import Path



def process_hand_raster(config, hand_raster_path, temp_raster_path, depth_raster_path):
    """
    Threshold HAND raster and compute water depth raster.
    """
    current_hand = config["current_hand"]
    future_hand = config["projection_hand"]
    hand_threshold = current_hand + future_hand
    nodata_value = -32768

    # Open raster
    with rasterio.open(hand_raster_path) as src:
        profile = src.profile
        hand_data = src.read(1)
        input_nodata = src.nodata

    # Mask: values > current_hand or input nodata set to nodata
    mask_nodata = (hand_data > hand_threshold)
    if input_nodata is not None:
        mask_nodata |= (hand_data == input_nodata)
    temp_data = np.where(mask_nodata, nodata_value, hand_data)

    # Save thresholded raster
    profile.update(dtype=rasterio.float32, nodata=nodata_value)
    with rasterio.open(temp_raster_path, "w", **profile) as dst:
        dst.write(temp_data.astype(np.float32), 1)

    # Compute depth = current_hand - raster_value (only where valid)
    depth_data = np.where(temp_data != nodata_value, hand_threshold - temp_data, nodata_value)

    # Save depth raster
    with rasterio.open(depth_raster_path, "w", **profile) as dst:
        dst.write(depth_data.astype(np.float32), 1)

def extract_depth_at_buildings(config, buildings_geojson, depth_raster_path, output_geojson):
    import numpy as np
    import geopandas as gpd
    import rasterio
    from rasterio.mask import mask
    from shapely.geometry import mapping

    # Read buildings
    gdf = gpd.read_file(buildings_geojson)

    # Ensure geometries are valid
    gdf = gdf[gdf.geometry.notnull()]
    gdf["geometry"] = gdf["geometry"].buffer(0)

    # Open raster
    with rasterio.open(depth_raster_path) as src:
        nodata = src.nodata

        # Extract mean raster value inside each polygon
        values = []
        for geom in gdf.geometry:
            if geom.is_empty:
                values.append(0.0)  # replace empty with 0 or np.nan
                continue
            out_image, _ = mask(src, [mapping(geom)], crop=True)
            arr = out_image[0]
            arr = arr[arr != nodata]
            values.append(float(arr.mean()) if arr.size > 0 else 0.0)

    # Add column with proper name and dtype
    gdf["current_water_depth"] = np.array(values, dtype=float)

    # Optional: check before saving
    print("Columns:", gdf.columns)
    print(gdf.head())

    #MAYBE: 
     # Drop polygons where depth is 0 or NaN
    gdf = gdf[(gdf["current_water_depth"] > 0) & (~gdf["current_water_depth"].isna())]

    if len(gdf) == 0:
        print("No buildings with water depth > 0. Nothing to write.")
        return
 
    # Save updated GeoJSON safely
    gdf.to_file(output_geojson, driver="GeoJSON")



def assign_risk_index2(config):
    """
    Assign risk index (1-4) to buildings based on current_water_depth and thresholds in config.

    Parameters
    ----------
    buildings_geojson : str or Path
        Input GeoJSON of buildings (must have 'current_water_depth').
    config_path : str or Path
        Path to JSON config with thresholds, e.g.,
        {"risk_1": 0.5, "risk_2": 1.0, "risk_3": 2.0}.
    output_geojson : str or Path
        Output GeoJSON with new column 'risk_index'.
    """

    thresholds = [
        config.get("risk_1", 0),
        config.get("risk_2", 0),
        config.get("risk_3", 0)
    ]
    buildings_geojson = os.path.join(config['buildingsfolder'], "extracted_buildings.geojson")

    # Load GeoJSON
    gdf = gpd.read_file(buildings_geojson)

def assign_risk_index(config):
    import geopandas as gpd

    # Load the updated GeoJSON that has current_water_depth
    buildings_geojson = os.path.join(config['riskfolder'], "building_risk_output_future.geojson")
    output_geojson = os.path.join(config['riskfolder'], "building_risk_output_future.geojson")
    gdf = gpd.read_file(buildings_geojson)  # make sure this is the file from extract_depth_at_buildings

    # Thresholds from config
    thresholds = config['depth_thresholds']

    def risk_value(depth):
        if depth <= thresholds[0]:
            return 1
        elif depth <= thresholds[1]:
            return 2
        elif depth <= thresholds[2]:
            return 3
        elif depth > thresholds[2]:
            return 4
        else:
            return 4

    # Apply function
    # Add column with proper name and dtype
    #gdf["risk_index"] = np.array(depth, dtype=float)
    tmpval = 0.0
    #gdf["risk_index"] = np.array([tmpval], dtype=float)

    gdf["risk_index"] = gdf["current_water_depth"].apply(lambda x: risk_value(x) if x is not None else None)

    # Save updated GeoJSON
    gdf.to_file(output_geojson, driver="GeoJSON")

def remove_duplicates(config):
    """
    Remove duplicate buildings from the GeoDataFrame based on their geometry.
    """
    buildings_geojson_now = os.path.join(config['riskfolder'], "building_risk_output.geojson")
    buildings_geojson_future = os.path.join(config['riskfolder'], "building_risk_output_future.geojson")
    gdf1 = gpd.read_file(buildings_geojson_now)
    gdf2 = gpd.read_file(buildings_geojson_future)

    # Normalize geometries (remove metadata differences)
    gdf1["geometry"] = gdf1["geometry"].apply(lambda g: g.normalize())
    gdf2["geometry"] = gdf2["geometry"].apply(lambda g: g.normalize())

    # Get unique geometries from the first file
    geom_set1 = set(gdf1["geometry"])

    # Filter gdf2 so it only keeps geometries not in gdf1
    gdf2_clean = gdf2[~gdf2["geometry"].isin(geom_set1)]

    # Save cleaned second GeoJSON
    gdf2_clean.to_file(buildings_geojson_future, driver="GeoJSON")

    print(f"Removed {len(gdf2) - len(gdf2_clean)} duplicate geometries from {gj2}")
    #return gdf2_clean
    #gdf.to_file(buildings_geojson_future, driver="GeoJSON")


def risk(config):
    """
    Compute risk metrics for buildings based on HAND and water depth.

    Parameters
    ----------
    config : dict
        Configuration dictionary with paths to input/output files.
    """
    datadir = config['mainprojectfolder']
    hand_raster_path = os.path.join(datadir, "hand.tif")
    buildings_geojson = os.path.join(config['buildingsfolder'], "extracted_buildings.geojson")
    #new files: 
    temp_raster_path = os.path.join(config['riskfolder'], "temp_future.tif")
    depth_raster_path = os.path.join(config['riskfolder'], "depth_future.tif")
    output_geojson = os.path.join(config['riskfolder'], "building_risk_output_future.geojson")

    # Process HAND raster
    process_hand_raster(config, hand_raster_path, temp_raster_path, depth_raster_path)

    # Extract depth at buildings
    extract_depth_at_buildings(config, buildings_geojson, depth_raster_path, output_geojson)

    #assign risk value
    assign_risk_index(config)

    #remove duplicates
    remove_duplicates(config)

    #######to comment out later:
 #for testing, code it: 
config_file = "D:/g20/src/config/config.yaml"
with open(config_file, 'r') as f: 
    config = yaml.safe_load(f)


risk(config)