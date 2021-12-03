### Elevation data folder


This folder contains elevation data from USGS, DEM 1 arc second resolution. Data was downloaded from https://apps.nationalmap.gov/downloader/#/

__USGS_1arcsec__ Folder containing downloaded USGS DEM 1 arc second resolution, 1 degree x 1 degree tiles.

__USGS_DEM_1arcsecond.txt__ Text file listing the individual raster files to be downloaded. Download run through uGet software

__construct_elevation_raster.R__ R file read in USGS raster tiles, stitch together, and mask to MLRA42. Writes result to MLRA42_DEM1arcsec.tif.

__MLRA42_DEM1arcsec.tif__ Raster of elevation for MLRA42.
