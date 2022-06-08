# RCMAP shrub cover data

This folder contains data from RCMAP shrub cover estimates https://www.mrlc.gov/data/rcmap-shrub-cover.

Data covers the western US and is based on Landsat. 

## Data acquisition

Map tool to select a subregion: https://www.mrlc.gov/rangeland-viewer/
 - Geographic region covers southern half of NM 
 - Selected years and layers wanted (1985-2020 and shrub cover)  

## Mask to area of interest

__process_rcmap_rasters.R__ script that masks raw RCMAP rasters to study area.
 - Saves masked rasters to "masked rasters" folder
 - Classifies each pixel to state (1 = no shrub, 2 = low shrub, 3 = shrubland) and saves to "staterasters" folder.

__study-area-mask.tif__ raster for masking area of interest.

 - MLRA 42
 - State of NM
 - Elevation 1000-2000m
 - LandFire BPS classes of shrubland or grassland
 - No pixels classified as anthropogenic land cover types (according to NLCD 2019 map)

## Get transition probabilities

__get_transition_probabilities_rcmap.R__ script which uses files in "staterasters" folder and estimates rates of annual transition between the three shrub states. Output is written to __transition_probabilities.csv__.