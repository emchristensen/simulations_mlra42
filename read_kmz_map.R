#' read Laura's state map (kmz file)
#' EMC 7/13/21

library(dplyr)
library(ggplot2)
library(rgdal)

inputfile = 'C:/Users/echriste/Downloads/JERStateMapSimple.kmz'

# workaround from https://mitchellgritts.com/posts/load-kml-and-kmz-files-into-r/
targetfile = 'data/.temp.kml.zip'
fs::file_copy(inputfile, targetfile)
unzip(targetfile,)

(test <- sf::read_sf('doc.kml'))
# has 7053 rows -- polygons?

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

# plot objects
plot(state_polygons[1,'geometry'])

# # look at just Gravelly
# gravelly = dplyr::filter(state_polygons, esite=='Gravelly')
# plot(gravelly[,'geometry'])
# 
# # try to merge all gravelly into one polygon
# datalayer_union = maptools::unionSpatialPolygons(datalayer, datalayer@data$plant)
# gravellytest = sf::st_union(gravelly[,'geometry'])
# plot(gravellytest)
# # this takes a long time and what we really want is a raster



# ====================================================
# create state raster map

# get bounds of whole set, create raster template object
bbox = sf::st_bbox(test)
r = raster::raster(xmn=bbox$xmin, xmx=bbox$xmax, ymn=bbox$ymin, ymx=bbox$ymax, nrows=1000, ncols=1000)

# convert to sf object
statepolygonssf = sf::st_sf(esite=state_polygons$esite, geometry=state_polygons$geometry)

# create separate columns for each esite of interest (1/0) this is dumb but I can't come up with a better way
# esites of interest: Sandy group (Sandy, Shallow Sandy, Loamy Sand); Gravelly; Loamy to clayey group (Loamy, Clayey?)
statepolygonssf$SandGravelLoam = 0
statepolygonssf$SandGravelLoam[statepolygonssf$esite %in% c('Sandy','Shallow sandy','Gravelly','Loamy','Clayey')] <- 1

stateraster = fasterize::fasterize(statepolygonssf, r, field = 'SandGravelLoam', fun='sum')
plot(stateraster)

# write to file
raster::writeRaster(stateraster, filename='data/state_map_raster.tif')
