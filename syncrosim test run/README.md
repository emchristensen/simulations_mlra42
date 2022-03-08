# syncrosim test run

MLRA 42 is a very large area, so test runs were done on a 1-deg by 1-deg geographic subregion.

__crop_rasters.R__ crops RAP data rasters to a manageable area for testing procedure. Depends on files in _RAP/shrub rasters 5yr_ folder. This script also creates an "initial_stratum.tif" file needed for SyncroSim runs, and crops soil and elevation rasters.

__get_transition_parameters.R__ Script to estimate transition parameters on cropped RAP data files. Saves probabilities to _syncrosim test run/probabilities.csv_

__probabilities.csv__ Data file containing transition probability estimates to be used for SyncroSim runs.