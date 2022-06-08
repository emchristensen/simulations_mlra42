# scraps of code

# look at differences in 5-year avg shrub cover
# working with subset of pixels -- MLRA 42 too large
# lookat differences by soil


# ========================================================
# put all years of shrub rasters in a single stack
shrub_stack = stack()
for (year in 1986:2020) {
  r = raster(paste0('RAP/shrub rasters/RAP_shrubtree_', year, '.tif')) 
  shrub_stack = stack(shrub_stack, r)
}

# calculate 5-year means of shrub cover
mean_1986_1990 = stack(shrub_stack@layers[1:5]) %>% mean()
mean_1991_1995 = stack(shrub_stack@layers[6:10]) %>% mean()
mean_1996_2000 = stack(shrub_stack@layers[11:15]) %>% mean()
mean_2001_2005 = stack(shrub_stack@layers[16:20]) %>% mean()
mean_2006_2010 = stack(shrub_stack@layers[21:25]) %>% mean()
mean_2011_2015 = stack(shrub_stack@layers[26:30]) %>% mean()
mean_2016_2020 = stack(shrub_stack@layers[31:35]) %>% mean()


# # write 5-year averages to a single stack
# stack_5y_avg = stack(mean_1986_1990,
#                      mean_1991_1995,
#                      mean_1996_2000,
#                      mean_2001_2005,
#                      mean_2006_2010,
#                      mean_2011_2015,
#                      mean_2016_2020)
# 
# pal <- colorRampPalette(c("white","black"))
# plot(stack_5y_avg, breaks = seq(0,90,10), col=pal(10))

# calculate differences between 5-year averages
difference_5y_avg = stack(mean_2016_2020 - mean_2011_2015,
                          mean_2011_2015 - mean_2006_2010,
                          mean_2006_2010 - mean_2001_2005,
                          mean_2001_2005 - mean_1996_2000,
                          mean_1996_2000 - mean_1991_1995,
                          mean_1991_1995 - mean_1986_1990)
plot(difference_5y_avg)


# =====================================================
# get mean of 5-year differences in shrub -- all soils
mean_diff_5y = mean(difference_5y_avg)
plot(mean_diff_5y)

# get overall shrub in-fill rates (all soils and all pixels)
results_5yr_rate = data.frame(soils = 'all',
                              pixels = 'all',
                              ncell = ncell(mean_diff_5y),
                              mean = cellStats(mean_diff_5y, stat='mean'),
                              sd = cellStats(mean_diff_5y, stat='sd'),
                              min = cellStats(mean_diff_5y, stat='min'),
                              max = cellStats(mean_diff_5y, stat='max'))

# identify pixels with >2 and <15% cover in 1985-1990 period
low_early = mean_1986_1990>=2 & mean_1986_1990<15
plot(low_early)

# mask raster
mean_diff_low_early = mask(mean_diff_5y, low_early, maskvalue=0)
plot(mean_diff_low_early)

# get results, all soils and only early-shrub pixels
results_5yr_rate = rbind(results_5yr_rate,
                         data.frame(soils = 'all',
                                    pixels = 'early_invaded',
                                    ncell = ncell(mean_diff_low_early) - cellStats(mean_diff_low_early, stat='countNA'),
                                    mean = cellStats(mean_diff_low_early, stat='mean'),
                                    sd = cellStats(mean_diff_low_early, stat='sd'),
                                    min = cellStats(mean_diff_low_early, stat='min'),
                                    max = cellStats(mean_diff_low_early, stat='max')))


# =============================================
# get differences by soil type

#' read in soil layer
#'   1 = sandy
#'   2 = deep sand
#'   3 = loamy-clayey
#'   4 = gravelly/calcic
#'   5 = bedrock/colluvium
#'   6 = gypsic
#'   7 = bottomland
soilmodel = stack('Soil maps/MLRA42_Prediction/NM_ens_dsm_prediction.tif')
# layer 8 is the soil category prediction
soilcategory_raster = soilmodel@layers[[8]]

# convert soil to lon/lat to match RAP
soilcategory_lonlat = projectRaster(soilcategory_raster, crs = crs(mean_diff_5y))

# reprojection caused the values to interpolate; round to get integer values
soilcategory_lonlat = round(soilcategory_lonlat)

# crop to RAP bounds
soilcategory_cropped = crop(soilcategory_lonlat, extent(mean_diff_5y))
plot(soilcategory_cropped)

# resample to match resolution
soil_resampled = resample(soilcategory_cropped, mean_diff_5y, method='ngb')

soil_sandy = soil_resampled==1
plot(soil_sandy)
soil_deepsand = soil_resampled==2
plot(soil_deepsand)
soil_loamclay = soil_resampled==3
plot(soil_loamclay)
soil_gravelly = soil_resampled==4
plot(soil_gravelly)
soil_bedrock = soil_resampled==5
plot(soil_bedrock)
soil_gypsic = soil_resampled==6
plot(soil_gypsic)
soil_bottomland = soil_resampled==7
plot(soil_bottomland)



# get mean of 5-year differences in shrub -- sandy
mean_sandy = mask(mean_diff_5y, soil_sandy, maskvalue=0) %>%
  mask(low_early, maskvalue=0)
results_5yr_rate = rbind(results_5yr_rate,
                         data.frame(soils = 'sandy',
                                    pixels = 'early_invaded',
                                    ncell = ncell(mean_sandy) - cellStats(mean_sandy, stat='countNA'),
                                    mean = cellStats(mean_sandy, stat='mean'),
                                    sd = cellStats(mean_sandy, stat='sd'),
                                    min = cellStats(mean_sandy, stat='min'),
                                    max = cellStats(mean_sandy, stat='max')))

# get mean of 5-year differences in shrub -- deep sand
mean_deepsand = mask(mean_diff_5y, soil_deepsand, maskvalue=0) %>%
  mask(low_early, maskvalue=0)
plot(mean_deepsand)
results_5yr_rate = rbind(results_5yr_rate,
                         data.frame(soils = 'deepsand',
                                    pixels = 'early_invaded',
                                    ncell = ncell(mean_deepsand) - cellStats(mean_deepsand, stat='countNA'),
                                    mean = cellStats(mean_deepsand, stat='mean'),
                                    sd = cellStats(mean_deepsand, stat='sd'),
                                    min = cellStats(mean_deepsand, stat='min'),
                                    max = cellStats(mean_deepsand, stat='max')))

# get mean of 5-year differences in shrub -- loamy clayey
mean_loamclay = mask(mean_diff_5y, soil_loamclay, maskvalue=0) %>%
  mask(low_early, maskvalue=0)
plot(mean_loamclay)
results_5yr_rate = rbind(results_5yr_rate,
                         data.frame(soils = 'loamclay',
                                    pixels = 'early_invaded',
                                    ncell = ncell(mean_loamclay) - cellStats(mean_loamclay, stat='countNA'),
                                    mean = cellStats(mean_loamclay, stat='mean'),
                                    sd = cellStats(mean_loamclay, stat='sd'),
                                    min = cellStats(mean_loamclay, stat='min'),
                                    max = cellStats(mean_loamclay, stat='max')))

# get mean of 5-year differences in shrub -- gravelly
mean_gravelly = mask(mean_diff_5y, soil_gravelly, maskvalue=0) %>%
  mask(low_early, maskvalue=0)
plot(mean_gravelly)
results_5yr_rate = rbind(results_5yr_rate,
                         data.frame(soils = 'gravelly',
                                    pixels = 'early_invaded',
                                    ncell = ncell(mean_gravelly) - cellStats(mean_gravelly, stat='countNA'),
                                    mean = cellStats(mean_gravelly, stat='mean'),
                                    sd = cellStats(mean_gravelly, stat='sd'),
                                    min = cellStats(mean_gravelly, stat='min'),
                                    max = cellStats(mean_gravelly, stat='max')))

# get mean of 5-year differences in shrub -- bedrock/colluvium
mean_bedrock = mask(mean_diff_5y, soil_bedrock, maskvalue=0) %>%
  mask(low_early, maskvalue=0)
plot(mean_bedrock)
results_5yr_rate = rbind(results_5yr_rate,
                         data.frame(soils = 'bedrock',
                                    pixels = 'early_invaded',
                                    ncell = ncell(mean_bedrock) - cellStats(mean_bedrock, stat='countNA'),
                                    mean = cellStats(mean_bedrock, stat='mean'),
                                    sd = cellStats(mean_bedrock, stat='sd'),
                                    min = cellStats(mean_bedrock, stat='min'),
                                    max = cellStats(mean_bedrock, stat='max')))

# get mean of 5-year differences in shrub -- gypsic
mean_gypsic = mask(mean_diff_5y, soil_gypsic, maskvalue=0) %>%
  mask(low_early, maskvalue=0)
plot(mean_gypsic)
results_5yr_rate = rbind(results_5yr_rate,
                         data.frame(soils = 'gypsic',
                                    pixels = 'early_invaded',
                                    ncell = ncell(mean_gypsic) - cellStats(mean_gypsic, stat='countNA'),
                                    mean = cellStats(mean_gypsic, stat='mean'),
                                    sd = cellStats(mean_gypsic, stat='sd'),
                                    min = cellStats(mean_gypsic, stat='min'),
                                    max = cellStats(mean_gypsic, stat='max')))

# get mean of 5-year differences in shrub -- bottomland
mean_bottomland = mask(mean_diff_5y, soil_bottomland, maskvalue=0) %>%
  mask(low_early, maskvalue=0)
plot(mean_bottomland)
results_5yr_rate = rbind(results_5yr_rate,
                         data.frame(soils = 'bottomland',
                                    pixels = 'early_invaded',
                                    ncell = ncell(mean_bottomland) - cellStats(mean_bottomland, stat='countNA'),
                                    mean = cellStats(mean_bottomland, stat='mean'),
                                    sd = cellStats(mean_bottomland, stat='sd'),
                                    min = cellStats(mean_bottomland, stat='min'),
                                    max = cellStats(mean_bottomland, stat='max')))

write.csv(results_5yr_rate, file = 'shrub_infill_rate_smallarea_2021_12.csv', row.names=F)
