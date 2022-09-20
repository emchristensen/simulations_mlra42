#' reduce pdsi to smaller area and yearly mean rasters
#' 
#' EMC 7/19/22
library(dplyr)
library(terra)
library(ggplot2)

pdsi = terra::rast('Climate/PDSI/pdsi.nc')

# only want pdsi layers
pdsi_layers = pdsi['pdsi']

# crop to smaller area

e = ext(-109.1,-102.8, 31.3, 35)
pdsi_crop = terra::crop(pdsi_layers, e)

dates = names(pdsi_crop) %>% readr::parse_number() %>% as.Date(origin='1900-01-01')

dates_1980 = grep('1980', dates)

pdsi_1980 = terra::mean(pdsi_crop[[1:73]])


# for each year, find layer names from that year and calculate mean yearly raster
yearstrings = as.character(1985:2021)
yearstring = yearstrings[1]

# find layers from the selected year
yeardates = grep(yearstring, dates)

# take the mean of those layers: create start of SpatRaster stack
pdsi_yearly = terra::mean(pdsi_crop[[yeardates]])

for (yearstring in yearstrings[-1]) {
  # find layers from the selected year
  yeardates = grep(yearstring, dates)
  
  # take the mean of those layers
  pdsi_yearlymean = terra::mean(pdsi_crop[[yeardates]])
  
  # add new year of data to stack
  add(pdsi_yearly) <- pdsi_yearlymean
  
}

# change names of layers
names(pdsi_yearly) <- paste0('pdsi_', yearstrings)

# write to file
writeRaster(pdsi_yearly, 'Climate/PDSI/PDSI_yearly_raster.tif')


# =======================================================
# resample pdsi to be on same grid as RCMAP

# state raster file list
filelist = list.files('Raster_data/RCMAP/staterasters', pattern = '*.tif$', full.names=T)
testfile = terra::rast(filelist[1])

# resample pdsi rasters
pdsi_resampled = resample(pdsi_yearly, testfile)

writeRaster(pdsi_resampled, 'Climate/PDSI/PDSI_yearly_rcmap_grid.tif')


# =======================================================

# get mean of whole are for each time point

pdsi_by_date = c()
# loop through each layer
for (n in 1:length(pdsi_crop[1])) {
  # parse date from name
  layerdate = names(pdsi_crop[[n]]) %>% readr::parse_number() %>% as.Date(origin='1900-01-01')
  
  # add to data frame
  pdsi_by_date = rbind(pdsi_by_date, data.frame(date=layerdate,
                                                pdsi_mean=global(pdsi_crop[[n]], mean, na.rm=T),
                                                pdsi_min=global(pdsi_crop[[n]], min, na.rm=T),
                                                pdsi_max = global(pdsi_crop[[n]], max, na.rm=T),
                                                pdsi_median = global(pdsi_crop[[n]], median, na.rm=T)))
  
}
pdsi_by_date = pdsi_by_date %>%
  rename(pdsi_mean=mean,
         pdsi_min=min,
         pdsi_max=max,
         pdsi_median=global)

ggplot(pdsi_by_date, aes(x=date, y=pdsi_mean)) +
  geom_point()

# group by year
pdsi_by_date$year = lubridate::year(pdsi_by_date$date)
pdsi_by_date$month = lubridate::month(pdsi_by_date$date)

pdsi_by_year = pdsi_by_date %>%
  dplyr::filter(month %in% c(4,5,6,7,8,9)) %>%
  group_by(year) %>%
  summarize(avg = mean(pdsi_mean),
            min=min(pdsi_min),
            max=max(pdsi_max),
            median=mean(pdsi_median))
write.csv(pdsi_by_year, 'Climate/PDSI_by_year.csv', row.names=F)
