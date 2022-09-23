#' process raw RCMAP rasters
#' 
#' Masks rasters to:
#'   - MLRA 42
#'   - state of NM
#'   - elevation 1000-2000 m
#'   - soil raster exists
#'   - LandFire BPS classes of Shrubland and Grassland types
#'   - no anthropogenic land covery types according to NLCD 2019 map
#' 
#' EMC 5/20/22

library(dplyr)
library(terra)

# get list of downloaded RCMAP rasters
file_list = list.files('Raster_data/RCMAP', pattern = '*.tiff$', full.names=T)

# load mask raster
area_mask = terra::rast('Raster_data/study-area-mask.tif')


# categorization matrix
m <- c(0,1,1,
       1,14,2,
       14,Inf,3)
rclmat = matrix(m, ncol=3, byrow=T)



# loop through files, crop and categorize cells
rcmapfile = file_list[1]
for (rcmapfile in file_list) {
  rcmap = terra::rast(rcmapfile)
  year = readr::parse_number(rcmapfile)
  
  # crop and mask to study-area-mask.tif
  rcmap_crop = terra::crop(rcmap, area_mask)
  rcmap_mask = terra::mask(rcmap_crop, area_mask)
  
  # values >100 are NA
  rcmap_mask[rcmap_mask>100] <- NA
  
  # save to file
  writeRaster(rcmap_mask, filename=paste0('Raster_data/RCMAP/masked rasters/rcmap_masked_', year, '.tif'), overwrite=T)
  
  # categorize
  stateraster = classify(rcmap_mask, rclmat, include.lowest=T)

  # save to file
  writeRaster(stateraster, filename=paste0('Raster_data/RCMAP/staterasters/rcmap_states_', year, '.tif'), overwrite=T)
}

