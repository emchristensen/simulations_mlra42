# RAP cover data

This folder contains pixel-level vegetation cover data 1984-2020 broken down by category (perennial forbs and grasses, shrub, etc.) 

__get_staterasters_from_RAP.R__ processes the files in the raw data folder and outputs rasters of model states
__get_cover_from_RAP.R__ takes rasters created above and calculates % cover by state. output in csv form

## processed data
__state_cover_1984_2020.csv__ csv of % cover by state as determined by RAP tool.

## raw data
Raw data is from the Rangeland Analysis Platform (https://rangelands.app/products/). Data was downloaded using gdal tool in miniconda powershell. The following code was used to download each data file (one file = one year): 

gdal_translate -co compress=lzw -co tiled=yes -co bigtiff=yes /vsicurl/http://rangeland.ntsg.umt.edu/data/rap/rap-vegetation-cover/v2/vegetation-cover-v2-2019.tif  -projwin -106.82 32.69 -106.63 32.44 RAP_cover_v2_2019.tif

__data_README.txt__ contains the readme from the data repository
