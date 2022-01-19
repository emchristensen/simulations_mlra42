# RAP cover data

This folder contains pixel-level vegetation cover data 1984-2020 broken down by category (perennial forbs and grasses, shrub, etc.) 

__get_staterasters_from_RAP.R__ processes the files in the raw data folder and outputs rasters of model states
__get_cover_from_RAP.R__ takes rasters created above and calculates % cover by state. output in csv form
__pixel_states_timeseries.R__ takes rasters created above and returns table of cover by veg class for each pixel. Also contains code to smooth each pixel's timeseries using GAMs


## Raw data
Raw data is from the Rangeland Analysis Platform (https://rangelands.app/products/). Data covering the entire MLRA 42 area was downloaded using gdal tool in miniconda powershell. These are very large files. The following code was used to download each data file (one file = one year; see conda_code_mlra42.txt): 

gdal_translate -co compress=lzw -co tiled=yes -co bigtiff=yes /vsicurl/http://rangeland.ntsg.umt.edu/data/rap/rap-vegetation-cover/v2/vegetation-cover-v2-2019.tif  -projwin -108.9867 35.3866 -102.0357 28.98026 RAP_cover_v2_2019.tif

__data_README.txt__ contains the readme from the data repository


## Workflow
1. Download RAP data uisng conda (see above)
  - Large data files placed in "RAP/raw files MLRA42/raw downloads"
2. Trim raw files to MLRA42 boundary
  - Run code in "RAP/raw files MLRA42/trim_rap_files.R"
  - Trimmed files are saved to "raw filesw MLRA42"
3. Extract shrub/tree layer from RAP files
  - Run code in "RAP/construct_shrubcover_rasters.R"
  - Shrub cover rasters are saved to "RAP/shrub rasters MLRA42"
4. Calculate 5-year means of shrub cover
  - Run code in "RAP/calculate_5year_mean_shrub_rasters.R"
  - Shrub rasters are saved to "RAP/shrub rasters 5yr"



