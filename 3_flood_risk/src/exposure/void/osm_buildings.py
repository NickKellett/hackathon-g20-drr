import os
import yaml
import os
import yaml
#import arcparse
import geopandas as gpd
import osmnx as ox


def get_osm_buildings(config):
    wd = config['buildingsfolder']
    os.makedirs(wd, exist_ok=True)
    # Load the input GeoJSON polygon
    boundaryfile = config['projectboundary']
    input_polygon = gpd.read_file(boundaryfile)

    # Ensure the polygon is in the correct coordinate reference system
    input_polygon = input_polygon.to_crs(epsg=4326)

    # Get the bounding box of the polygon
    bbox = input_polygon.total_bounds  # [minx, miny, maxx, maxy]

    # Extract building footprints from OpenStreetMap within the bounding box
    tags = {'building': True}
    buildings = ox.geometries.geometries_from_bbox(bbox[3], bbox[1], bbox[2], bbox[0], tags)
    buildings.plot()
    # Clip the buildings to the input polygon
    buildings_clipped = gpd.clip(buildings, input_polygon)

    # Save the clipped buildings to a GeoJSON file
    buildings_clipped.to_file("extracted_buildings.geojson", driver="GeoJSON")

    print("Extracted building polygons have been saved to 'extracted_buildings.geojson'.")


###########################################
######################



def mainbuildings(config_file):
    with open(config_file, 'r') as f: 
        config = yaml.safe_load(f)
    
    get_osm_buildings(config)


mainbuildings(config_file)

import arcparse
import geopandas as gpd
import osmnx as ox


def get_osm_buildings(config):
    wd = config['buildingsfolder']
    os.makedirs(wd, exist_ok=True)
    # Load the input GeoJSON polygon
    boundaryfile = config['projectboundary']
    input_polygon = gpd.read_file(boundaryfile)

    # Ensure the polygon is in the correct coordinate reference system
    input_polygon = input_polygon.to_crs(epsg=4326)

    # Get the bounding box of the polygon
    bbox = input_polygon.total_bounds  # [minx, miny, maxx, maxy]

    # Extract building footprints from OpenStreetMap within the bounding box
    tags = {'building': True}
    buildings = ox.geometries.geometries_from_bbox(bbox[3], bbox[1], bbox[2], bbox[0], tags)
    buildings.plot()
    # Clip the buildings to the input polygon
    buildings_clipped = gpd.clip(buildings, input_polygon)

    # Save the clipped buildings to a GeoJSON file
    buildings_clipped.to_file("extracted_buildings.geojson", driver="GeoJSON")

    print("Extracted building polygons have been saved to 'extracted_buildings.geojson'.")


###########################################

#for testing, code it: 
config_file = "D:/g20/src/config/config.yaml"


def mainbuildings(config_file):
    with open(config_file, 'r') as f: 
        config = yaml.safe_load(f)
    
    get_osm_buildings(config)


mainbuildings(config_file)