import os
import yaml

import geopandas as gpd
import datacube
from datacube import Datacube
from datacube.utils import geometry
import rasterio
import numpy as np


import numpy as np
import xarray as xr
import matplotlib.pyplot as plt

from deafrica_tools.plotting import display_map
from deafrica_tools.load_era5 import load_era5
from odc.algo import xr_reproject

def main_extract_dem_copglo30(config):
    """
    Extract COP-DEM GLO-30 DSM clipped to the GeoJSON boundary, and save as GeoTIFF.

    Parameters:
    - input_geojson (str): Path to your GeoJSON file (with polygon AOI).
    - output_tiff (str): Path to the output clipped DSM GeoTIFF.
    - resolution (tuple, optional): Output resolution (y, x) in degrees; default ~30 m per pixel.
    """
    # 1. Load AOI
    input_geojson = config['projectboundary']
    output_tiff = os.path.join( config['dtm_folder'] + "dem_copglo30_clipped.tif")
    gdf = gpd.read_file(input_geojson)
    # Use the union of all geometries
    union_geom = gdf.unary_union
    # Create ODC geometry object
    geom = geometry.Geometry(union_geom, gdf.crs)

    # 2. Connect to the Datacube
    dc = Datacube(app='DEM')

    # 3. Set resolution (defaults to approximately 30 m)
    if resolution is None:
        res = (0.0003, 0.0003)  # ~30 m at Equator
    else:
        res = resolution

    # 4. Load the Copernicus GLO-30 DSM product
    ds = dc.load(
        product='dem_cop_30',
        measurements=['elevation'],
        geobox=dc.geobox(geometry=geom, resolution=res),
        output_crs='EPSG:4326',
        group_by='solar_day',
        time=None  # product is static (no time dimension)
    )

    if ds is None or 'elevation' not in ds:
        raise ValueError("Could not load COP-DEM GLO-30 for the given AOI.")

    elevation = ds.elevation.squeeze()

    # 5. Mask outside the AOI polygon
    mask = ds.geobox.extent.to_crs(gdf.crs).mask(geom)
    elevation = elevation.where(mask, np.nan)

    # 6. Save as GeoTIFF
    transform = ds.geobox.transform
    with rasterio.open(
        output_tiff,
        'w',
        driver='GTiff',
        height=elevation.shape[0],
        width=elevation.shape[1],
        count=1,
        dtype=elevation.dtype,
        crs='EPSG:4326',
        transform=transform,
        nodata=np.nan
    ) as dst:
        dst.write(elevation.values, 1)

    print(f"Saved clipped DEM to: {output_tiff}")



config_file = "D:/g20/src/config/config.yaml"
with open(config_file, 'r') as f: 
    config = yaml.safe_load(f)

main_extract_dem_copglo30(config)