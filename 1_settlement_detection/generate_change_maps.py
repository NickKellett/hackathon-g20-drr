import os

import numpy as np
from osgeo import gdal


IMAGE_DATA = "refined_binary_maps/"

def main():
    f_list = os.listdir(IMAGE_DATA)
    f_list.sort()
    pairs_list = [(f_list[i], f_list[i+1]) for i in range(len(f_list)-1)]

    for pair in pairs_list:
        img1_ds = gdal.Open(os.path.join(IMAGE_DATA, pair[0]), 0)
        img1_arr = img1_ds.ReadAsArray()

        img2_ds = gdal.Open(os.path.join(IMAGE_DATA, pair[1]), 0)
        img2_arr = img2_ds.ReadAsArray()

        change_map = img1_arr - img2_arr

        change_map = np.where(change_map < 0, 1, np.where(change_map > 0, -1, 0))

        before_prefix = pair[0].replace("_binary.tif", "")
        after_prefix = pair[1].replace("_binary.tif", "")
        out_file_name = f"{before_prefix}_to_{after_prefix}_change_map.tif"
        out_folder = os.path.join(os.path.dirname(os.path.abspath(__file__)), "change_maps")
        os.makedirs(out_folder, exist_ok=True)
        out_file = os.path.join(out_folder, out_file_name)

        drv = gdal.GetDriverByName('GTiff')
        out_ds = drv.Create(out_file, change_map.shape[1], change_map.shape[0], 1, gdal.GDT_Int16, options=['COMPRESS=DEFLATE'])
        out_ds.SetGeoTransform(img1_ds.GetGeoTransform())
        out_ds.SetProjection(img1_ds.GetProjection())
        out_ds.GetRasterBand(1).WriteArray(change_map)
        out_ds.GetRasterBand(1).SetNoDataValue(0)
        out_ds.FlushCache()
        out_ds = None
        img1_ds = None
        img2_ds = None


if __name__ == '__main__':
    main()