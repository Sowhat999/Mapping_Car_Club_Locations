#exploring the relationship between car clubs and parking surplus
library(tidyverse)
library(ggplot2)
library(cowplot)
library(viridis)
library(gtools)
library(sp)
library(sf)

#read parking revenue data (Local Authority level)
parking_revenue <- read.csv("data/wrangled/parking_revenue_wrangled.csv")

#load LAD shapefile
lad.sf <- st_read("data/wrangled/LAD_shapefile/LAD.shp")

#create quantile of revenues
parking_revenue$surplus_q <- quantcut(parking_revenue$surplus, q = 5)

#create sf object
parking_revenue.sf <- right_join(lad.sf,parking_revenue)

### map of parking revenue
map1 <- ggplot() +
  geom_sf(data = parking_revenue.sf, aes(fill = surplus_q)) +
  scale_fill_viridis(discrete = TRUE, name = "Parking revenue (£ ,000)", labels = c("-1014 - 64", " 64 - 463", " 463 - 1230", " 1230 - 2820", " 2820 - 55900")) +
  theme_map() +
  labs(title = "Council parking revenue for local authorities in England",
        caption = "Data from the RAC foundation | Plot by @CaitlinChalk")
  theme(plot.title = element_text(size = 10, face = "bold"),
        plot.subtitle = element_text(size = 8),
        legend.text = element_text(size = 8),
        legend.title = element_text(size = 8),
        legend.position = c(0.05,0.6),
        plot.caption = element_text(size = 8))  


#save map as pdf
ggsave("maps/parking_surplus_lad.pdf", plot = map1, width = 15, units = "cm")

#save as png
png("maps/parking_surplus_lad.png", units="in", width=8, height=7, res=500)
plot_grid(map1)
dev.off()

### map of parking revenue with car club locations overlain

#read car club data at lad level
car_clubs_lad <- read.csv("data/wrangled/car_clubs_lad.csv")

#compute quantiles for the number of lots
car_clubs_lad$n_lots_q <- quantcut(car_clubs_lad$n_lots, q = 4)

#create sf object
car_clubs_lad.sf <- right_join(lad.sf,car_clubs_lad)

#filter car clubs in England only
car_clubs_lad.sf <- car_clubs_lad.sf %>%
  filter(!(Region %in% c("Scotland", "Wales", "Northern Ireland")))

#get centroid of each LAD that contains car club lots
car_clubs_c <- st_centroid(car_clubs_lad.sf)

#plot centroid on top of parking revenue map
#the size of the pointer represents how many car clubs are in that local authority

map2 <- ggplot() +
  geom_sf(data = parking_revenue.sf, aes(fill = surplus_q)) +
  scale_fill_viridis(discrete = TRUE, name = "Parking revenue (£ ,000)", labels = c("-1014 - 64", " 64 - 463", " 463 - 1230", " 1230 - 2820", " 2820 - 55900"),na.translate=FALSE) +
  geom_sf(data = car_clubs_c, aes(size = n_lots_q, colour = n_lots_q), alpha = 0.7) +
#  scale_size(range = c(2,12)) +
  guides(size = guide_legend("Number of car club lots"), colour = guide_legend("Number of car club lots")) +
  scale_colour_brewer(guide = "legend", palette = "Reds",labels = c("1","2-3","4-10","11-374")) +
  scale_size_discrete(labels = c("1","2-3","4-10","11-374")) +
  theme_map() +
  labs(title = "Council parking revenue for local authorities in England",
     subtitle = " The red dots denote local authorities that contain car club lots",
       caption = "Parking data from the RAC foundation | Car club data scraped from como.org.uk | Plot by @CaitlinChalk")
  theme(plot.title = element_text(size = 10, face = "bold"),
      plot.subtitle = element_text(size = 8),
      legend.text = element_text(size = 8),
      legend.title = element_text(size = 8),
      legend.position = c(0.05,0.6),
      plot.caption = element_text(size = 6)) 

#save map as pdf
ggsave("maps/parking_surplus_with_car_clubs.pdf", plot = map2, width = 15, units = "cm")

#save as png
png("maps/parking_surplus_with_car_clubs.png", units="in", width=8, height=7, res=500)
plot_grid(map2)
dev.off()


### plot both maps side by side

map1b <- map1 + 
  ggtitle("Council parking revenue (2015-2016) and car clubs (2020) for local authorities in England.",
          subtitle = " The red dots denote local authorities that contain car club lots
          \n Parking data provided by http://www.racfoundation.org/media-centre/parking-profits-break-three-quarters-of-a-billion
          \n Car club locations are scraped from https://como.org.uk/shared-mobility/shared-cars/where/") +
  theme(legend.position = c(0.05,0.8),
        legend.text = element_text(size = 8),
        legend.title = element_text(size = 8))
  
map2b <- map2 +
  guides(fill = FALSE) +
  ggtitle(" ", subtitle = " ") +
  theme(legend.position = c(0.05,0.8),
        legend.text = element_text(size = 8),
        legend.title = element_text(size = 8)) 

map3 <- plot_grid(map1b,map2b,align = "hv")

#save map
ggsave("maps/parking_surplus_with_car_clubs_2maps.pdf", plot = map3, width = 20, units = "cm")


### scatter plot showing the relationship between parking surplus and the number of car club lots per LAD
car_clubs_lad <- left_join(car_clubs_lad,parking_revenue) 

p1 <- ggplot(car_clubs_lad, aes(x = n_lots, y = surplus, fill = n_lots)) +
  geom_point(shape = 21, alpha = 0.8, size = 5) +
  scale_fill_viridis(option = "D", name = "Number of lots") +
  labs(x = "Number of car club lots", y = "Council parking surplus (£, 000)") +
  ggtitle("The number of car club vehicles per local authority \n vs council parking revenue") +
  scale_x_log10() + 
  scale_y_log10() +
  theme_classic() +
  theme(legend.position = c(0.85,0.4), plot.title = element_text(size = 12),
        legend.title = element_text(size = 10), legend.text = element_text(size = 10))

ggsave("plots/parking_surplus_carclub_lots.pdf", plot = p1, width = 15, height = 10, units = "cm")








