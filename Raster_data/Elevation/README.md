### Elevation data folder


This folder describes the process to download elevation data from USGS, DEM 1 arc second resolution. Data from https://apps.nationalmap.gov/downloader/#/ (too large to put in repo).

__USGS_DEM_1arcsecond.txt__ Text file listing the individual raster files to be downloaded. Download run through uGet software.

__construct_elevation_raster.R__ After files are downloaded, this script reads in 29 USGS raster tiles, stitches them together, and masks to MLRA42. Depends on file _MLRA42_boundary/nrcs142p2_052440/mlra_v42.shp_. Writes result to raster, too large to store on github. 