#' get soil raster of entire MLRA42
#' 
#' Soil categories:
#'   1 = sandy
#'   2 = deep sand
#'   3 = loamy-clayey
#'   4 = gravelly and calcic
#'   5 = bedrock and colluvium
#'   6 = gypsic
#'   7 = bottomland
#' 
#' Data obtained from Shawn Salley
#' Shawn recommended combining sand and deep sand
#' 
#' 
#' EMC 1/21/22

library(dplyr)
library(raster)
library(ggplot2)
library(RColorBrewer)

color_pal = brewer.pal(7, 'Set1')

raw_file = 'Soil maps/MLRA42_Prediction/NM_ens_dsm_prediction.tif'
ssei_file = 'Soil maps/MLRA42_Prediction/NM_ens_dsm_SSEI.tif'
ci_file = 'Soil maps/MLRA42_Prediction/NM_ens_dsm_CI.tif'

# read in prediction
s = stack(raw_file)
plot(s)
# There are 8 layers. It looks like the first 7 are the probability of each cell being in the 7 soil categories. The 8th layer assigns
# each cell to its most likely category.
soilcategory_raster = s@layers[[8]]
plot(soilcategory_raster, col=color_pal)


# look at ssei
ssei = stack(ssei_file)
plot(ssei)
# areas with high ssei (western portion) had lower density of field samples

# look at ci file
ci = stack(ci_file)
plot(ci)

# ====================================
# reproject to match RAP

# read in one of the RAP rasters
rapraster = stack('RAP/raw files MLRA42/RAP_cover_v2_2020_MLRA42.tif')

geo_extent = extent(rapraster)

# convert soil to lon/lat to match RAP
soilcategory_lonlat = projectRaster(soilcategory_raster, crs = crs(rapraster))

plot(soilcategory_lonlat)

# combine sand and deep sand (1 and 2)
soilcategory_lonlat[values(soilcategory_lonlat)==2] <-1

writeRaster(soilcategory_lonlat, 'Soil maps/ensemble_soil_map_MLRA42.tif')
