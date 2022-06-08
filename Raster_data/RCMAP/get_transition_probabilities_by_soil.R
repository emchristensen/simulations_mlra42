#' Estimate transition probabilities from RCMAP rasters; by soil
#' 
#' First crop raw rasters and categorize into three states:
#'   1 = no shrub (0-2%)
#'   2 = low shrub (2-15%)
#'   3 = shrubland (>15%)
#'   
#'   #' Soil categories:
#'   1 = sandy
#'   2 = deep sand
#'   3 = loamy-clayey
#'   4 = gravelly and calcic
#'   5 = bedrock and colluvium
#'   6 = gypsic
#'   7 = bottomland
#' 
#'  combine sand and deep sand
#' 
#' EMC 5/27/22


library(dplyr)
library(terra)
#library(rgdal)

# state raster file list
filelist = list.files('RCMAP/staterasters', pattern = '*.tif$', full.names=T)
testfile = terra::rast(filelist[1])

# soil raster
soilraster = terra::rast('Soil maps/ensemble_soil_map_MLRA42.tif')

# load mask raster
area_mask = terra::rast('RCMAP/study-area-mask.tif')

# get soil raster into same crs as RCMAP
soil = terra::project(soilraster, testfile) %>%
  crop(area_mask) %>% mask(area_mask)

# create mask for each soil type
sandymask = round(soil)
sandymask[sandymask >2] <- NA

loamymask = round(soil)
loamymask[loamymask != 3] <- NA

gravellymask = round(soil)
gravellymask[gravellymask != 4] <- NA

bedrockmask = round(soil)
bedrockmask[bedrockmask != 5] <- NA

gypsicmask = round(soil)
gypsicmask[gypsicmask != 6] <- NA

bottomlandmask = round(soil)
bottomlandmask[bottomlandmask != 7] <- NA

# ============================================================================
# function to get probabilities


#' @param filelist list of files in chronological order
#' @param area_mask mask to apply to each file in filelist

get_probabilities = function(filelist, area_mask) {
  
  probabilities_df = c()
  n = 1
  
  while (n<length(filelist)) {
    
    # read in two rasters
    step1 = rast(filelist[n]) %>% mask(area_mask)
    step2 = rast(filelist[n+1]) %>% mask(area_mask)
    
    # get years from raster file names
    year1 = readr::parse_number(filelist[n])
    year2 = readr::parse_number(filelist[n+1])
    
    # mask step2 by cells that were state 2 in step1
    step2_lowshrub = terra::mask(step2, step1==2, maskvalue=0)
    # count frequency of cells in each state in step 2
    step2_counts = freq(step2_lowshrub) %>% as.data.frame()
    # total number of cells that were state 2 in step 1
    total2 = sum(step2_counts$count[step2_counts$value %in% 1:3])
    # probability of going from state 2 to state 3
    prob_2_3 = step2_counts$count[which(step2_counts$value==3)]/total2
    # probability of going from state 2 to state 1
    prob_2_1 = step2_counts$count[which(step2_counts$value==1)]/total2
    
    # mask step2 by cells that were state 1 in step1
    step2_noshrub = terra::mask(step2, step1==1, maskvalue=0)
    # count frequency of cells in each state in step 2
    step2_counts_1 = freq(step2_noshrub) %>% as.data.frame()
    # total number of cells that were state 2 in step 1
    total1 = sum(step2_counts_1$count[step2_counts_1$value %in% 1:3])
    # probability of going from state 1 to state 3
    prob_1_3 = step2_counts_1$count[which(step2_counts_1$value==3)]/total1
    # probability of going from state 1 to state 2
    prob_1_2 = step2_counts_1$count[which(step2_counts_1$value==2)]/total1
    
    # mask step2 by cells that were state 3 in step1
    step2_shrub = terra::mask(step2, step1==3, maskvalue=0)
    # count frequency of cells in each state in step 2
    step2_counts_3 = freq(step2_shrub) %>% as.data.frame()
    # total number of cells that were state 2 in step 1
    total3 = sum(step2_counts_3$count[step2_counts_3$value %in% 1:3])
    # probability of going from state 3 to state 2
    prob_3_2 = step2_counts_3$count[which(step2_counts_3$value==2)]/total3
    # probability of going from state 3 to state 1
    prob_3_1 = step2_counts_3$count[which(step2_counts_3$value==1)]/total3
    
    # store probabilities in data frame
    prob = data.frame(timestep=paste(year1, year2, sep='-'),
                      prob_1_2=max(prob_1_2,0),
                      prob_1_3=max(prob_1_3,0),
                      prob_2_1=max(prob_2_1,0),
                      prob_2_3=max(prob_2_3,0),
                      prob_3_1=max(prob_3_1,0),
                      prob_3_2=max(prob_3_2,0))
    
    probabilities_df = rbind(probabilities_df, prob)
    # go to next time step 
    n = n + 1
  }
  
  # add row of means
  probabilities_df = rbind(probabilities_df, summarize_all(probabilities_df, mean))
  
  return(probabilities_df)
}

# =======================================================
# all soils, no masking

allprob = get_probabilities(filelist, area_mask)

# write csv
write.csv(allprob, 'RCMAP/transition_probabilities_all.csv', row.names = F)

# ========================================================
# soil type 1-2 sandy and deep sand

sandyprob = get_probabilities(filelist, sandymask)

# write csv
write.csv(sandyprob, 'RCMAP/transition_probabilities_sandy.csv', row.names = F)


# =============================================
# soil type 3 loamy-clayey

loamyprob = get_probabilities(filelist, loamymask)

# write csv
write.csv(loamyprob, 'RCMAP/transition_probabilities_loamy.csv', row.names = F)

# =============================================
# soil type 4 gravelly and calcic

gravellyprob = get_probabilities(filelist, gravellymask)

# write csv
write.csv(gravellyprob, 'RCMAP/transition_probabilities_gravelly.csv', row.names = F)

# =============================================
# soil type 5 bedrock and colluvium

bedrockprob = get_probabilities(filelist, bedrockmask)

# write csv
write.csv(bedrockprob, 'RCMAP/transition_probabilities_bedrock.csv', row.names = F)

# =============================================
# soil type 6 gypsic

gypsicprob = get_probabilities(filelist, gypsicmask)

# write csv
write.csv(gypsicprob, 'RCMAP/transition_probabilities_gypsic.csv', row.names = F)

# =============================================
# soil type 7 bottomland

bottomlandprob = get_probabilities(filelist, bottomlandmask)

# write csv
write.csv(bottomlandprob, 'RCMAP/transition_probabilities_bottomland.csv', row.names = F)
