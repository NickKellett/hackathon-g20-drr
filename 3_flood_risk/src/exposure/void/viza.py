import os
import geopandas as gpd
import requests

import os
import geopandas as gpd
import requests

import os
import geopandas as gpd
from pystac_client import Client

def bingblds_vida(config):
    boundary = config['projectboundary']
    output_dir = config['buildingsfolder']
    os.makedirs(output_dir, exist_ok=True)
    os.chdir(output_dir)

    # Load your polygon AOI
    input_gdf = gpd.read_file(boundary).to_crs(epsg=4326)

    # --- Identify country from polygon ---
    # Load Natural Earth countries shapefile
    world_shp = config.get('ne_countries_shp', 'ne_110m_admin_0_countries.shp')
    world = gpd.read_file(world_shp).to_crs(epsg=4326)

    intersecting_country = gpd.sjoin(input_gdf, world, how="left", predicate="intersects")
    country_iso = intersecting_country.iloc[0]['ISO_A3']
    print(f"Identified country ISO code: {country_iso}")

    # --- Map ISO_A3 to VIDA region if needed ---
    # VIDA uses ISO_A3 for 'country' field, so we can usually use it directly
    region = country_iso

    # --- Connect to VIDA STAC API ---
    catalog = Client.open("https://data.source.coop/vida/google-microsoft-open-buildings/stac/catalog.json")

    # Search for building footprint assets for this country
    search = catalog.search(
        collections=["google-microsoft-open-buildings"],
        query={"country": {"eq": region}}
    )

    items = list(search.get_items())
    if not items:
        # If nothing found, list available countries
        all_items = list(catalog.search(collections=["google-microsoft-open-buildings"]).get_items())
        available_countries = sorted(set(i.properties.get("country") for i in all_items))
        raise ValueError(
            f"No building footprint data found for country='{region}'.\n"
            f"Available countries: {available_countries}"
        )

    # Get first item's GeoParquet asset
    asset = items[0].assets.get("data")
    if asset is None:
        raise ValueError(f"No 'data' asset found in STAC item for {region}")

    asset_url = asset.href
    print(f"Loading buildings from: {asset_url}")

    # --- Load buildings into GeoPandas ---
    buildings_gdf = gpd.read_parquet(asset_url)

    # --- Clip to AOI ---
    buildings_clipped = gpd.clip(buildings_gdf, input_gdf)

    # --- Save output ---
    outfile = os.path.join(output_dir, "extracted_buildings.geojson")
    buildings_clipped.to_file(outfile, driver="GeoJSON")
    print(f"Saved clipped buildings to: {outfile}")


#for testing, code it: 
config_file = "D:/g20/src/config/config.yaml"


def mainbuildings(config_file):
    with open(config_file, 'r') as f: 
        config = yaml.safe_load(f)
    bingblds_vida(config)


mainbuildings(config_file)
