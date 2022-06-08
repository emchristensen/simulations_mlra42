#' Create raster figures for SRM talk
#' 2/22/22

library(raster)
library(dplyr)

cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

shrub1986 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_1986_1990_categories.tif')
shrub1991 = raster('RAP/shrub rasters 5yr/RAP_shrubtree_1991_1995_categories.tif')

# new extent: subregion of MLRA 42
e = extent(-106.02,-106, 32.58, 32.6)

shrub1986_e = crop(shrub1986,e)
shrub1991_e = crop(shrub1991, e)

# create plots
shrub1986_df = rasterToPoints(shrub1986_e) %>% data.frame()
colnames(shrub1986_df) <- c('x','y','shrub')
plot1986 = ggplot(data=shrub1986_df, aes(x=x, y=y)) +
  geom_raster(aes(fill=as.factor(shrub))) +
  scale_fill_manual(breaks = c(2,3),
                    values = cbPalette[1:2],
                    labels = c('1','2')) +
  theme_bw() +
  labs(x = '', y = '', fill = 'State')
plot1986

ggsave('Figures/example_time1.png', plot=plot1986, width=4, height=4)

shrubtime2_df = rasterToPoints(shrub1991_e) %>% data.frame()
colnames(shrubtime2_df) <- c('x','y','shrub')
plottime2 = ggplot(data=shrubtime2_df, aes(x=x, y=y)) +
  geom_raster(aes(fill=as.factor(shrub))) +
  scale_fill_manual(breaks = c(2,3),
                    values = cbPalette[1:2],
                    labels = c('1','2')) +
  theme_bw() +
  labs(x = '', y = '', fill = 'State')
plottime2

ggsave('Figures/example_time2.png', plot=plottime2, width=4, height=4)

# ==================================================
# ran spatial-shrub only-small area in syncrosim

ts0 = raster('C:/Users/echriste/Desktop/scn66.sc.it1.ts0.tif')
ts6 = raster('C:/Users/echriste/Desktop/scn66.sc.it1.ts6.tif')

ts0_df = rasterToPoints(ts0) %>% data.frame()
colnames(ts0_df) <- c('x','y','State')
ts0plot = ggplot(data=ts0_df, aes(x=x, y=y)) +
  geom_raster(aes(fill=as.factor(State))) +
  scale_fill_manual(breaks = c(1,2,3),
                    values = cbPalette[c(1,2,5)],
                    labels = c('no shrub','low shrub','shrubland')) +
  theme_bw() +
  labs(x = '', y = '', fill = 'State')
ts0plot

ggsave('Figures/raster_1986.png', plot=ts0plot, width=4, height=3)

ts6_df = rasterToPoints(ts6) %>% data.frame()
colnames(ts6_df) <- c('x','y','State')
ts6plot = ggplot(data=ts6_df, aes(x=x, y=y)) +
  geom_raster(aes(fill=as.factor(State))) +
  scale_fill_manual(breaks = c(1,2,3),
                    values = cbPalette[c(1,2,5)],
                    labels = c('no shrub','low shrub','shrubland')) +
  theme_bw() +
  labs(x = '', y = '', fill = 'State')
ts6plot

ggsave('Figures/raster_2020.png', plot=ts6plot, width=4, height=3)

# actual 2020
classes2020 = raster('syncrosim test run/shrubtree_2016_2020.tif')
actual20_df = rasterToPoints(classes2020) %>% data.frame()
colnames(actual20_df) <- c('x','y','State')
actual20plot = ggplot(data=actual20_df, aes(x=x, y=y)) +
  geom_raster(aes(fill=as.factor(State))) +
  scale_fill_manual(breaks = c(1,2,3),
                    values = cbPalette[c(1,2,5)],
                    labels = c('no shrub','low shrub','shrubland')) +
  theme_bw() +
  labs(x = '', y = '', fill = 'State')
actual20plot
ggsave('Figures/raster_2020_actual.png', plot=actual20plot, width=4, height=3)

# ==============================
# state class percent covers

# predicted
endclasses = read.csv('syncrosim test run/State Classes.csv') %>%
  dplyr::filter(Timestep %in% c(6))

# get amount as %
total = sum(endclasses$Amount[endclasses$Iteration==1 & endclasses$Timestep==6])
endclasses$total=total
endclasses$pct = endclasses$Amount/endclasses$total

predicted2020 = ggplot(endclasses, aes(x=Timestep, y=pct, fill=StateClassID)) +
  geom_bar(position='stack', stat='identity') +
  scale_fill_manual(
                    values = cbPalette[c(1,2,5)],
                    labels = c('low shrub','no shrub','shrubland')) +
  labs(x='', y='', fill='State') +
  theme_bw() +
  theme(axis.text.x=element_blank(),
        axis.ticks.x=element_blank())
predicted2020
ggsave('Figures/predicted2020states.png', plot=predicted2020, width=2, height=3)


# actual 2020
classes2020 = raster('syncrosim test run/shrubtree_2016_2020.tif')
actual2020 = freq(classes2020) %>% data.frame()
actual2020$pct = actual2020$count/sum(actual2020$count)

# actual 1986
classes1986 = raster('syncrosim test run/shrubtree_1986_1990.tif')
actual1986 = freq(classes1986) %>% data.frame()
actual1986$pct = actual1986$count/sum(actual1986$count)
