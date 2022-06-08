# simulations_mlra42

This aim of this project is to parameterize and run simulations of a state-and-transition model based in MLRA 42 (Southern desertic basins, plains, and mountains) which covers portions of southern New Mexico and west Texas. 

## Data  
__Ground_data__ contains data from on the ground vegetation measurements.

__Raster_data__ contains rasters used in analysis. Raster data sets include elevation, soil maps, and fractional cover. 

__MLRA42_boundary__ contains shapefile of MLRA42 boundary. 


## Workflow
1. Get shrub cover raster data for area of interest
    - See "RCMAP" folder
2. Estimate transition probabilities
    - See "syncrosim test run" folder
3. Run simulations using rsyncrosim
    - See "rsyncrosim" folder
