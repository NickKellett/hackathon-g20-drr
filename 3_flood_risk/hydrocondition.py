# Standard library imports
import os
import time
import glob
import itertools
import shutil
import argparse
from pathlib import Path

# Third-party imports
import yaml
import numpy as np
import rasterio
from rasterio.mask import mask
from rasterio.merge import merge
from rasterio.enums import Resampling
from rasterio import features
import geopandas as gpd
from shapely.geometry import box, shape, Point
import matplotlib.pyplot as plt
import fiona
from pyproj import CRS

# Whitebox tools
import whitebox
from whitebox.whitebox_tools import WhiteboxTools




os.environ.setdefault("RUST_BACKTRACE", "full")
#python myscript.py --input data/file1.csv 
parser = argparse.ArgumentParser(description="Run flood driver modelling")
parser.add_argument("--config_file", required=True, help="Path to config file")

#for testing, code it: 
config_file = "D:/g20/src/config/config.yaml"

# --------------------------
# functions:
# --------------------------
def hydrocondition_dtm(config, dtm):
    #for pitfilling.. etc prep for hydro conditioning and HAND
    BASE_DIR = config["mainprojectfolder"]
    saf = config['projectboundary']
    wd = BASE_DIR
    wbt = WhiteboxTools()
    wbt.set_working_dir(wd)
    ## but licensed
    #cop_backup = 'D:/g20/durban/dtm/copglo30/rasters_COP30/cop30.tif'
    
    wbt.fill_missing_data(dtm, 'fillnas.tif', filter=11, weight=0.5)
    wbt.fill_single_cell_pits('fillnas.tif', "pit_filled.tif")
    #for breacch depressions, need a distance, need to get that from raster:
    wbt.breach_depressions_least_cost("pit_filled.tif", "hydro_conditioned.tif", dist=10, fill=True)
    wbt.fill_depressions_wang_and_liu("hydro_conditioned.tif", "final_hydro_conditioned.tif")
    fhc = os.path.join(wd, "final_hydro_conditioned.tif")
    fhf = os.path.join(wd, "final_hydro_conditioned_masked.tif")
    mask_final_hydro_conditioned(fhc, saf,  fhf)


def hand(config, dtmconditioned):
    BASE_DIR = config["mainprojectfolder"]
    threshold_stream = config['streamthres']
    sd = config['snap_distance']
    wd = BASE_DIR
    wbt = WhiteboxTools()
    wbt.set_working_dir(wd)
    #now stream and stuff: 
    wbt.d8_flow_accumulation(dtmconditioned, "fac.tif", out_type="specific contributing area", clip=True)
    #find upper quantile from fac.
    #q = quantile_fac(config, "fac.tif")
    #q = round(q, 3)
    #print(q)
    wbt.d8_pointer(dtmconditioned, "fdr.tif")
    wbt.extract_streams("fac.tif", "streams.tif", threshold = threshold_stream)
    wbt.raster_streams_to_vector("streams.tif", "fdr.tif", "streams.shp")
    save_prj_from_raster(os.path.join(wd, "streams.tif"), os.path.join(wd, "streams.shp"))

    #now get dangles ** need to add path:
    get_dangles(config, "streams.shp", 'dangles.shp')
    wbt.jenson_snap_pour_points('dangles.shp', 'streams.shp', 'jsp.shp', snap_dist=sd)
                                
                                    ## get only certain order streams: 
    stream_select(config, "streams.tif",  sr="streams_selected.tif", streamshp="streams_selected.shp")

    #lastly, get hand: 
    wbt.elevation_above_stream(dtmconditioned, "streams.tif", "hand.tif")


def save_prj_from_raster(raster_path, shapefile_path):
    """
    Reads raster CRS and writes a .prj file for a shapefile.
    
    Parameters
    ----------
    raster_path : str or Path
        Path to the raster file.
    shapefile_path : str or Path
        Path to the shapefile (used to name the .prj file).
    """
    raster_path = Path(raster_path)
    shapefile_path = Path(shapefile_path)
    
    # Read raster CRS
    with rasterio.open(raster_path) as src:
        crs = src.crs
    
    if crs is None:
        raise ValueError("Raster has no CRS")
    
    # Convert to WKT
    crs_wkt = CRS.from_user_input(crs).to_wkt()
    
    # Save .prj file
    prj_file = shapefile_path.with_suffix(".prj")
    with open(prj_file, "w") as f:
        f.write(crs_wkt)
    
    print(f".prj file saved to {prj_file}")


def stream_select(config, streamrastertif,  sr="streams_selected.tif", streamshp="streams_selected.shp"):
    """
    Compute a stream order raster, reclassify by threshold, and convert to vector.
    
    Parameters
    ----------
    streamrastertif : str
        Output path for the stream order raster (GeoTIFF).
    sttype : str
        Stream order type: 'Hack', 'Topological', 'Horton', or 'Strahler'.
    stval : int
        Threshold stream order value for selection.
    sr : str, optional
        Output path for reclassified raster.
    streamshp : str, optional
        Output path for stream shapefile.
    """
    BASE_DIR = config["mainprojectfolder"]
    wd = BASE_DIR
    wbt = WhiteboxTools()
    wbt.set_working_dir(wd)
    sttype = config['stream_so']
    stval = config['stream_so_val']
    wd = config["mainprojectfolder"]

    # Run appropriate WhiteboxTools stream ordering
    if sttype == "Hack":
        wbt.hack_stream_order(d8_pntr="fdr.tif", streams="streams.tif", output=sr)
        reclass_rules = [(0, stval, 1), (stval + 0.5, 100, np.nan)]

    elif sttype == "Topological":
        wbt.topological_stream_order(d8_pntr="fdr.tif", streams="streams.tif", output=sr)
        reclass_rules = [(0, stval, 1), (stval + 0.5, 100, np.nan)]

    elif sttype == "Horton":
        wbt.horton_stream_order(d8_pntr="fdr.tif", streams="streams.tif", output=sr)
        reclass_rules = [(0, stval - 0.5, np.nan), (stval, 100, 1)]

    elif sttype == "Strahler":
        wbt.strahler_stream_order(d8_pntr="fdr.tif", streams="streams.tif", output=sr)
        reclass_rules = [(0, stval - 0.5, np.nan), (stval, 100, 1)]

    else:
        raise ValueError("sttype must be one of: Hack, Topological, Horton, Strahler")

    print("Stream order raster generated:", sr)

    # --- Reclassify raster ---
    str_path = os.path.join(wd, sr)
    with rasterio.open(str_path) as src:
        arr = src.read(1, masked=True)
        profile = src.profile

        # Start with NaN everywhere
        out_arr = np.full(arr.shape, np.nan, dtype="float32")

        for low, high, val in reclass_rules:
            mask = (arr >= low) & (arr < high)
            out_arr[mask] = val

    # Save reclassified raster
    str_path = os.path.join(wd, 'stream-reclassed.tif')
    profile.update(dtype="float32", nodata=np.nan)
    with rasterio.open(str_path, "w", **profile) as dst:
        dst.write(out_arr, 1)

    print("Reclassified raster saved to:", str_path)






##may not need:
def get_dangles(config, streamshp, outppts):
    """
    Reads a stream shapefile, extracts start/end points (dangles), 
    and writes them to a new point shapefile.

    Parameters
    ----------
    streamshp : str
        Path to the input streams shapefile (LineString/MultiLineString).
    outppts : str
        Path to output point shapefile.
    """
    # Read stream shapefile
    wd = config['mainprojectfolder']

    sfls = gpd.read_file(os.path.join(wd, streamshp))

    # Plot streams for inspection
    sfls.plot()
    plt.title("Input Streams")
    plt.show()

    dangle_points = []

    for geom in sfls.geometry:
        if geom is None:
            continue
        
        # Handle LineString vs MultiLineString
        if geom.geom_type == "LineString":
            coords = list(geom.coords)
            dangle_points.append(Point(coords[0]))       # first vertex
            dangle_points.append(Point(coords[-1]))      # last vertex

        elif geom.geom_type == "MultiLineString":
            for line in geom.geoms:
                coords = list(line.coords)
                dangle_points.append(Point(coords[0]))
                dangle_points.append(Point(coords[-1]))

    # Build GeoDataFrame from points
    sfls_ends = gpd.GeoDataFrame(geometry=dangle_points, crs=sfls.crs)

    # Save to file
    sfls_ends.to_file(os.path.join(wd, outppts), driver="ESRI Shapefile")

    print("Finished: get_dangles function") 



def quantile_fac(config, fac):
    BASE_DIR = config["mainprojectfolder"]
    # Open raster
    with rasterio.open(os.path.join(BASE_DIR, fac)) as src:
        data = src.read(1, masked=True)  # read first band, mask NoData values

    # Flatten the array and drop masked/nodata values
    valid_data = data.compressed()  

    # Compute quantiles
    probs = [config["q_lower"], config["q_upper"]]
    quantiles = np.quantile(valid_data, probs)

    print(f"Quantiles at {probs}: {quantiles}")
    qr = quantiles[1]
    return(qr)

############################

def clip_rasters_bound(study_area_file, raster_to_clip, output_path):
    import rasterio
    from rasterio.mask import mask
    from rasterio.merge import merge
    from shapely.geometry import box
    import geopandas as gpd
    import glob
    import os

    # Read and buffer study area
    study_area_gdf = gpd.read_file(study_area_file)
    study_area_gdf = study_area_gdf.to_crs(study_area_gdf.crs)
    study_area_geom = study_area_gdf.geometry.buffer(0.001)
    study_area_union = study_area_geom.unary_union
    study_area_crs = study_area_gdf.crs.to_wkt()

    # Find all .tif files in the folder
    tif_files = glob.glob(os.path.join(raster_to_clip, "*.tif"))

    # If no rasters, return None
    if not tif_files:
        print("No .tif files found in", raster_to_clip)
        return None

    # If only one raster, clip and save as dtm_clipped.tif
    if len(tif_files) == 1:
        tif = tif_files[0]
        with rasterio.open(tif) as src:
            # Reproject if needed
            if src.crs.to_wkt() != study_area_crs:
                import rasterio.warp
                dst_crs = study_area_crs
                transform, width, height = rasterio.warp.calculate_default_transform(
                    src.crs, dst_crs, src.width, src.height, *src.bounds)
                kwargs = src.meta.copy()
                kwargs.update({
                    'crs': dst_crs,
                    'transform': transform,
                    'width': width,
                    'height': height
                })
                reprojected_path = tif.replace(".tif", "_reproj.tif")
                with rasterio.open(reprojected_path, 'w', **kwargs) as dst:
                    for i in range(1, src.count + 1):
                        rasterio.warp.reproject(
                            source=rasterio.band(src, i),
                            destination=rasterio.band(dst, i),
                            src_transform=src.transform,
                            src_crs=src.crs,
                            dst_transform=transform,
                            dst_crs=dst_crs,
                            resampling=rasterio.enums.Resampling.nearest)
                src_to_clip = rasterio.open(reprojected_path)
            else:
                src_to_clip = src

            out_image, out_transform = mask(
                src_to_clip, [study_area_union.__geo_interface__], crop=True
            )
            out_meta = src_to_clip.meta.copy()
            out_meta.update({
                "driver": "GTiff",
                "height": out_image.shape[1],
                "width": out_image.shape[2],
                "transform": out_transform,
                "crs": study_area_crs
            })
            with rasterio.open(output_path, "w", **out_meta) as dest:
                dest.write(out_image)
            if src_to_clip != src:
                src_to_clip.close()
        return output_path

    # If more than one raster, clip those that overlap and mosaic
    clipped_rasters = []
    for tif in tif_files:
        with rasterio.open(tif) as src:
            # Reproject if needed
            if src.crs.to_wkt() != study_area_crs:
                import rasterio.warp
                dst_crs = study_area_crs
                transform, width, height = rasterio.warp.calculate_default_transform(
                    src.crs, dst_crs, src.width, src.height, *src.bounds)
                kwargs = src.meta.copy()
                kwargs.update({
                    'crs': dst_crs,
                    'transform': transform,
                    'width': width,
                    'height': height
                })
                reprojected_path = tif.replace(".tif", "_reproj.tif")
                with rasterio.open(reprojected_path, 'w', **kwargs) as dst:
                    for i in range(1, src.count + 1):
                        rasterio.warp.reproject(
                            source=rasterio.band(src, i),
                            destination=rasterio.band(dst, i),
                            src_transform=src.transform,
                            src_crs=src.crs,
                            dst_transform=transform,
                            dst_crs=dst_crs,
                            resampling=rasterio.enums.Resampling.nearest)
                src_to_clip = rasterio.open(reprojected_path)
            else:
                src_to_clip = src

            # Check intersection
            raster_bounds = src_to_clip.bounds
            raster_box = box(*raster_bounds)
            if not study_area_union.intersects(raster_box):
                if src_to_clip != src:
                    src_to_clip.close()
                continue

            # Clip raster
            out_image, out_transform = mask(
                src_to_clip, [study_area_union.__geo_interface__], crop=True
            )
            out_meta = src_to_clip.meta.copy()
            out_meta.update({
                "driver": "GTiff",
                "height": out_image.shape[1],
                "width": out_image.shape[2],
                "transform": out_transform,
                "crs": study_area_crs
            })
            clipped_path = tif.replace(".tif", "_clipped_tmp.tif")
            with rasterio.open(clipped_path, "w", **out_meta) as dest:
                dest.write(out_image)
            clipped_rasters.append(clipped_path)
            if src_to_clip != src:
                src_to_clip.close()

    if not clipped_rasters:
        print("No rasters overlapped the study area.")
        return None

    # Mosaic all clipped rasters
    src_files_to_mosaic = [rasterio.open(fp) for fp in clipped_rasters]
    mosaic, out_trans = merge(src_files_to_mosaic)
    out_meta = src_files_to_mosaic[0].meta.copy()
    out_meta.update({
        "driver": "GTiff",
        "height": mosaic.shape[1],
        "width": mosaic.shape[2],
        "transform": out_trans,
        "crs": study_area_crs
    })
    with rasterio.open(output_path, "w", **out_meta) as dest:
        dest.write(mosaic)
    for src in src_files_to_mosaic:
        src.close()
    # Optionally, clean up tmp files
    for fp in clipped_rasters:
        os.remove(fp)
    return output_path

def mask_final_hydro_conditioned(input_raster, study_area_file, output_raster):
    # Read study area geometry using fiona
    with fiona.open(study_area_file, "r") as shapefile:
        geoms = [feature["geometry"] for feature in shapefile]

    with rasterio.open(input_raster) as src:
        out_image, out_transform = mask(
            src, geoms, crop=True, nodata=src.nodata if src.nodata is not None else -9999
        )
        out_meta = src.meta.copy()
        out_meta.update({
            "driver": "GTiff",
            "height": out_image.shape[1],
            "width": out_image.shape[2],
            "transform": out_transform,
            "nodata": src.nodata if src.nodata is not None else -9999
        })

        with rasterio.open(output_raster, "w", **out_meta) as dest:
            dest.write(out_image)

def main(config_file):
    with open(config_file, 'r') as f: 
        config = yaml.safe_load(f)
    
    BASE_DIR = config["mainprojectfolder"]
    study_area = config['projectboundary']
    
    dem_folder = config['dtm_folder']
    

    #merge/clip dems.
    output_raster = os.path.join(BASE_DIR, "dtm_clipped.tif")
    dtm_raster = clip_rasters_bound(study_area, dem_folder, output_raster)
    dtm = glob.glob(os.path.join(BASE_DIR, "dtm_clipped.tif"))
    

    #now, hydro condition. 
    hydrocondition_dtm(config, "dtm_clipped.tif")

    #now hand:
    hand(config, "final_hydro_conditioned_masked.tif")
    # Move all .tif files except 'hand.tif'
    
    """ # Paths
    src_dir = config['mainprojectfolder']
    dst_dir = config['intermedieatefiles']
    dst_dir.mkdir(parents=True, exist_ok=True)

    # Move all .tif files except 'hand.tif'
    for tif in src_dir.glob("*.tif"):
        if tif.name != "hand.tif":
            dest_file = dst_dir / tif.name
            if dest_file.exists():
                dest_file.unlink()  # remove existing file
            shutil.move(str(tif), dest_file)
    print("Done! All .tif files (except hand.tif) moved to:", dst_dir)  
 """

main(config_file)