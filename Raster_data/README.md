# Raster data folder

This folder contains raster data, including elevation, soil maps, and fractional vegetation cover products. Preliminary analysis compared RAP and RCMAP shrub cover raster data. While neither product was consistently more accurate at estimating shrub compared to on the ground AIM data, RAP appeared to overestimate shrub cover at low values, and had a higher one-year difference in shrub cover (shrub cover should change little in one year). We therefore decided to use the RCMAP product. (analyses in compare_shrub_cover_data_sources.R). 

### Elevation
Elevation raster from USGS, DEM 1 arcsecond

### RAP
Rangeland Analysis Platform fractional shrub cover. https://rangelands.app/rap/?biomass_t=herbaceous&ll=39.0000,-98.0000&z=5

### RCMAP
https://www.mrlc.gov/data/rcmap-shrub-cover

### Soil_maps
Raster of soil map.

### study-area-mask
Mask of study area.
 - MLRA 42  
 - State of NM  
 - Elevation 1000-2000m  
 - Overlaps with soil map
 - LandFire BPS classes of shrubland and grassland types  
 - No anthropogenic cover types (according to NLCD 2019 map)  