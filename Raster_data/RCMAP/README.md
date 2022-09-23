# RCMAP shrub cover data

This folder contains data from RCMAP shrub cover estimates https://www.mrlc.gov/data/rcmap-shrub-cover.

Data covers the western US and is based on Landsat. Data available 1985-2020, 2012 no data.

## Data acquisition

Map tool to select a subregion: https://www.mrlc.gov/rangeland-viewer/
 - Geographic region covers southern half of NM 
 - Selected years and layers wanted (1985-2020 and shrub cover)  

## Process raw rasters

__process_rcmap_rasters.R__ script that masks raw RCMAP rasters to study area.
 - Saves masked rasters to "masked rasters" folder
 - Classifies each pixel to state (1 = no shrub, 2 = low shrub, 3 = shrubland) and saves to "staterasters" folder.


## transition probabilities
Old method was to estimate transition probabilities directly from the proportion of cells that transitioned during each time step. 
