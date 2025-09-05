import os
import yaml
import rasterio
from rasterio import features
import geopandas as gpd
from shapely.geometry import shape
import geopandas as gpd
import numpy as np
from shapely.geometry import box

def raster_nodata_to_polygons(config, nodata_value=-32768):
    """
    Extract nodata pixels from a raster and save them as polygons.
    """

    raster_path = os.path.join(config['riskfolder'], "depth.tif")
    output_path = os.path.join(config['intermedieatefiles'], "nonflood_polygons.geojson")

    with rasterio.open(raster_path) as src:
        data = src.read(1)
        transform = src.transform
        crs = src.crs

        # Create a mask where nodata values are 1
        mask = (data == nodata_value).astype("uint8")

        # Convert to polygons
        polygons = []
        for geom, val in features.shapes(mask, transform=transform):
            if val == 1:  # only nodata
                polygons.append(shape(geom))

        if not polygons:
            print("⚠️ No nodata polygons found.")
            return

        gdf = gpd.GeoDataFrame(geometry=polygons, crs=crs)
        gdf.to_file(output_path, driver="GeoJSON")
        print(f"✅ Nodata polygons saved to {output_path}")

def intersect_parks_and_dry(config):
    # Load both layers
    parks_path = os.path.join(config['intermedieatefiles'], "parks.geojson")
    dry_path = os.path.join(config['intermedieatefiles'], "nonflood_polygons.geojson")
    output_path = os.path.join(config['intermedieatefiles'], "dry_parks_intersection.geojson")
    parks = gpd.read_file(parks_path)
    parks = parks[parks.geometry.type.isin(["Polygon", "MultiPolygon"])]
    dry = gpd.read_file(dry_path)

    # Ensure CRS matches
    if parks.crs != dry.crs:
        dry = dry.to_crs(parks.crs)

    # Intersect
    dryparks = gpd.overlay(parks, dry, how="intersection")

    # Save result
    dryparks.to_file(output_path, driver="GeoJSON")
    print(f"✅ Saved {len(dryparks)} intersecting polygons to {output_path}")



def distance_parks_to_facilities(config):
    # Load data
    parks_path = os.path.join(config['intermedieatefiles'], "dry_parks_intersection.geojson")
    facilities_path = os.path.join(config['intermedieatefiles'], "facilities.geojson")
    output_path = os.path.join(config['intermedieatefiles'], "parks_with_facility_distances.geojson")

    parks = gpd.read_file(parks_path)
    facilities = gpd.read_file(facilities_path)

    # Keep only polygons/multipolygons from parks
    parks = parks[parks.geometry.type.isin(["Polygon", "MultiPolygon"])]

    # Ensure CRS matches
    if parks.crs != facilities.crs:
        facilities = facilities.to_crs(parks.crs)

    # Compute nearest distance (polygon edge to facility point)
    def nearest_distance(park_geom):
        return facilities.distance(park_geom).min()

    parks["nearest_facility_dist"] = parks.geometry.apply(nearest_distance)

    # Save result
    parks.to_file(output_path, driver="GeoJSON")
    print(f"✅ Saved with distances to {output_path}")



def distance_parks_to_streets(config):
    # Load data
    streets_path = os.path.join(config['intermedieatefiles'], 'streets.geojson')
    parks_path = os.path.join(config['intermedieatefiles'], "parks_with_facility_distances.geojson")
    output_path = os.path.join(config['intermedieatefiles'], "parks_with_street_distances.geojson")

    parks = gpd.read_file(parks_path)
    streets = gpd.read_file(streets_path)

    # Keep only polygons/multipolygons for parks
    parks = parks[parks.geometry.type.isin(["Polygon", "MultiPolygon"])]

    # Keep only LineString for streets
    streets = streets[streets.geometry.type == "LineString"]

    # Ensure CRS match
    if parks.crs != streets.crs:
        streets = streets.to_crs(parks.crs)

    # Split streets into all vs motorway only
    motorways = streets[streets["highway"] == "motorway"]

    # Distance to nearest street
    def nearest_distance(geom, gdf):
        if gdf.empty:
            return None
        return gdf.distance(geom).min()

    parks["dist_to_street"] = parks.geometry.apply(lambda g: nearest_distance(g, streets))
    parks["dist_to_motorway"] = parks.geometry.apply(lambda g: nearest_distance(g, motorways))

    # Save
    parks.to_file(output_path, driver="GeoJSON")
    print(f"✅ Saved with street + motorway distances: {output_path}")


def rank_polygons(config):
    # Load polygons
    input_path = os.path.join(config['intermedieatefiles'], "parks_with_street_distances.geojson")
    output_polygons = os.path.join(config['intermedieatefiles'], "ranked_evacuationsites.geojson")
    output_sites = os.path.join(config['intermedieatefiles'], "ideal_evacuation_sites.geojson")

    gdf = gpd.read_file(input_path)

    # Ensure required columns exist
    for col in ["dist_to_motorway", "nearest_facility_dist", "dist_to_street"]:
        if col not in gdf.columns:
            raise ValueError(f"Missing required column: {col}")

    # Replace NaN with large value (so missing data doesn't rank high)
    gdf[["dist_to_motorway", "nearest_facility_dist", "dist_to_street"]] = \
        gdf[["dist_to_motorway", "nearest_facility_dist", "dist_to_street"]].fillna(1e9)

    # Compute weighted score (lower = better)
    gdf["score"] = (
        0.5 * gdf["dist_to_motorway"] +
        0.3 * gdf["nearest_facility_dist"] +
        0.2 * gdf["dist_to_street"]
    )

    # Rank polygons
    gdf = gdf.sort_values(by="score", ascending=True).reset_index(drop=True)
    gdf["rank"] = gdf.index + 1

    # Save polygons with scores
    gdf.to_file(output_polygons, driver="GeoJSON")
    print(f"✅ Ranked polygons saved: {output_polygons}")

    # Take top 5 polygons → centroids
    top5 = gdf.head(5).copy()
    top5["geometry"] = top5.geometry.centroid

    # Save as new file
    top5.to_file(output_sites, driver="GeoJSON")
    print(f"✅ Top 5 ideal evacuation sites saved: {output_sites}")



def split_polygon_grid(input_geojson, output_geojson, n=100):
    """
    Split polygon(s) from a GeoJSON into ~n equal-sized pieces using a grid.
    """
    gdf = gpd.read_file(input_geojson)
    union_poly = gdf.unary_union  # merge all polygons into one
    
    minx, miny, maxx, maxy = union_poly.bounds
    
    # how many cells along each axis?
    n_cols = int(np.sqrt(n))
    n_rows = int(np.ceil(n / n_cols))
    
    dx = (maxx - minx) / n_cols
    dy = (maxy - miny) / n_rows
    
    cells = []
    for i in range(n_cols):
        for j in range(n_rows):
            cell = box(minx + i*dx, miny + j*dy,
                       minx + (i+1)*dx, miny + (j+1)*dy)
            inter = union_poly.intersection(cell)
            if not inter.is_empty:
                cells.append(inter)
    
    out_gdf = gpd.GeoDataFrame(geometry=cells, crs=gdf.crs)
    out_gdf.to_file(output_geojson, driver="GeoJSON")
    print(f"✅ Split polygon saved to {output_geojson} with {len(out_gdf)} parts")


def main_musterpoints(config):
    raster_nodata_to_polygons(config)
    #input_geojson = os.path.join(config['intermedieatefiles'], "nonflood_polygons.geojson")
    #output_geojson = os.path.join(config['intermedieatefiles'], "nonflood_split_polygons.geojson")
    #split_polygon_grid(input_geojson, output_geojson, n=100)

    intersect_parks_and_dry(config)
    distance_parks_to_facilities(config)
    distance_parks_to_streets(config)
    rank_polygons(config)


# Load Config file: 
import yaml
config_file = "D:/g20/src/config/config.yaml"
with open(config_file, 'r') as f:
    config = yaml.safe_load(f)

main_musterpoints(config)
