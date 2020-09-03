#exploring the relationship between car clubs and accessibility
library(tidyverse)
library(ggplot2)
library(cowplot)
library(viridis)
library(gtools)
library(sp)
library(sf)

### load data

travel_times <- read.csv(file = "data/wrangled/accessibility_wrangled.csv")

#load LAD shapefile
lad.sf <- st_read("data/wrangled/LAD_shapefile/LAD.shp")

#create quantile of town_time variable
travel_times$town_time_q <- quantcut(travel_times$town_time, q = 5)

#create sf object
travel_times.sf <- right_join(lad.sf,travel_times)


### map of average travel time (to nearest town) per LAD

map1 <- ggplot() +
  geom_sf(data = travel_times.sf, aes(fill = town_time_q)) +
  scale_fill_viridis(discrete = TRUE, name = "Travel time (minutes)", labels = c("11 - 17",
                                                                                 "17 - 20",
                                                                                 "20 - 22",
                                                                                 "22 - 26",
                                                                                 "26 - 120")) +
  theme_map() +
  labs(title = "Average travel times for local authorities in England",
          subtitle = paste0("The contours represent the average travel times to the nearest town \nwith public transport or on foot"),
          caption="Data from the Deparment for Transport | Plot by @CaitlinChalk") +
  theme(plot.title = element_text(size = 10, face = "bold"),
        plot.subtitle = element_text(size = 8),
        legend.text = element_text(size = 8),
        legend.title = element_text(size = 8),
        legend.position = c(0.05,0.6),
        plot.caption = element_text(size = 8)) 


#save map as pdf
ggsave("maps/travel_time_lad.pdf", plot = map1, width = 15, units = "cm")

#save as png
png("maps/travel_time_lad.png", units="in", width=8, height=7, res=500)
plot_grid(map1)
dev.off()

### map of average travel time with car club locations

#read car club data at lad level
car_clubs_lad <- read.csv("data/wrangled/car_clubs_lad.csv")

#compute quantiles for the number of lots
car_clubs_lad$n_vehicles_q <- quantcut(car_clubs_lad$n_vehicles, q = 4)

#create sf object
car_clubs_lad.sf <- right_join(lad.sf,car_clubs_lad)

#filter car clubs in England only
car_clubs_lad.sf <- car_clubs_lad.sf %>%
  filter(!(Region %in% c("Scotland", "Wales", "Northern Ireland")))

#get centroid of each LAD that contains car club lots
car_clubs_c <- st_centroid(car_clubs_lad.sf)

#plot centroid on top of the travel time map
#the size of the pointer represents how many car clubs are in that local authority

map2 <- ggplot() +
  geom_sf(data = travel_times.sf, aes(fill = town_time_q)) +
  scale_fill_viridis(discrete = TRUE, name = "Travel time (minutes)", labels = c("11 - 17",
                                                                                 "17 - 20",
                                                                                 "20 - 22",
                                                                                 "22 - 26",
                                                                                 "26 - 120")) +
  geom_sf(data = car_clubs_c, aes(size = n_vehicles_q, colour = n_vehicles_q), alpha = 0.7) +
  guides(size = guide_legend("Number of car club vehicles"), colour = guide_legend("Number of car club vehicles")) +
  scale_colour_brewer(guide = "legend", palette = "Reds",labels = c("1","2-3","4-12", "13-386")) +
  scale_size_discrete(labels = c("1","2-3","4-12", "13-386")) +
  theme_map() +
  labs(title = "Average travel times and car clubs for local authorities in England",
       subtitle = paste0("The contours represent the average travel times to the nearest town with public transport \nor on foot. The red dots denote local authorities that contain car club lots"),
       caption="Travel time data from the Deparment for Transport | Car club data scraped from como.org.uk | Plot by @CaitlinChalk") +
    theme(plot.title = element_text(size = 10, face = "bold"),
        plot.subtitle = element_text(size = 8),
        legend.text = element_text(size = 8),
        legend.title = element_text(size = 8),
        legend.position = c(0.05,0.6),
        plot.caption = element_text(size = 8)) 

#save map as pdf
ggsave("maps/travel_time_with_car_clubs.pdf", plot = map2, width = 15, units = "cm")

#save as png
png("maps/travel_time_with_car_clubs.png", units="in", width=8, height=7, res=500)
plot_grid(map2)
dev.off()

### plot both maps side by side

map1b <- map1 + 
  theme(legend.position = c(0.05,0.8)) +
labs(title = "Average travel times and car clubs for local authorities in England",
     subtitle = paste0("The contours represent the average travel times to the nearest town with public transport or on foot. \nThe red dots denote local authorities that contain car club lots."),
     caption=" ") +
  theme(plot.title = element_text(size = 14, face = "bold"),
        plot.subtitle = element_text(size = 12),
        legend.text = element_text(size = 10),
        legend.title = element_text(size = 10),
        plot.caption = element_text(size = 10))
  

map2b <- map2 +
  guides(fill = FALSE) +
  labs(title = " ", subtitle = " ") +
  theme(legend.position = c(0.05,0.8),
        legend.text = element_text(size = 10),
        legend.title = element_text(size = 10),
        plot.caption = element_text(size = 10)) 

map3 <- plot_grid(map1b,map2b,align = "hv")

#save as png
png("maps/travel_time_with_car_clubs_2maps.png", units="cm", width=15, height=7, res=500)
plot_grid(map3)
dev.off()

### scatter plot showing the relationship between parking surplus and the number of car club lots per LAD
car_clubs_lad <- left_join(car_clubs_lad,travel_times) 

p1 <- ggplot(car_clubs_lad, aes(x = n_vehicles, y = town_time, fill = n_vehicles)) +
  geom_point(shape = 21, alpha = 0.8, size = 5) +
  scale_fill_viridis(option = "D", name = "Number of vehicles") +
  labs(x = "Number of car club vehicles", y = "Time to nearest town on foot or by public transport (minutes)") +
  ggtitle("The number of car club vehicles per local authority vs travel time to the nearest town") +
  scale_x_log10() + 
  scale_y_log10() +
  theme_classic() +
  theme(legend.position = c(0.65,0.8), plot.title = element_text(size = 10, face = "bold"),
        legend.title = element_text(size = 8), legend.text = element_text(size = 8),
        axis.title  = element_text(size = 7),
        legend.direction = "horizontal")

#save as png
png("maps/travel_time_cc_vehicles.png", units="in", width=6, height=3, res=500)
plot_grid(p1)
dev.off()

