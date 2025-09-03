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
    bingblds(config)


def bingblds_specificquadkeys(config):
    # Connect to the STAC API
    catalog = Client.open("https://planetarycomputer.microsoft.com/api/stac/v1")

    # Search for items by quadkey
    search = catalog.search(
        collections=["ms-buildings"],
        query={"msbuildings:quadkey": {"eq": "30030330002"}}
    )

    items = list(search.get_items())
    item = items[0]

    # Access the Delta table URL
    delta_url = item.assets["delta"].href

    # Use fsspec to read the GeoParquet file
    gdf = gpd.read_parquet(delta_url)

    # Save to GeoJSON
    gdf.to_file("buildings_quadkey_30030330002.geojson", driver="GeoJSON")

    ###or:
    import msfootprint as msf
    from pathlib import Path

    boundary = config['projectboundary']
    output_dir = config['buildingsfolder']
    countryISO = "ZA"  # For Canada

    msf.BuildingFootprintwithISO(countryISO, boundary, output_dir)



import os
import requests
import zipfile
import geopandas as gpd
from pystac_client import Client

def bingblds(config):

    boundary = config['projectboundary']
    output_dir = config['buildingsfolder']
    os.makedirs(output_dir, exist_ok=True)
    os.chdir(output_dir)

    # Load your polygon
    input_gdf = gpd.read_file(boundary).to_crs(epsg=4326)

    zip_name = "ne_110m_admin_0_countries.zip"
    url = ("https://github.com/nvkelso/natural-earth-vector/raw/master/"
           f"110m_cultural/{zip_name}")

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

    # Load country boundaries
    world = gpd.read_file("ne_110m_admin_0_countries.shp")

    # Identify intersecting country
    intersecting_country = gpd.sjoin(input_gdf, world, how="left", predicate="intersects")
    country_iso = intersecting_country.iloc[0]['ISO_A3']
    print(f"Identified country ISO code: {country_iso}")

    # Map ISO_A3 → ms-buildings region
    iso_to_region = {
        "USA": "us",
        "CAN": "canada",
        "NGA": "nigeria",
        "TZA": "tanzania",
        "UGA": "uganda",
        "KEN": "kenya",
        "ETH": "ethiopia",
        "GHA": "ghana",
        "ZAF": "south_africa",

        # extend mapping as needed
    }
    region = iso_to_region.get(country_iso, country_iso.lower())
    print(f"Using ms-buildings region: {region}")

    # Connect to STAC API
    catalog = Client.open("https://planetarycomputer.microsoft.com/api/stac/v1")

    # Search for building footprints
    search = catalog.search(
        collections=["ms-buildings"],
        query={"msbuildings:region": {"eq": region}}
    )
    items = list(search.get_items())

    if not items:
        # Debug: list available regions
        print(f"No building data found for '{region}'. Checking available regions...")
        all_items = list(catalog.search(collections=["ms-buildings"]).get_items())
        available_regions = sorted(set(i.properties.get("msbuildings:region") for i in all_items))
        raise ValueError(
            f"No building footprint data for region='{region}' (from ISO={country_iso}).\n"
            f"Available regions: {available_regions}"
        )

    # Load building footprints
    delta_url = items[0].assets["delta"].href
    buildings_gdf = gpd.read_parquet(delta_url)

    # Clip to your polygon
    buildings_clipped = gpd.clip(buildings_gdf, input_gdf)

    # Save to GeoJSON
    outfile = os.path.join(output_dir, "extracted_buildings.geojson")
    buildings_clipped.to_file(outfile, driver="GeoJSON")
    print(f"Saved clipped buildings to: {outfile}")


mainbuildings(config_file)