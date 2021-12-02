#' read downloaded elevation rasters and combine into a single raster
#' EMC 11/30/21

library(dplyr)
library(ggplot2)
library(raster)
library(sf)

# USGS data: National Elevation Dataset, USGS 1 Arc Second

usgs1 = stack('elevation/DEM_1arcsec/USGS_1_n32w106_20210616.tif')
plot(usgs1)

# stick together USGS tiles
usgs2 = stack('elevation/DEM_1arcsec/USGS_1_n32w107_20210616.tif')
usgs3 = stack('elevation/DEM_1arcsec/USGS_1_n33w106_20210616.tif')
usgs4 = stack('elevation/DEM_1arcsec/USGS_1_n33w107_20210702.tif')
usgs5 = stack('elevation/DEM_1arcsec/USGS_1_n32w105_20211124.tif')
usgs6 = stack('elevation/DEM_1arcsec/USGS_1_n33w105_20211124.tif')
usgs7 = stack('elevation/DEM_1arcsec/USGS_1_n32w104_20211124.tif')
usgs8 = stack('elevation/DEM_1arcsec/USGS_1_n33w104_20211124.tif')
usgs9 = stack('elevation/DEM_1arcsec/USGS_1_n32w103_20211124.tif')
usgs10 = stack('elevation/DEM_1arcsec/USGS_1_n33w103_20211124.tif')
usgs11 = stack('elevation/DEM_1arcsec/USGS_1_n32w108_20130911.tif')
usgs12 = stack('elevation/DEM_1arcsec/USGS_1_n33w108_20130911.tif')
usgs13 = stack('elevation/DEM_1arcsec/USGS_1_n32w109_20130911.tif')
usgs14 = stack('elevation/DEM_1arcsec/USGS_1_n33w109_20130911.tif')
usgs15 = stack('elevation/DEM_1arcsec/USGS_1_n34w104_20191001.tif')
usgs16 = stack('elevation/DEM_1arcsec/USGS_1_n34w105_20190204.tif')
usgs17 = stack('elevation/DEM_1arcsec/USGS_1_n34w106_20170306.tif')
usgs18 = stack('elevation/DEM_1arcsec/USGS_1_n34w107_20210630.tif')
usgs19 = stack('elevation/DEM_1arcsec/USGS_1_n34w108_20210630.tif')
usgs20 = stack('elevation/DEM_1arcsec/USGS_1_n35w107_20190712.tif')
usgs21 = stack('elevation/DEM_1arcsec/USGS_1_n35w108_20190731.tif')
usgs22 = stack('elevation/DEM_1arcsec/USGS_1_n31w106_20210616.tif')
usgs23 = stack('elevation/DEM_1arcsec/USGS_1_n31w105_20210616.tif')
usgs24 = stack('elevation/DEM_1arcsec/USGS_1_n31w104_20201228.tif')
usgs25 = stack('elevation/DEM_1arcsec/USGS_1_n31w103_20201228.tif')
usgs26 = stack('elevation/DEM_1arcsec/USGS_1_n30w105_20201228.tif')
usgs27 = stack('elevation/DEM_1arcsec/USGS_1_n30w104_20201228.tif')
usgs28 = stack('elevation/DEM_1arcsec/USGS_1_n36w107_20210630.tif')
usgs29 = stack('elevation/DEM_1arcsec/USGS_1_n36w108_20210630.tif')

# merge function uses value of "upper" layer if there is an overlap; mosaic function you can specify max/mean/etc.
usgs_merged = merge(usgs1, usgs2) %>% merge(usgs3) %>% merge(usgs4) %>% merge(usgs5) %>% merge(usgs6) %>% 
  merge(usgs7) %>% merge(usgs8) %>% merge(usgs9) %>% merge(usgs10) %>% merge(usgs11) %>% merge(usgs12) %>%
  merge(usgs13) %>% merge(usgs14) %>% merge(usgs15) %>% merge(usgs16) %>% merge(usgs17) %>% merge(usgs18) %>%
  merge(usgs19) %>% merge(usgs20) %>% merge(usgs21) %>% merge(usgs22) %>% merge(usgs23) %>% merge(usgs24) %>%
  merge(usgs25) %>% merge(usgs26) %>% merge(usgs27) %>% merge(usgs28) %>% merge(usgs29)

#usgs_merged = usgs_merged %>% merge(usgs29)

plot(usgs_merged)


# ===================================
# mask elevation to MLRA 42

# read in MLRA shapefile
mlras = st_read('shapefile/nrcs142p2_052440/mlra_v42.shp')
mlra42 = subset(mlras, MLRARSYM==42)
plot(mlra42)

# mask
MLRA42_elevation = mask(usgs_merged, mlra42)
plot(MLRA42_elevation)

# write to file
writeRaster(MLRA42_elevation, filename='elevation/MLRA42_DEM1arcsec.tif')

