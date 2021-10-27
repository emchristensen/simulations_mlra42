#' get timeseries of states for each pixel
#' 

library(dplyr)
library(raster)

file_list = list.files('RAP/raw files', pattern = '*.tif', full.names=T)

#raw_file <- 'RAP/raw files/RAP_cover_v2_1988.tif'

raw_file = file_list[31]
file_list2 = file_list[1:3]


pixel_df = c()

for (raw_file in file_list) {
  # get year from file name
  year = unlist(strsplit(tools::file_path_sans_ext(basename(raw_file)),'_'))[4]
  
  # read in raster stack
  s = stack(raw_file)
  
  # create objects for important raster layers
  perennialforbgrass = s@layers[[4]]
  shrubcover = s@layers[[5]]
  treecover = s@layers[[6]]
  barecover = s@layers[[2]]
  littercover = s@layers[[3]]
  annualcover = s@layers[[1]]
  
  perennialuncert = s@layers[[10]]
  shrubuncert = s@layers[[11]]
  bareuncert = s@layers[[8]]
  treeuncert = s@layers[[12]]
  litteruncert = s@layers[[9]]
  annualuncert = s@layers[[7]]
  
  # combine veg and nonveg elements
  #shrubtree = shrubcover + treecover
  #nonveg = littercover + barecover
  #nonveg_uncert = litteruncert + bareuncert
  #veg = treecover + shrubcover + perennialforbgrass
  #veg_uncert = treeuncert + shrubuncert + perennialuncert
  
  # get values into data frame
  pixels = stack(list(shrub=shrubcover, shrub_uncert=shrubuncert, tree=treecover, tree_uncert=treeuncert, bare=barecover, bare_uncert=bareuncert,
                      perennial=perennialforbgrass, perenn_uncert = perennialuncert, litter=littercover, litter_uncert=litteruncert, annuals=annualcover,
                      annual_uncert=annualuncert)) #, veg=veg, veg_uncert=veg_uncert, nonveg=nonveg, nonveg_uncert=nonveg_uncert))
  df = as.data.frame(pixels, xy=T) %>% mutate(year=year)
  
  pixel_df = rbind(pixel_df, df)
  
}


# create data frame of pixel IDs
pixid = dplyr::select(pixel_df, x, y) %>%
  unique() %>%
  tibble::rowid_to_column('ID')
pixel_df = merge(pixid, pixel_df)

pixel_df$shrubtree = pixel_df$shrub + pixel_df$tree

# assign each pixel to a state class
# 1 = grass; 2 = mixed; 3 = shrub; 4 = barren; 5 = invaded
pixel_df$state = NA
pixel_df$state[pixel_df$shrubtree<1 & pixel_df$perennial>=3] <- 1
pixel_df$state[pixel_df$shrubtree>=1 & pixel_df$shrubtree<15 & pixel_df$perennial>=3] <- 2
pixel_df$state[pixel_df$shrubtree>=15] <- 3
pixel_df$state[pixel_df$shrubtree<15 & pixel_df$perennial<3 & pixel_df$bare>85] <- 4


# write to csv for later
write.csv(pixel_df, 'RAP/pixel_cover_all.csv', row.names = F)

# =========================================================
pixel_df = read.csv('RAP/pixel_cover_all.csv')

# explore one pixel
onepix = dplyr::filter(pixel_df, ID==2254)

ggplot(onepix, aes(x=as.numeric(year))) +
  geom_point(aes(y=shrub, color='s')) +
  geom_smooth(aes(y=shrub, color='s')) +
  geom_point(aes(y=perennial, color='p')) +
  geom_smooth(aes(y=perennial, color='p')) +
  geom_point(aes(y=bare, color='b')) +
  geom_smooth(aes(y=bare, color='b'))
