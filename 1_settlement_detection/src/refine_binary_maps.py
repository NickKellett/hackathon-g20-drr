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

import os

import numpy as np
from osgeo import gdal

MAP = {
    "2019_binary.tif": "2019_ESRI.tif",
    "2020_binary.tif": "2020_ESRI.tif",
    "2021_binary.tif": "2021_ESRI.tif",
    "2022_0_before_binary.tif": "2022_ESRI.tif",
    "2022_1_after_binary.tif": "2022_ESRI.tif",
    "2023_binary.tif": "2023_ESRI.tif",
    "2024_binary.tif": "2023_ESRI.tif",
    "2025_binary.tif": "2023_ESRI.tif",
}
BINARY_DATA = "binary_maps/"
LULC_MAPS = "lulc_maps/"
OUTPUT_DIR = "refined_binary_maps/"

def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    for binary_map, lulc_map in MAP.items():
        binary_path = os.path.join(BINARY_DATA, binary_map)
        lulc_path = os.path.join(LULC_MAPS, lulc_map)

        binary_ds = gdal.Open(binary_path, gdal.GA_ReadOnly)
        binary_arr = binary_ds.ReadAsArray()

        lulc_ds = gdal.Open(lulc_path, gdal.GA_ReadOnly)
        lulc_arr = lulc_ds.ReadAsArray()

        # Refine binary map: keep only urban areas
        refined_binary_arr = np.where(lulc_arr == 1, 0, binary_arr)

        out_file = os.path.join(OUTPUT_DIR, binary_map.replace("_binary.tif", "_refined_binary.tif"))

        drv = gdal.GetDriverByName('GTiff')
        out_ds = drv.Create(out_file, refined_binary_arr.shape[1], refined_binary_arr.shape[0], 1, gdal.GDT_Byte, options=['COMPRESS=DEFLATE'])
        out_ds.SetGeoTransform(binary_ds.GetGeoTransform())
        out_ds.SetProjection(binary_ds.GetProjection())
        out_ds.GetRasterBand(1).WriteArray(refined_binary_arr)
        out_ds.GetRasterBand(1).SetNoDataValue(0)
        out_ds.FlushCache()
        out_ds = None
        binary_ds = None
        lulc_ds = None


if __name__ == '__main__':
    main()
