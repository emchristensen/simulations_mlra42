#' get total cover by state from each RAP raster
#' EMC 9/17/21

library(dplyr)
library(ggplot2)
library(raster)

# test file
#rasterfile = 'RAP/state_raster_1999.tif'

file_list = list.files('RAP/', pattern = '*.tif', full.names=T)

# final data frame
allyearscover = c()

for (rasterfile in file_list) {
  
  # get year from file name
  year = unlist(strsplit(tools::file_path_sans_ext(basename(rasterfile)),'_'))[[3]]
  
  rasterdat = raster(rasterfile)
  
  plot(rasterdat)
  
  # get total number of cells that have values
  total = ncell(rasterdat[!is.na(rasterdat)])
  
  # get number of cells in each state
  state_pct = freq(rasterdat) %>% as.data.frame() %>% mutate(pct=count/total)
  
  # convert to wide format
  state_pct_wide = state_pct %>% dplyr::select(-count) %>%
    tidyr::pivot_wider(names_from = value, values_from = pct) %>%
    mutate(year=as.numeric(year),
           total_pix = total)
  
  # append to data frame
  allyearscover = rbind(allyearscover, state_pct_wide)
}

finaldf = allyearscover %>% dplyr::select(year, total_pix, state1=1, state2=2, state3=3, state4=4)

write.csv(finaldf, 'RAP/state_cover_1984_2020.csv', row.names=F)

# plot timeseries
ggplot(finaldf, aes(x=year, y=state1)) +
  geom_line(aes(color='grass')) +
  geom_line(aes(y=state2, color='mixed')) +
  geom_line(aes(y=state3, color='shrub')) +
  geom_line(aes(y=state4, color='barren'))
