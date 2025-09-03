


import os
from logging import config
from pystac_client import Client
import yaml
import geopandas as gpd
import fsspec
import argparse
import geodatasets #for geolocating the country of user input spatial file




parser = argparse.ArgumentParser(description="Run flood driver modelling")
parser.add_argument("--config_file", required=True, help="Path to config file")

#for testing, code it: 
config_file = "D:/g20/src/config/config.yaml"


def mainbuildings(config_file):
    with open(config_file, 'r') as f: 
        config = yaml.safe_load(f)
    hotosm_(config)



import os
import requests
import zipfile
import geopandas as gpd
from pystac_client import Client

def hotosm_(config):

    boundary = config['projectboundary']
    output_dir = config['buildingsfolder']
    os.makedirs(output_dir, exist_ok=True)
    os.chdir(output_dir)

    # Load your polygon
    input_gdf = gpd.read_file(boundary).to_crs(epsg=4326)

    zip_name = "hotosm_zaf_buildings_polygons_shp.zip"
    url = ("https://s3.dualstack.us-east-1.amazonaws.com/production-raw-data-api/ISO3/ZAF/buildings/polygons/hotosm_zaf_buildings_polygons_shp.zip")

    # Step 1: If already extracted, skip everything
    if os.path.isdir(output_dir) and any(fname.endswith(".shp") for fname in os.listdir(output_dir)):
        print(f"Data already extracted in '{output_dir}'. Skipping download/unzip.")
    else:
        if os.path.exists(zip_name):
            print(f"Found local {zip_name}, extracting...")
        else:
            print(f"{zip_name} not found locally. Downloading from {url}...")
            r = requests.get(url)
            r.raise_for_status()
            with open(zip_name, "wb") as f:
                f.write(r.content)
            print(f"Downloaded {zip_name}")

        with zipfile.ZipFile(zip_name, 'r') as zip_ref:
            zip_ref.extractall(output_dir)
        print(f"Extracted contents to '{output_dir}'")

    
    # Load building footprints
    delta_url = "hotosm_zaf_buildings_polygons_shp.shp"
    buildings_gdf = gpd.read_file(delta_url)

    # Clip to your polygon
    buildings_clipped = gpd.clip(buildings_gdf, input_gdf)

    # Save to GeoJSON
    outfile = os.path.join(output_dir, "extracted_buildings.geojson")
    buildings_clipped.to_file(outfile, driver="GeoJSON")
    print(f"Saved clipped buildings to: {outfile}")


mainbuildings(config_file)