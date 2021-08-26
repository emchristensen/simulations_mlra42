# code from Darren James (email 8/25/21)
# install.packages("fasterize")
# install.packages("DescTools")

library(tidyverse)
library(raster)
library(sf)

# working.directory <- "D:/Projects/Erica Christiansen/JER_state_map_rasterize"
# setwd(working.directory)
# dir()

# Import state map
JER.StateMap.sf <- st_read("shapefile/StateMap25Mar2021.shp") %>%
  dplyr::select(esite, state_code)

# make column for whether esite is in Sandy, Loamy, Clayey 
JER.StateMap.sf$SandGravelLoam = 0
JER.StateMap.sf$SandGravelLoam[JER.StateMap.sf$esite %in% c('Sandy','Shallow sandy','Gravelly','Loamy','Clayey')] <- 1

# make column for rounded state_code (just first digit important)
JER.StateMap.sf$state <- substr(as.character(JER.StateMap.sf$state_code),1,1) %>% as.numeric()

# convert default numbers to my state class numbers -- the labels have to be numeric
# 1, 2 -> 'grass'
# 3, 4, 5 -> 'mixed grass/shrub'
# 6 -> 'shrub'
# 7 -> 'barren'
# 8, 9 -> 'invaded'
JER.StateMap.sf$mystatecode = NA
JER.StateMap.sf$mystatecode[JER.StateMap.sf$state %in% c(1,2)] <- 1
JER.StateMap.sf$mystatecode[JER.StateMap.sf$state %in% c(3,4,5)] <- 2
JER.StateMap.sf$mystatecode[JER.StateMap.sf$state %in% c(6)] <- 3
JER.StateMap.sf$mystatecode[JER.StateMap.sf$state %in% c(7)] <- 4
JER.StateMap.sf$mystatecode[JER.StateMap.sf$state %in% c(8,9)] <- 5

# Check coordinate reference system
crs(JER.StateMap.sf) 

# Get extent of the state map
extent <- JER.StateMap.sf %>%
  st_bbox() 
extent

pixel.size <- 30 # units in m because of coordinate reference system

# Round min extents down and max extents up to whole number and in mupliples of pixel.size
xmin <- DescTools::RoundTo(extent[1], pixel.size, "floor")
ymin <- DescTools::RoundTo(extent[2], pixel.size, "floor")
xmax <- DescTools::RoundTo(extent[3], pixel.size, "ceiling")
ymax <- DescTools::RoundTo(extent[4], pixel.size, "ceiling")

# Calculate number of rows and columns
rows <- ymax- ymin
columns <- xmax- xmin

# Create blank raster
raster.blank = raster::raster(xmn=xmin,
                   xmx=xmax, 
                   ymn=ymin, 
                   ymx=ymax, 
                   nrows = rows, 
                   ncols = columns, 
                   crs = crs(JER.StateMap.sf))

raster.blank

# Rasterize to the state_code variable (it's already numeric)
# For overlapping polygons in a raster cell, assign to the highest state_code
state.code.raster <- fasterize::fasterize(sf = JER.StateMap.sf, 
                                          raster = raster.blank, 
                                          field = "state",
                                          fun = "max")
plot(state.code.raster)

# write to file
raster::writeRaster(state.code.raster, filename='data/state_map_raster_30m_res.tif', overwrite=T)

# Rasterize to the mystatecode variable (it's already numeric)
# For overlapping polygons in a raster cell, assign to the highest
my.state.code.raster <- fasterize::fasterize(sf = JER.StateMap.sf, 
                                          raster = raster.blank, 
                                          field = "mystatecode",
                                          fun = "max")
plot(my.state.code.raster)
# write to file
raster::writeRaster(my.state.code.raster, filename='data/state_map_raster_30m_mymodel.tif', overwrite=T)

# Rasterize the SandGravelLoam variable for masking
sandgravelloam.raster <- fasterize::fasterize(sf = JER.StateMap.sf,
                                              raster = raster.blank,
                                              field = 'SandGravelLoam', 
                                              fun = 'max')
plot(sandgravelloam.raster)

# write to file
raster::writeRaster(sandgravelloam.raster, filename='data/esite_map_raster_30m_res.tif', overwrite=T)



# ===============================================
# convert Jornada state codes to my simulation model codes

# read in raster created above
my.state.code.raster = raster('data/state_map_raster_30m_mymodel.tif')


# get a small subset of the map for testing models
e = raster::extent(337000, 341000, 3604000, 3608000)
stateraster_small = raster::crop(my.state.code.raster, e)
plot(stateraster_small)

# write to file
raster::writeRaster(stateraster_small, filename='data/state_map_raster_30m_cropped.tif', overwrite=T)


# create raster of same size for primary stratum, all 1s
esiteraster_small = stateraster_small
values(esiteraster_small) <- 1
plot(esiteraster_small)

# write to file
raster::writeRaster(esiteraster_small, filename='data/esite_raster_30m_cropped.tif', overwrite=T)
