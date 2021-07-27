#' Create rasters for initial conditions
#' EMC 7/26/21

library(dplyr)
library(raster)

# create a raster with uniform 1 values
r = raster(ncol=100, nrow=100)
ncell(r)
hasValues(r)

values(r) <- 1

plot(r)

