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

# Description column has unparsed html
attributes = c()
for (n in 1:nrow(test)) {
  t1 = (rvest::read_html(test$Description[n]) %>% rvest::html_table(fill=T))[[2]] %>% tidyr::pivot_wider(names_from=X1, values_from=X2)
  attributes = rbind(attributes, t1)
}
write.csv(attributes, 'data/attributes_from_kmz_map.csv', row.names=F)
