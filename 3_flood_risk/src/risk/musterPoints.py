import os
import yaml
import geopandas as gpd
import rasterio
import rasterio.features
import rasterio.mask
import numpy as np
from shapely.geometry import shape, Polygon, MultiPolygon
from shapely.ops import unary_union
from sklearn.cluster import KMeans



def evac_pts(config):
    flood_raster_path = os.path.join(config["riskfolder"], "depth.tif")
    road_data_path = os.path.join(config["intermedieatefiles"], "streets.geojson")
    hospital_data_path = os.path.join(config["intermedieatefiles"], "facilities.geojson")
    park_data_path = os.path.join(config["intermedieatefiles"], "parks.geojson")
    dem_raster_path = os.path.join(config["mainprojectfolder"], "final_hydro_conditioned_masked.tif")

    elevation_threshold = 50  # meters
    max_distance = 2000       # meters

    # === STEP 1: Identify dry land from flood raster ===
    with rasterio.open(flood_raster_path) as src:
        flood_data = src.read(1)
        flood_data[flood_data == -32768] = np.nan  # handle NoData
        flood_mask = np.isnan(flood_data) | (flood_data == 0)  # dry land
        transform = src.transform
        dry_shapes = list(rasterio.features.shapes(flood_mask.astype(np.uint8), transform=transform))
        dry_polygons = [shape(geom) for geom, val in dry_shapes if val == 1]

    if not dry_polygons:
        raise ValueError("No dry areas found in the flood raster.")

    # Merge dry polygons
    dry_union = unary_union(dry_polygons)

    # === STEP 2: Split into 100 polygons using clustering ===
    if isinstance(dry_union, Polygon):
        dry_geoms = [dry_union]
    elif isinstance(dry_union, MultiPolygon):
        dry_geoms = list(dry_union.geoms)
    else:
        dry_geoms = []

    if len(dry_geoms) < 2:
        raise ValueError("Not enough dry polygons to perform clustering.")

    if len(dry_geoms) < 100:
        print(f"Only {len(dry_geoms)} dry polygons found. Skipping clustering.")
        split_polygons = dry_geoms
    else:
        coords = np.array([poly.centroid.coords[0] for poly in dry_geoms])
        if coords.ndim != 2 or coords.shape[0] == 0:
            raise ValueError("No valid centroid coordinates for clustering.")
        kmeans = KMeans(n_clusters=100, random_state=0).fit(coords)
        clusters = [[] for _ in range(100)]
        for poly in dry_geoms:
            cluster_idx = kmeans.predict([poly.centroid.coords[0]])[0]
            clusters[cluster_idx].append(poly)
        split_polygons = [unary_union(cluster) for cluster in clusters]

    gdf = gpd.GeoDataFrame(geometry=split_polygons, crs="EPSG:4326")

    # === STEP 3: Filter by proximity to roads (only LineString geometries) ===
    roads = gpd.read_file(road_data_path).to_crs(gdf.crs)
    roads = roads[roads.geometry.type == "LineString"]
    gdf = gdf[gdf.geometry.apply(lambda x: roads.distance(x).min() <= max_distance)]

    # === STEP 4: Filter by elevation ===
    with rasterio.open(dem_raster_path) as dem_src:
        def get_mean_elevation(polygon):
            try:
                out_image, _ = rasterio.mask.mask(dem_src, [polygon], crop=True)
                valid = out_image[out_image != dem_src.nodata]
                return valid.mean() if valid.size > 0 else 0
            except:
                return 0

        gdf["mean_elevation"] = gdf.geometry.apply(get_mean_elevation)
        gdf = gdf[gdf["mean_elevation"] > elevation_threshold]

    # === STEP 5: Check proximity to hospitals and parks ===
    hospitals = gpd.read_file(hospital_data_path).to_crs(gdf.crs)
    parks = gpd.read_file(park_data_path).to_crs(gdf.crs)
    parks = parks[parks.geometry.type == "Polygon"]

    gdf["hospital_dist"] = gdf.geometry.apply(lambda x: hospitals.distance(x).min())
    gdf["park_dist"] = gdf.geometry.apply(lambda x: parks.distance(x).min())

    # === STEP 6: Score sites ===
    gdf["score"] = -gdf["hospital_dist"] - gdf["park_dist"]

    # === STEP 7: Save results ===
    gdf_sorted = gdf.sort_values(by="score", ascending=False).iloc[1:]

    outfile = os.path.join(config["intermedieatefiles"], "ideal_evacuation_sites.geojson")
    gdf_sorted.to_file(outfile, driver="GeoJSON")

    print("Evacuation sites saved to ideal_evacuation_sites.geojson")

# === CONFIGURATION ===
config_file = "D:/g20/src/config/config.yaml"
with open(config_file, "r") as f:
    config = yaml.safe_load(f)

 main_musterpoints(config)