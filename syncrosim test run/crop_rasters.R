#' cut down bounds of MLRA 42 rasters for test runs in syncrosim
#' 
#' EMC 1/19/22

library(raster)
library(dplyr)

# new extent: subregion of MLRA 42
e = extent(-107,-106, 32, 33)


# initial conditions
initialcond = raster('RAP/shrub rasters 5yr/RAP_shrubtree_1986_1990_categories.tif')

IC_crop = crop(initialcond, e)
plot(IC_crop)
freq(IC_crop)

writeRaster(IC_crop, filename = 'syncrosim test run/shrubtree_1986_1990.tif')


# create stratum raster of same size (all 1s)
stratum = IC_crop
values(stratum) = 1

writeRaster(stratum, filename = 'syncrosim test run/initial_stratum.tif')


# get sizes of rasters -- confirm software got it right
nrow(stratum)
ncol(stratum)
ncell(stratum)


# Crop the rest of the time steps
ts2 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_1991_1995_categories.tif')
ts2_crop= crop(ts2, e)
writeRaster(ts2_crop, filename = 'syncrosim test run/shrubtree_1991_1995.tif')

ts3 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_1996_2000_categories.tif')
ts3_crop= crop(ts3, e)
writeRaster(ts3_crop, filename = 'syncrosim test run/shrubtree_1996_2000.tif')

ts4 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_2001_2005_categories.tif')
ts4_crop= crop(ts4, e)
writeRaster(ts4_crop, filename = 'syncrosim test run/shrubtree_2001_2005.tif')

ts5 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_2006_2010_categories.tif')
ts5_crop= crop(ts5, e)
writeRaster(ts5_crop, filename = 'syncrosim test run/shrubtree_2006_2010.tif')

ts6 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_2011_2015_categories.tif')
ts6_crop= crop(ts6, e)
writeRaster(ts6_crop, filename = 'syncrosim test run/shrubtree_2011_2015.tif')

ts7 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_2016_2020_categories.tif')
ts7_crop= crop(ts7, e)
writeRaster(ts7_crop, filename = 'syncrosim test run/shrubtree_2016_2020.tif')
