## Climate

Precip and PDSI data downloaded from GridMET https://www.climatologylab.org/gridmet.html

PDSI info https://www.drought.gov/data-maps-tools/us-gridded-palmer-drought-severity-index-pdsi-gridmet

get_climate_variables.R  
 - for PDSI: masks raw raster files to area of interest, calculates average value per time step, then average value per year  
 - for precip: calculates total precip per year per cell of raw raster files, masks to area of interest, calculates average yearly sum over area of interest