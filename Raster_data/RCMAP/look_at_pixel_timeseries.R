library(dplyr)
library(terra)
library(ggplot2)

file_list = list.files('RCMAP/masked rasters', pattern = '*.tif$', full.names=T)


rasterstack = raster::stack(file_list)

# focus on first raster
oneraster = subset(rasterstack,1) %>% terra::rast()

# get random pixels
n = 100
pixel = spatSample(oneraster, n, 'random', xy=T)

# get 2016-2020 for random pixels
pixel_ts = terra::extract(rasterstack, pixel[,1:2]) %>% 
  as.data.frame() %>% 
  mutate(ID = 1:n) %>%
  dplyr::filter(!is.na(rcmap_masked_2016)) %>%
  tidyr::pivot_longer(!ID, names_to='layer') %>%
  mutate(year = readr::parse_number(layer))

plotdata = pixel_ts %>% dplyr::filter(ID==33)

ggplot(plotdata, aes(x=year, y=value, group=ID, color=ID)) +
  geom_point() +
  geom_line() +
  theme_bw()
