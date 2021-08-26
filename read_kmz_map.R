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

# convert to UTM projection
# set projection
utm_proj = '+proj=utm +zone=13 +datum=WGS84 +units=m'
JRN_utm <- spTransform(JRN_spatialpolygon, utm_proj)

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
#bbox = sf::st_bbox(test)
bbox = sf::st_bbox(JRN_utm)

#r = raster::raster(xmn=bbox$xmin, xmx=bbox$xmax, ymn=bbox$ymin, ymx=bbox$ymax, norw=100, ncol=100)
r = raster::raster(xmn=bbox$xmin, xmx=bbox$xmax, ymn=bbox$ymin, ymx=bbox$ymax, crs=utm_proj, resolution=250)



# set up data columns from attributes
state_polygons$SandGravelLoam = NA
state_polygons$SandGravelLoam[state_polygons$esite %in% c('Sandy','Shallow sandy','Gravelly','Loamy','Clayey')] <- 1

# JRN_spatialpolygon@data$SandGravelLoam = state_polygons$SandGravelLoam
# JRN_spatialpolygon@data$statecode = state_polygons$state_code
# JRN_spatialpolygon@data$state = as.numeric(substr(JRN_spatialpolygon@data$statecode, 1,1))
JRN_utm@data$SandGravelLoam = state_polygons$SandGravelLoam
JRN_utm@data$statecode = state_polygons$state_code
JRN_utm@data$state = as.numeric(substr(JRN_utm@data$statecode, 1,1))

# use rasterize function instead -- slower, but more options for "fun"
#mask_raster = raster::rasterize(JRN_spatialpolygon, r, field='SandGravelLoam', fun='sum')
mask_raster = raster::rasterize(JRN_utm, r, field='SandGravelLoam', fun='sum')
plot(mask_raster)

# raster of state code
#stateraster = raster::rasterize(JRN_spatialpolygon, r, field='state', fun='max')
stateraster = raster::rasterize(JRN_utm, r, field='state', fun='max')
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
e = raster::extent(332000, 345000, 3602000, 3610000)
stateraster_small = raster::crop(stateraster_mymodel, e)

# fill in NAs with 1s
stateraster_small@data@values[is.na(stateraster_small@data@values)] <- 1
plot(stateraster_small)

# write to file
raster::writeRaster(stateraster_small, filename='data/state_map_raster_small.tif', overwrite=T)

# create a first stratum of all 1s to match
stratum = stateraster_small
stratum@data@values <- 1
plot(stratum)

raster::writeRaster(stratum, filename='data/first_stratum_small.tif', overwrite=T)
