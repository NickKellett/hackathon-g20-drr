import os
import yaml
import geopandas as gpd
import osmnx as ox
from shapely.geometry import Polygon, MultiPolygon
from shapely.ops import unary_union


def load_aoi(aoi_path):
    gdf = gpd.read_file(aoi_path)
    if gdf.empty:
        raise ValueError("AOI GeoJSON is empty.")

    # dissolve to a single geometry (handles multi-features)
    geom = unary_union(gdf.geometry)
    if not isinstance(geom, (Polygon, MultiPolygon)):
        # if user passed a line/point accidentally, try convex hull
        geom = geom.convex_hull
    # OSMnx expects WGS84
    if gdf.crs is None or gdf.crs.to_epsg() != 4326:
        geom = gpd.GeoSeries([geom], crs=gdf.crs).to_crs(epsg=4326).iloc[0]
    return geom


def fetch_osm_streets(aoi_polygon):
    """Fetch OSM street data within polygon."""
    tags = {"highway": True}
    return ox.features.features_from_polygon(aoi_polygon, tags=tags)


def fetch_osm_facilities(aoi_polygon):
    """Fetch hospitals, police, fire stations within polygon."""
    tags = {
        "amenity": ["hospital", "clinic", "doctors", "police", "fire_station"],
        "emergency": True  # catches features explicitly tagged emergency=yes
    }
    return ox.features.features_from_polygon(aoi_polygon, tags=tags)


def fetch_osm_parks(aoi_polygon):
    """Fetch park/greenspace polygons within polygon."""
    tags = {
        "leisure": ["park", "garden", "playground"],
        "landuse": ["recreation_ground", "grass"],
        "natural": ["wood", "heath"]
    }
    return ox.features.features_from_polygon(aoi_polygon, tags=tags)


def main_osmdata(config):
    out_geojson_streets = os.path.join(config['intermedieatefiles'], "streets.geojson")
    out_geojson_facilities = os.path.join(config['intermedieatefiles'], "facilities.geojson")
    out_geojson_parks = os.path.join(config['intermedieatefiles'], "parks.geojson")

    aoi_geojson = config['projectboundary']
    aoi_gdf = gpd.read_file(aoi_geojson)
    aoi_polygon = aoi_gdf.geometry.iloc[0]

    # Streets
    streets_gdf = fetch_osm_streets(aoi_polygon)
    if streets_gdf.empty:
        print("No OSM street features found in the AOI.")
    else:
        streets_gdf.to_file(out_geojson_streets, driver="GeoJSON")
        print(f"Saved {len(streets_gdf)} streets to {out_geojson_streets}")

    # Facilities
    facilities_gdf = fetch_osm_facilities(aoi_polygon)
    if facilities_gdf.empty:
        print("No OSM care/emergency facilities found in the AOI.")
    else:
        facilities_gdf.to_file(out_geojson_facilities, driver="GeoJSON")
        print(f"Saved {len(facilities_gdf)} facilities to {out_geojson_facilities}")

    # Parks / Greenspaces
    parks_gdf = fetch_osm_parks(aoi_polygon)
    if parks_gdf.empty:
        print("No OSM park/greenspace features found in the AOI.")
    else:
        parks_gdf.to_file(out_geojson_parks, driver="GeoJSON")
        print(f"Saved {len(parks_gdf)} parks to {out_geojson_parks}")


# Example run
config_file = "D:/g20/src/config/config.yaml"
with open(config_file, 'r') as f:
    config = yaml.safe_load(f)

main_osmdata(config)
