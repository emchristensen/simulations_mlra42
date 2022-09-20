#' get climate variables
#' 

library(terra)
library(dplyr)

# ============================================================
# download daily precip data for each year
year = 1986
for (year in 1986:2021) {
  downloader::download(url = paste0('http://www.northwestknowledge.net/metdata/data/pr_', year ,'.nc'),
                       destfile = paste0('Climate/Precip/pr_', year, '.nc'),
                       mode = 'wb')
}


# ==========================================================
# sum to get yearly precip
for (year in 1986:2021) {
  
  # read nc as raster
  pr_year = terra::rast(paste0('Climate/Precip/pr_', year, '.nc'))
  
  # get sum of precip for the year
  pr_sum = sum(pr_year)
  #terra::plot(pr_sum)
  
  # save to file
  writeRaster(pr_sum, filename=paste0('Climate/Precip/yearlyprecip_', year, '.tif'), overwrite=T)
}
# =========================================================

# crop precip to smaller extent
e = ext(-109.1,-102.8, 31.3, 35)

pr_sum = terra::rast('Climate/Precip/yearlyprecip_1986.tif')
pr_crop = terra::crop(pr_sum, e)

# load mask raster
area_mask = terra::rast('Raster_data/study-area-mask.tif')

# reproject mask
mask_reprojected = terra::project(area_mask, pr_crop)


# mask precip and calculate mean
ppt_timeseries = c()
for (year in 1986:2021) {
  
  pr_sum = terra::rast(paste0('Climate/Precip/yearlyprecip_', year, '.tif'))
  
  # crop
  pr_crop = terra::crop(pr_sum, e)
  
  # mask precip to AOI
  pr_masked = terra::mask(pr_crop, mask_reprojected)
  
  # calculate mean over AOI
  mean_ppt = mean(values(pr_masked), na.rm=T)
  
  # append to df
  ppt_timeseries = rbind(ppt_timeseries,
                         data.frame(y=year, ppt_total = mean_ppt))
}

write.csv(ppt_timeseries, 'Climate/ppt_timeseries.csv', row.names=F)


# ==============================
# PDSI
# value every 5 days since 1980 (one layer per value)
# names variable contains numbers indicating number of days since 01-01-1900
# pdsi.nc contains pdsi values and category values (?) 

pdsi = terra::rast('Climate/PDSI/pdsi.nc')

# only want pdsi layers
pdsi_layers = pdsi['pdsi']

# crop to smaller area
pdsi_crop = terra::crop(pdsi_layers, e)

# mask to study area
pdsi_masked = terra::mask(pdsi_crop, mask_reprojected)

# calculate mean pdsi per time point
pdsi_dataframe = c()
for (n in 1:nlyr(pdsi_masked)) {
  layer_mean = mean(values(pdsi_masked[[n]], na.rm=T))
  layer_min = min(values(pdsi_masked[[n]], na.rm=T))
  layer_max = max(values(pdsi_masked[[n]], na.rm=T))
  date = names(pdsi_masked)[n] %>% readr::parse_number() %>% as.Date(origin='1900-01-01')
  pdsi_dataframe = rbind(pdsi_dataframe,
                         data.frame(year=lubridate::year(date),
                                    month=lubridate::month(date),
                                    day=lubridate::day(date),
                                    date=date,
                                    pdsi_mean=layer_mean,
                                    pdsi_min=layer_min,
                                    pdsi_max=layer_max))
}


write.csv(pdsi_dataframe, 'Climate/pdsi_completetimeseries.csv', row.names=F)  

# monthly pdsi
monthly_pdsi = pdsi_dataframe %>%
  group_by(year, month) %>%
  summarize(pdsi_mean = mean(pdsi_mean),
            pdsi_min = min(pdsi_min),
            pdsi_max = max(pdsi_max))
monthly_pdsi$season = 'winter'
monthly_pdsi$season[monthly_pdsi$month %in% c(4,5,6,7,8,9)] <- 'summer'

# yearly
yearly_pdsi = monthly_pdsi %>%
  group_by(year) %>%
  summarize(mean_pdsi=mean(pdsi_mean))

# seasonally
season_pdsi = monthly_pdsi %>%
  group_by(year, season) %>%
  summarize(pdsi_season =mean(pdsi_mean)) %>%
  tidyr::pivot_wider(id_cols=year, names_from=season, values_from=pdsi_season)

yearly_pdsi = merge(yearly_pdsi, season_pdsi)

write.csv(yearly_pdsi, 'Climate/pdsi_timeseries.csv', row.names=F)
