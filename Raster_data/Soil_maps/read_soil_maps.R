#' Read digitial soil maps
#' 
#' Data from John Maynard via Shawn Salley, Nov 2021
#' Data from paper "Digital mapping of ecological land units using a nationally scalable modeling framework" Maynard et a. 2019
#' 
#' Soil categories:
#'   1 = sandy
#'   2 = deep sand
#'   3 = loamy-clayey
#'   4 = gravelly and calcic
#'   5 = bedrock and colluvium
#'   6 = gypsic
#'   7 = bottomland
#' 
#' EMC 11/29/21

library(dplyr)
library(terra)
library(ggplot2)
library(RColorBrewer)

color_pal = brewer.pal(7, 'Set1')

raw_file = 'Raster_data/Soil_maps/MLRA42_Prediction/NM_ens_dsm_prediction.tif'
ssei_file = 'Raster_data/Soil_maps/MLRA42_Prediction/NM_ens_dsm_SSEI.tif'
ci_file = 'Raster_data/Soil_maps/MLRA42_Prediction/NM_ens_dsm_CI.tif'

# read in prediction
s = terra::rast(raw_file)
plot(s)
# There are 8 layers. It looks like the first 7 are the probability of each cell being in the 7 soil categories. The 8th layer assigns
# each cell to its most likely category.
soilcategory_raster = s[[8]]
plot(soilcategory_raster, col=color_pal)

# look at ssei
ssei = terra::rast(ssei_file)
plot(ssei)
# areas with high ssei (western portion) had lower density of field samples

# look at ci file
ci = terra::rast(ci_file)
plot(ci)


# ====================================
# clip to bounds of this study
  
# read in one of the RAP rasters
rapraster = stack('Raster_data/RAP/raw files/RAP_cover_v2_2020.tif')

geo_extent = extent(rapraster)

# convert soil to lon/lat to match RAP
soilcategory_lonlat = projectRaster(soilcategory_raster, crs = crs(rapraster))

# crop to RAP bounds
soilcategory_cropped = crop(soilcategory_lonlat, geo_extent)
plot(soilcategory_cropped)
hist(soilcategory_cropped)

# crop ssei 
ssei_lonlat = projectRaster(ssei, crs=crs(rapraster))
ssei_cropped = crop(ssei_lonlat, geo_extent)
plot(ssei_cropped)
# restrict to "good" ssei values (>50)
ssei_good = ssei_cropped>50
ssei_filtered = mask(ssei_cropped, ssei_good, maskvalue=0)
plot(ssei_filtered)

# crop ci
ci_lonlat = projectRaster(ci, crs=crs(rapraster))
ci_cropped = crop(ci_lonlat, geo_extent)
plot(ci_cropped)



# ===================================================
# Import JER boundary shapefile (connect to jrn vpn)
JER.border <- sf::read_sf(dsn = "R:/Quadrat/Location_conflicts_Adler", layer = "jer_boundary")


ensemble = mask(soilcategory_cropped, ssei_good, maskvalue=0) %>%
  projectRaster(crs = crs(JER.border)) %>%
  rasterToPoints(spatial = T) %>% 
  as.data.frame() %>% 
  mutate(soil_category = as.factor(round(NM_ens_dsm_prediction.8)))


cbPalette <- c("#999999","#D55E00", "#0072B2","#E69F00", "#56B4E9", "#009E73", "#F0E442", "#CC79A7")

jrnmap = ggplot() +
  geom_raster(data = ensemble, aes(x=x, y=y, fill=soil_category)) +
  geom_sf(data = JER.border) +
  scale_fill_manual(values=cbPalette, labels=c(NA,'sandy','deep sand','loamy-clayey','gravelly/calcic','bedrock/colluvium','gypsic','bottomland')) + 
  ggtitle('ensemble') +
  theme_bw()
jrnmap
ggsave(plot=jrnmap, 'Figures/soil_category_map.png', width=5, height=5)

# ================================================
# look at the other models

rapraster_utm = projectRaster(rapraster, crs = crs(JER.border))
extent_utm = extent(rapraster_utm)

rf = stack('Soil maps/MLRA42_Prediction/NM_rf_dsm_prediction.tif')
plot(rf)
rf_df = projectRaster(rf, crs=crs(JER.border)) %>%
  crop(extent_utm) %>%
  rasterToPoints(spatial = T) %>%
  as.data.frame() %>%
  mutate(soil = as.factor(round(NM_rf_dsm_prediction)))

jrnmap_rfmodel = ggplot() +
  geom_raster(data = rf_df, aes(x=x, y=y, fill=soil)) +
  geom_sf(data = JER.border) +
  scale_fill_manual(values=cbPalette[-1], labels=c('sandy','deep sand','loamy-clayey','gravelly/calcic','bedrock/colluvium','gypsic','bottomland')) + 
  ggtitle('rf model') +
  theme_bw()
jrnmap_rfmodel
ggsave(plot=jrnmap_rfmodel, 'Figures/soil_category_map_rfmodel.png', width=5, height=5)

svm = stack('Soil maps/MLRA42_Prediction/NM_svm_dsm_prediction.tif')
plot(svm)
svm_df = projectRaster(svm, crs=crs(JER.border)) %>%
  crop(extent_utm) %>%
  rasterToPoints(spatial = T) %>%
  as.data.frame() %>%
  mutate(soil = as.factor(round(NM_svm_dsm_prediction)))

jrnmap_svmmodel = ggplot() +
  geom_raster(data = svm_df, aes(x=x, y=y, fill=soil)) +
  geom_sf(data = JER.border) +
  scale_fill_manual(values=cbPalette[-1], labels=c('sandy','deep sand','loamy-clayey','gravelly/calcic','bedrock/colluvium','gypsic','bottomland')) + 
  ggtitle('svm model') +
  theme_bw()
jrnmap_svmmodel
ggsave(plot=jrnmap_svmmodel, 'Figures/soil_category_map_svmmodel.png', width=5, height=5)

xgb = stack('Soil maps/MLRA42_Prediction/NM_xgb_dsm_prediction.tif')
plot(xgb)
xgb_df = projectRaster(xgb, crs=crs(JER.border)) %>%
  crop(extent_utm) %>%
  rasterToPoints(spatial = T) %>%
  as.data.frame() %>%
  mutate(soil = as.factor(round(NM_xgb_dsm_prediction)))

jrnmap_xgbmodel = ggplot() +
  geom_raster(data = xgb_df, aes(x=x, y=y, fill=soil)) +
  geom_sf(data = JER.border) +
  scale_fill_manual(values=cbPalette[-1], labels=c('sandy','deep sand','loamy-clayey','gravelly/calcic','bedrock/colluvium','gypsic','bottomland')) + 
  ggtitle('xgb model') +
  theme_bw()
jrnmap_xgbmodel
ggsave(plot=jrnmap_xgbmodel, 'Figures/soil_category_map_xgbmodel.png', width=5, height=5)
