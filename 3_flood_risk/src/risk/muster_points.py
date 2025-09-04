import yaml
import os
import geopandas as gpd
import rasterio
from rasterio import features
import numpy as np
from shapely.geometry import shape

def raster_to_polygons(raster_path, nodata_value=-32768, min_pixels=4):
    """
    Convert raster NODATA areas to polygons for evacuation sites.
    
    Parameters
    ----------
    raster_path : str
        Path to the raster.
    nodata_value : int or float
        Raster value that represents NODATA (safe area).
    min_pixels : int
        Minimum number of contiguous pixels to keep as polygon.
    
    Returns
    -------
    GeoDataFrame of polygons
    """
    import rasterio
    from rasterio import features
    import geopandas as gpd
    import numpy as np

    with rasterio.open(raster_path) as src:
        data = src.read(1)
        mask = data == nodata_value  # Only consider NODATA areas
        transform = src.transform

        # Convert masked pixels to polygons
        shapes_gen = features.shapes(data, mask=mask, transform=transform)
        records = []
        for geom, val in shapes_gen:
            # Only keep polygon if it has enough pixels
            geom_area_pixels = np.count_nonzero(mask[features.geometry_mask([shape(geom)], transform=transform, invert=True, out_shape=data.shape)])
            if geom_area_pixels >= min_pixels:
                records.append({"geometry": shape(geom), "value": val})

    if len(records) == 0:
        return gpd.GeoDataFrame(columns=["geometry", "value"], crs=src.crs)

    gdf = gpd.GeoDataFrame.from_records(records, crs=src.crs)
    return gdf



def load_data(flood_raster_path, road_data_path, hospital_data_path, park_data_path):
    """Load flood raster (convert NoData to polygons), roads, hospitals, and parks."""
    flood_polygons = raster_to_polygons(flood_raster_path)
    road_data = gpd.read_file(road_data_path)
    hospital_data = gpd.read_file(hospital_data_path)
    park_data = gpd.read_file(park_data_path)
    return flood_polygons, road_data, hospital_data, park_data


def assess_accessibility(dryland, road_data):
    """Find dryland polygons that intersect with roads (accessible)."""
    road_data = road_data[road_data.geometry.type.isin(["LineString", "MultiLineString"])]
    accessible_dryland = gpd.sjoin(dryland, road_data, how="inner", predicate="intersects")
    return accessible_dryland


def filter_high_and_dryland(accessible_dryland, dem_raster_path, threshold):
    """Filter polygons where DEM elevation > threshold."""
    with rasterio.open(dem_raster_path) as src:
        data = src.read(1, masked=True)

        centroids = accessible_dryland.centroid
        elevations = []
        for point in centroids:
            row, col = src.index(point.x, point.y)
            if 0 <= row < data.shape[0] and 0 <= col < data.shape[1]:
                elevations.append(data[row, col])
            else:
                elevations.append(np.nan)

        accessible_dryland["elevation"] = elevations

    return accessible_dryland[accessible_dryland["elevation"] > threshold]


def find_nearby_services(high_dryland, hospital_data, park_data, max_distance):
    """Keep only sites with hospitals *and* parks nearby."""
    high_dryland["hospital_nearby"] = high_dryland.geometry.apply(
        lambda x: hospital_data.distance(x).min() <= max_distance
    )
    high_dryland["park_nearby"] = high_dryland.geometry.apply(
        lambda x: park_data.distance(x).min() <= max_distance
    )

    return high_dryland[high_dryland["hospital_nearby"] & high_dryland["park_nearby"]]


def main(config):
    flood_raster_path = os.path.join(config["riskfolder"], "depth.tif")
    road_data_path = os.path.join(config["intermedieatefiles"], "streets.geojson")
    hospital_data_path = os.path.join(config["intermedieatefiles"], "facilities.geojson")
    park_data_path = os.path.join(config["intermedieatefiles"], "parks.geojson")
    dem_raster_path = os.path.join(config["mainprojectfolder"], "final_hydro_conditioned_masked.tif")

    elevation_threshold = 50   # meters
    max_distance = 2000        # meters

    flood_data, road_data, hospital_data, park_data = load_data(
        flood_raster_path, road_data_path, hospital_data_path, park_data_path
    )

    dryland = flood_data
    accessible_dryland = assess_accessibility(dryland, road_data)
    high_dryland = filter_high_and_dryland(accessible_dryland, dem_raster_path, elevation_threshold)
    evacuation_sites = find_nearby_services(high_dryland, hospital_data, park_data, max_distance)

    print("Potential Evacuation Sites:")
    print(evacuation_sites)

    out_path = os.path.join(config["intermedieatefiles"], "evacuation_sites.geojson")
    evacuation_sites.to_file(out_path, driver="GeoJSON")
    print(f"Saved evacuation sites to {out_path}")


# Run
config_file = "D:/g20/src/config/config.yaml"
with open(config_file, "r") as f:
    config = yaml.safe_load(f)

main(config)
