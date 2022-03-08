#' cut down bounds of MLRA 42 rasters for test runs in syncrosim
#' 
#' EMC 1/19/22

library(raster)
library(dplyr)
library(ggplot2)

# new extent: subregion of MLRA 42
e = extent(-106.5,-106, 32.5, 33)


# initial conditions
initialcond = raster('RAP/shrub rasters 5yr/RAP_shrubtree_1986_1990_categories.tif')

IC_crop = crop(initialcond, e)
plot(IC_crop)

# get relative areas for non-spatial run
freq(IC_crop)/ncell(IC_crop)

# plot and save figure
IC_crop_df = rasterToPoints(IC_crop) %>% data.frame()
colnames(IC_crop_df) <- c('lon','lat','state')
IC_crop_df$state = as.factor(IC_crop_df$state)
initialcond = ggplot(data = IC_crop_df, aes(x=lon, y=lat)) +
  geom_raster(aes(fill=state)) +
  theme_bw()
initialcond
ggsave('syncrosim test run/Figures/states_1986_1990.png', plot=initialcond, width=4, height=3)

writeRaster(IC_crop, filename = 'syncrosim test run/shrubtree_1986_1990.tif', overwrite=T)


# create stratum raster of same size (all 1s)
stratum = IC_crop
values(stratum) = 1

writeRaster(stratum, filename = 'syncrosim test run/initial_stratum.tif', overwrite=T)


# get sizes of rasters -- confirm software got it right
nrow(stratum)
ncol(stratum)
ncell(stratum)


# Crop the rest of the time steps
ts2 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_1991_1995_categories.tif')
ts2_crop= crop(ts2, e)
writeRaster(ts2_crop, filename = 'syncrosim test run/shrubtree_1991_1995.tif', overwrite=T)

ts3 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_1996_2000_categories.tif')
ts3_crop= crop(ts3, e)
writeRaster(ts3_crop, filename = 'syncrosim test run/shrubtree_1996_2000.tif', overwrite=T)

ts4 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_2001_2005_categories.tif')
ts4_crop= crop(ts4, e)
writeRaster(ts4_crop, filename = 'syncrosim test run/shrubtree_2001_2005.tif', overwrite=T)

ts5 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_2006_2010_categories.tif')
ts5_crop= crop(ts5, e)
writeRaster(ts5_crop, filename = 'syncrosim test run/shrubtree_2006_2010.tif', overwrite=T)

ts6 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_2011_2015_categories.tif')
ts6_crop= crop(ts6, e)
writeRaster(ts6_crop, filename = 'syncrosim test run/shrubtree_2011_2015.tif', overwrite=T)

ts7 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_2016_2020_categories.tif')
ts7_crop= crop(ts7, e)
writeRaster(ts7_crop, filename = 'syncrosim test run/shrubtree_2016_2020.tif', overwrite=T)


# ========================================
# look at soil and elevation maps
elevation = raster('elevation/MLRA42_DEM1arcsec.tif')
#plot(elevation)

elevation_crop = crop(elevation, e)
elevation_df = rasterToPoints(elevation_crop) %>% data.frame()
colnames(elevation_df) <- c('x','y','elevation')
elevationplot = ggplot(data=elevation_df, aes(x=x, y=y)) +
  geom_raster(aes(fill=elevation))
elevationplot

ggsave('syncrosim test run/Figures/elevation.png', plot=elevationplot, width=4, height=3)

soil = raster('Soil maps/ensemble_soil_map_MLRA42.tif')
soil_crop = crop(soil, e)
soil_df = rasterToPoints(soil_crop) %>% data.frame()
colnames(soil_df) <- c('x','y','soil')
soilplot = ggplot(data=soil_df, aes(x=x, y=y)) +
  geom_raster(aes(fill=soil))
soilplot

ggsave('syncrosim test run/Figures/soil.png', plot=soilplot, width=4, height=3)
