""" 
Copyright 2025 Team MapleByte 

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

import rasterio
import numpy as np
from rasterio.enums import Resampling
from rasterio import Affine
from rasterio import features
from rasterio.transform import from_origin
import statistics
import os

import yaml

def main_floodmapping(config):
    """
    Parameters
    ----------
    rasterA_path : str
        Path to raster A (to reclassify).
    rasterB_path : str
        Path to raster B.
    threshold : float
        Threshold for reclassification.
    out_dir : str
        Directory to save outputs.
    """
    rasterA_path = config['rasterA_path']
    rasterB_path = os.path.join(config['mainprojectfolder'], "hand.tif")
    threshold = config['MNDWI_threshold']
    out_dir = config['riskfolder']

    os.makedirs(out_dir, exist_ok=True)

    # -----------------
    # 1. Load raster A and reclassify
    # -----------------
    with rasterio.open(rasterA_path) as src:
        profile = src.profile.copy()
        dataA = src.read(1, masked=True)
        # Reclassify: values < threshold → 1, else nodata
        reclass = np.where(dataA < threshold, 1, -9999)

        # Update profile with valid nodata
        profile.update(dtype=rasterio.int16, nodata=-9999)

        

    reclass_path = os.path.join(out_dir, "SVreclass_raster.tif")
    with rasterio.open(reclass_path, "w", **profile) as dst:
        dst.write(reclass.astype(np.int16), 1)
    print(f"Saved: {reclass_path}")

    # -----------------
    # 2. Mask raster B using reclass_raster
    # -----------------

    from rasterio.warp import reproject, Resampling

# -----------------
# 2. Mask raster B using reclass_raster
# -----------------
    with rasterio.open(rasterB_path) as srcB, rasterio.open(reclass_path) as reclass_src:
        profileB = srcB.profile.copy()
        dataB = srcB.read(1)
        reclass_data = np.empty_like(dataB, dtype=np.int16)

        print("reclass_src.read(1) shape:", reclass_src.read(1).shape)
        print("reclass_data shape:", reclass_data.shape)
        print("src_transform:", reclass_src.transform)
        print("src_crs:", reclass_src.crs)
        print("dst_transform:", srcB.transform)
        print("dst_crs:", srcB.crs)
        reproject(
            source=reclass_src.read(1),
            destination=reclass_data,
            src_transform=reclass_src.transform,
            src_crs=reclass_src.crs,
            dst_transform=srcB.transform,
            dst_crs=srcB.crs,
            resampling=Resampling.nearest
        )

        # Keep values in B where reclass == 1
        masked_B = np.where(reclass_data == 1, dataB, -32768)

        profileB.update(dtype=rasterio.float32, nodata=-32768)



    rasterC_path = os.path.join(out_dir, "rasterC.tif")
    with rasterio.open(rasterC_path, "w", **profileB) as dst:
        dst.write(masked_B.astype(np.float32), 1)
    print(f"Saved: {rasterC_path}")

    # -----------------
    # 3. Compute statistics for raster C
    # -----------------
    valid_vals = masked_B[masked_B != -32768]
    stats = {
        "min": float(np.min(valid_vals)),
        "max": float(np.max(valid_vals)),
        "mean": float(np.mean(valid_vals)),
        "median": float(np.median(valid_vals))
    }
    print("Raster C statistics:", stats)

    # -----------------
    # 4. Create raster_Final from raster B (values <= mean)
    # -----------------
    with rasterio.open(rasterB_path) as srcB:
        profileFinal = srcB.profile.copy()
        dataB = srcB.read(1, masked=True)

        rasterFinal = np.where(dataB <= stats["median"], dataB, -32768)
        profileFinal.update(dtype=rasterio.float32, nodata=-32768)

    rasterFinal_path = os.path.join(out_dir, "HAND_raster_Flood.tif")
    with rasterio.open(rasterFinal_path, "w", **profileFinal) as dst:
        dst.write(rasterFinal.astype(np.float32), 1)
    print(f"Saved: {rasterFinal_path}")

    process_hand_short_future(config, stats["median"])
    return stats

def process_hand_short_future(config, current_hand):
    """
    Threshold HAND raster and compute water depth raster.
    """
    
    future_hand = config["projection_hand"]
    hand_threshold = current_hand + future_hand
    nodata_value = -32768
    hand_raster_path = os.path.join(config['mainprojectfolder'], "hand.tif")
    temp_raster_path = os.path.join(config['riskfolder'], "hand_shortterm.tif")

    # Open raster
    with rasterio.open(hand_raster_path) as src:
        profile = src.profile
        hand_data = src.read(1)
        input_nodata = src.nodata

    # Mask: values > current_hand or input nodata set to nodata
    mask_nodata = (hand_data > hand_threshold)
    if input_nodata is not None:
        mask_nodata |= (hand_data == input_nodata)
    temp_data = np.where(mask_nodata, nodata_value, hand_data)

    # Save thresholded raster
    profile.update(dtype=rasterio.float32, nodata=nodata_value)
    with rasterio.open(temp_raster_path, "w", **profile) as dst:
        dst.write(temp_data.astype(np.float32), 1)

    # Compute depth = current_hand - raster_value (only where valid)
    depth_data = np.where(temp_data != nodata_value, hand_threshold - temp_data, nodata_value)

    depth_raster_path = os.path.join(config['riskfolder'], "depth_shortterm.tif")
    # Save depth raster
    with rasterio.open(depth_raster_path, "w", **profile) as dst:
        dst.write(depth_data.astype(np.float32), 1)


#######to comment out later:
 #for testing, code it: 
#config_file = "D:/g20/src/config/config.yaml"
#with open(config_file, 'r') as f: 
#    config = yaml.safe_load(f)

#main_floodmapping(config)