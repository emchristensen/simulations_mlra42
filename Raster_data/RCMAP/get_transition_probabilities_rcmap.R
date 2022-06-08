#' Estimate transition probabilities from RCMAP rasters
#' 
#' First crop raw rasters and categorize into three states:
#'   1 = no shrub (0-2%)
#'   2 = low shrub (2-15%)
#'   3 = shrubland (>15%)
#' 
#' 
#' EMC 5/17/22
#' 
#' Deprecated 6/3/22: this analysis is now combined with get_transition_probabilities_by_soil.R


library(dplyr)
library(terra)
library(rgdal)




# ============================================================================

# loop through each consecutive time step
filelist = list.files('RCMAP/staterasters', pattern = '*.tif$', full.names=T)

probabilities = c()
n = 1
while (n<length(filelist)) {
  step1 = rast(filelist[n])
  step2 = rast(filelist[n+1])
  
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
  prob = data.frame(timestep=n,
                    prob_1_2=max(prob_1_2,0),
                    prob_1_3=max(prob_1_3,0),
                    prob_2_1=max(prob_2_1,0),
                    prob_2_3=max(prob_2_3,0),
                    prob_3_1=max(prob_3_1,0),
                    prob_3_2=max(prob_3_2,0))
  
  probabilities = rbind(probabilities, prob)
  # go to next time step 
  n = n + 1
}

# add row of means
probabilities = rbind(probabilities, summarize_all(probabilities, mean))

# write csv
write.csv(probabilities, 'RCMAP/transition_probabilities.csv', row.names = F)
