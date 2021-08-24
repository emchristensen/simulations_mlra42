#' read Laura's state map (kmz file)
#' EMC 7/13/21

library(dplyr)
library(ggplot2)
library(rgdal)
library(sf)

inputfile = 'C:/Users/echriste/Documents/Work/Jornada/STSim/JERStateMapSimple.kmz'

# workaround from https://mitchellgritts.com/posts/load-kml-and-kmz-files-into-r/
targetfile = 'data/.temp.kml.zip'
fs::file_copy(inputfile, targetfile)
unzip(targetfile,)

(test <- sf::read_sf('doc.kml'))
# has 7053 rows -- polygons?

# convert to SpatialPolygons type
JRN_spatialpolygon <- sf::as_Spatial(st_zm(test), IDs = as.character(1:nrow(test)))

# ============================
# Description column has unparsed html -- extract and write to csv
attributes = c()
for (n in 1:nrow(test)) {
  t1 = (rvest::read_html(test$Description[n]) %>% rvest::html_table(fill=T))[[2]] %>% tidyr::pivot_wider(names_from=X1, values_from=X2)
  attributes = rbind(attributes, t1)
}
write.csv(attributes, 'data/attributes_from_kmz_map.csv', row.names=F)
# ==================================

# read in attributes
attributes = read.csv('data/attributes_from_kmz_map.csv')

# combine attributes with spatial object
state_polygons = cbind(attributes, test[,c('Name','geometry')])

# plot the first object as a test
plot(state_polygons[1,'geometry'])




# ====================================================
# create state raster map

# get bounds of whole set, create raster template object
bbox = sf::st_bbox(test)
r = raster::raster(xmn=bbox$xmin, xmx=bbox$xmax, ymn=bbox$ymin, ymx=bbox$ymax, nrows=100, ncols=100)

# # convert to sf object
# statepolygonssf = sf::st_sf(esite=state_polygons$esite, geometry=state_polygons$geometry)
# 
# # create separate columns for each esite of interest (1/0) this is dumb but I can't come up with a better way
# # esites of interest: Sandy group (Sandy, Shallow Sandy, Loamy Sand); Gravelly; Loamy to clayey group (Loamy, Clayey?)
# statepolygonssf$SandGravelLoam = 0
# statepolygonssf$SandGravelLoam[statepolygonssf$esite %in% c('Sandy','Shallow sandy','Gravelly','Loamy','Clayey')] <- 1

# stateraster = fasterize::fasterize(statepolygonssf, r, field = 'SandGravelLoam', fun='sum')
# plot(stateraster)


# set up data columns from attributes
state_polygons$SandGravelLoam = NA
state_polygons$SandGravelLoam[state_polygons$esite %in% c('Sandy','Shallow sandy','Gravelly','Loamy','Clayey')] <- 1

JRN_spatialpolygon@data$SandGravelLoam = state_polygons$SandGravelLoam
JRN_spatialpolygon@data$statecode = state_polygons$state_code
JRN_spatialpolygon@data$state = as.numeric(substr(JRN_spatialpolygon@data$statecode, 1,1))

# use rasterize function instead -- slower, but more options for "fun"
mask_raster = raster::rasterize(JRN_spatialpolygon, r, field='SandGravelLoam', fun='sum')
plot(mask_raster)

# raster of state code
stateraster = raster::rasterize(JRN_spatialpolygon, r, field='state', fun='max')
plot(stateraster)

# mask state raster with the SandGravelLoam mask
stateraster_masked = raster::mask(stateraster, mask=mask_raster)
plot(stateraster_masked)

# use ggplot
rasterdf = raster::rasterToPoints(stateraster_masked, spatial=T)
rasterdf2 = data.frame(rasterdf)
rasterplot = ggplot(rasterdf2, aes(x=x, y=y)) +
  geom_tile(aes(fill=as.factor(layer)))
rasterplot
ggsave('Figures/state_map_raster_JRN.png', plot=rasterplot, width=5, height=4)

# write to file
raster::writeRaster(stateraster_masked, filename='data/state_map_raster.tif', overwrite=T)

# convert default numbers to my state class numbers -- the labels have to be numeric
# 1, 2 -> 'grass'
# 3, 4, 5 -> 'mixed grass/shrub'
# 6 -> 'shrub'
# 7 -> 'barren'
# 8, 9 -> 'invaded'
stateraster_mymodel = stateraster_masked
stateraster_mymodel@data@values[stateraster_mymodel@data@values %in% c(1,2)] <- 1
stateraster_mymodel@data@values[stateraster_mymodel@data@values %in% c(3,4,5)] <- 2
stateraster_mymodel@data@values[stateraster_mymodel@data@values %in% c(6)] <- 3
stateraster_mymodel@data@values[stateraster_mymodel@data@values %in% c(7)] <- 4
stateraster_mymodel@data@values[stateraster_mymodel@data@values %in% c(8,9)] <- 5

# plot
rasterdf = raster::rasterToPoints(stateraster_mymodel, spatial=T)
rasterdf2 = data.frame(rasterdf)
rasterplot = ggplot(rasterdf2, aes(x=x, y=y)) +
  geom_tile(aes(fill=as.factor(layer)))
rasterplot

# write to file
raster::writeRaster(stateraster_mymodel, filename='data/state_map_raster_mymodel.tif', overwrite=T)


# get a small subset of the map for testing models
e = raster::extent(-106.76, -106.66, 32.55, 32.65)
stateraster_small = raster::crop(stateraster_mymodel, e)

# fill in NAs with 1s
stateraster_small@data@values[is.na(stateraster_small@data@values)] <- 1
plot(stateraster_small)

# write to file
raster::writeRaster(stateraster_small, filename='data/state_map_raster_small.tif', overwrite=T)
