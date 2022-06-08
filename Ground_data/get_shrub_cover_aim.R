#' Get shrub cover from AIM data points
#' 
#' AIM data were collected in 2016-2021
#' Lat/lon are in NAD83
#' 
#' EMC 5/2/22

library(dplyr)
library(lubridate)
library(ggplot2)
library(terra)


# raw data
aim_raw = read.csv('Ground_data/BLM_Natl_AIM_TerrADat_Hub.csv')

# get only New Mexico, below 35.4 latitude, get only variables related to date, location, and cover
aim <- aim_raw %>%
  dplyr::filter(State=='NM', Latitude_NAD83<35.4) %>%
  dplyr::select(OBJECTID, PrimaryKey, PlotKey, PlotID, Latitude_NAD83, Longitude_NAD83, DateVisited,
                AH_ShrubCover) %>%
  mutate(date = as.Date(DateVisited),
         year = year(date))


# plot points on a map
aim_coordinates = data.frame(lat = aim$Latitude_NAD83,
                             lon = aim$Longitude_NAD83,
                             year = aim$year,
                             shrubcover = aim$AH_ShrubCover)

ggplot() + 
  borders('state') +
  coord_cartesian(xlim = c(-109.1, -103), ylim= c(31.25, 35.4)) +
  geom_point(data=aim_coordinates, aes(x=lon, y=lat, color=shrubcover)) +
  theme_bw()


table(aim_coordinates$year)
# 2020 has the most points
aim2020 = dplyr::filter(aim_coordinates, year==2020)
aim2020$ID = 1:nrow(aim2020)

# turn into terra SpatVector object
df = data.frame(ID=aim2020$ID, shrubcover=aim2020$shrubcover)
lonlat = cbind(aim2020$lon, aim2020$lat)
ptv = terra::vect(lonlat, atts = df, crs="+proj=longlat +datum=NAD83")

# get RAP data for 2020 
#rap2020 = terra::rast('RAP/shrub rasters/RAP_shrubtree_2020.tif')
rap2020 = terra::rast('Raster_data/RAP/shrub rasters MLRA42/RAP_shrubtree_2020.tif')


# get intersection of AIM points and RAP raster
aim_rap_2020 = terra::extract(rap2020, ptv) %>%
  merge(aim2020) %>%
  dplyr::filter(!is.na(RAP_shrubtree_2020))

# plot AIM shrub cover vs RAP shrub cover
ggplot(aim_rap_2020) +
  geom_point(aes(x=shrubcover, y=RAP_shrubtree_2020)) +
  xlab('AIM') +
  ylab('RAP') +
  ggtitle('2020') +
  geom_abline(intercept = 0, slope = 1) +
  theme_bw()

# get RCMAP data for 2020
rcmap2020 = terra::rast('Raster_data/RCMAP/rcmap_shrub_2020_LajMUGu45oF76trHI4pc.tiff')

# get RCMAP into same crs as points
rcmap2020_lonlat = project(rcmap2020, "+proj=longlat +datum=NAD83")

# get intersection of AIM points and RCMAP raster
aim_rcmap_2020 = terra::extract(rcmap2020_lonlat, ptv, fun=mean) %>%
  merge(aim2020) %>%
  dplyr::filter(!is.na(Red))

ggplot(aim_rcmap_2020) +
  geom_point(aes(x=shrubcover, y=Red)) +
  xlab('AIM') +
  ylab('RCMAP') +
  ggtitle('2020') +
  geom_abline(intercept = 0, slope = 1) +
  theme_bw()

# calculate rmse for RAP and RCMAP
sqrt(mean((aim_rcmap_2020$shrubcover-aim_rcmap_2020$Red)^2))
sqrt(mean((aim_rap_2020$shrubcover-aim_rap_2020$RAP_shrubtree_2020)^2))
