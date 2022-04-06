# RAP cover data

This folder contains scripts for obtaining and processing pixel-level vegetation cover data 1984-2020 broken down by category (perennial forbs and grasses, shrub, etc.) 

## Raw data
Raw data is from the Rangeland Analysis Platform (https://rangelands.app/products/). Data covering the entire MLRA 42 area was downloaded using gdal tool in miniconda powershell. These are very large files. The following code was used to download each data file (one file = one year; see conda_code_mlra42.txt): 

    gdal_translate -co compress=lzw -co tiled=yes -co bigtiff=yes /vsicurl/http://rangeland.ntsg.umt.edu/data/rap/rap-vegetation-cover/v2/vegetation-cover-v2-2019.tif  -projwin -108.9867 35.3866 -102.0357 28.98026 RAP_cover_v2_2019.tif

__data_README.txt__ contains the readme from the data repository


## Workflow
1. Download RAP data uisng conda (see above)
   - Large data files placed in __RAP/raw files MLRA42/raw downloads__  
2. Trim raw files to MLRA42 boundary
   - Run code in __RAP/trim_rap_files.R__
   - Trimmed files are saved to __RAP/raw filesw MLRA42__  
3. Extract shrub/tree layer from RAP files
   - Run code in __RAP/construct_shrubcover_rasters.R__
   - Sums shrub and tree cover from RAP data
   - Shrub cover rasters are saved to __RAP/shrub rasters MLRA42__  
4. Calculate 5-year means of shrub cover
   - Run code in __RAP/calculate_5year_mean_shrub_rasters.R__
   - Shrub rasters are saved to __RAP/shrub rasters 5yr__
5. Convert shrub cover to state classes
   - Run code __RAP/categorize_shrub_rasters.R__  
   - State class rasters are saved to __RAP/shrub rasters 5yr__  



