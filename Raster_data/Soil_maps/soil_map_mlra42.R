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
#' Data from John Maynard via Shawn Salley, Nov 2021
#'     from paper "Digital mapping of ecological land units using a nationally scalable modeling framework" Maynard et a. 2019
#' 
#' EMC 1/21/22
#' Last update: 6/8/22

library(dplyr)
library(terra)
library(ggplot2)
library(RColorBrewer)

color_pal = brewer.pal(7, 'Set1')

raw_file = 'Raster_data/Soil_maps/MLRA42_Prediction/NM_ens_dsm_prediction.tif'
ssei_file = 'Raster_data/Soil_maps/MLRA42_Prediction/NM_ens_dsm_SSEI.tif'
ci_file = 'Raster_data/Soil_maps/MLRA42_Prediction/NM_ens_dsm_CI.tif'

# read in prediction
s = rast(raw_file)
plot(s)
# There are 8 layers. It looks like the first 7 are the probability of each cell being in the 7 soil categories. The 8th layer assigns
# each cell to its most likely category.
soilcategory_raster = s[[8]]
plot(soilcategory_raster, col=color_pal)


# look at ssei
ssei = rast(ssei_file)
plot(ssei)
# areas with high ssei (western portion) had lower density of field samples

# look at ci file
ci = rast(ci_file)
plot(ci)

# ====================================
# reproject (only needed if using RAP, not RCMAP)

# # read in one of the RAP rasters
# rcmapraster = rast('Raster_data/RCMAP/rcmap_shrub_2020_YrxovhRBgE4yFRlToIA1.tiff')
# 
# #geo_extent = extent(rapraster)
# 
# # convert soil to lon/lat to match RAP
# soilcategory_lonlat = projectRaster(soilcategory_raster, crs = crs(rapraster))
# 
# plot(soilcategory_lonlat)
# 
# # combine sand and deep sand (1 and 2)
# soilcategory_lonlat[values(soilcategory_lonlat)==2] <-1

writeRaster(soilcategory_raster, 'Raster_data/Soil_maps/ensemble_soil_map_MLRA42.tif', overwrite=T)
