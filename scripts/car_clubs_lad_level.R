library(tidyverse)
library(tmap)
library(ggplot2)
library(cowplot)
library(viridis)
library(gtools)
library(sp)
library(sf)
library(grDevices)

# mapping car club distribution at the Local Authority District (LAD) level
#-----------------------------------------------------------------------------------------------

### Extract LAD-level information - number of operators per LAD, and number of lots per LAD

#read csv file containing car club locations
car_clubs <- read.csv("data/wrangled/car_club_locations.csv")

#get the number of operators and vehicles per lad 
car_clubs_lad <- car_clubs %>%
  group_by(lad) %>%
  summarise(lad_name = lad_name[1], n_lots = n(), 
            n_vehicles = sum(number_of_vehicles), n_operators = length(unique(operator))) 

#read lad shapefile
lad.sf <- st_read("data/wrangled/LAD_shapefile/LAD.shp")

#add region to car_clubs_lad
car_clubs_lad <- left_join(car_clubs_lad, select(data.frame(lad.sf), lad, Region))

#save data to file
write.csv(car_clubs_lad, file = "data/wrangled/car_clubs_lad.csv", row.names = FALSE)

#compute quantiles for the number of lots
car_clubs_lad$n_lots_q <- quantcut(car_clubs_lad$n_lots, q = 4)

#convert plotting variables to factors
car_clubs_lad$n_lots_q <- factor(car_clubs_lad$n_lots_q)
car_clubs_lad$n_operators <- factor(car_clubs_lad$n_operators)

#create sf object
car_clubs_lad.sf <- left_join(lad.sf,car_clubs_lad)

#extract London only:
cc_london.sf <- car_clubs_lad.sf %>% filter(Region == "London")

#bounding box of London
london_bbox <- st_bbox(cc_london.sf)


### map of number of operators per lad, showing London in closer detail 

#get UK background
UK <- map_data("world") %>% filter(region=="UK")

ggm1 <- ggplot() +
  geom_polygon(data = UK, aes(x=long, y = lat, group = group), fill="grey", alpha=0.9) +
  geom_sf(data = car_clubs_lad.sf, aes(fill = n_operators)) +
  geom_rect(aes(xmin = london_bbox$xmin, xmax = london_bbox$xmax, ymin = london_bbox$ymin , ymax =   london_bbox$ymax), fill = NA, colour = "black", size = 1.5) +
  scale_fill_brewer(palette = "Set1", name = "No. of operators",na.translate=FALSE) +
  theme_map() +
  ylim(50, 58.5) +
  labs(title = "Car club operators per local authority in the UK",
          subtitle = "The blank areas don't have any car club coverage",
      caption = "Data scraped from como.org.uk | Plot by @CaitlinChalk") +
  theme(plot.title = element_text(size = 10, face = "bold"),
        plot.subtitle = element_text(size = 8),
        legend.text = element_text(size = 8),
        legend.title = element_text(size = 8),
        plot.caption = element_text(size = 8),
        legend.direction = "horizontal",
        legend.position = "top") 

#London only
ggm2 <- ggplot() +
  geom_sf(data = cc_london.sf, aes(fill = n_operators)) +
  scale_fill_brewer(palette = "Set1", name = "",na.translate=FALSE) +
  guides(fill = FALSE) +
  ggtitle("London") +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        plot.title = element_text(size = 10)) 


#combine two plots as one
map1 <- ggdraw() +
  draw_plot(ggm1) +
  draw_plot(ggm2, x = 0.6, y = 0.5, width = 0.25, height = 0.25)

#save as pdf
ggsave("maps/operators_per_lad.pdf", plot = map1, width = 15, units = "cm")

#save as png
png("maps/operators_per_lad.png", units="in", width=8, height=7, res=500)
plot_grid(map1)
dev.off()

### map of number of lots per lad 

ggm1 <- ggplot() +
  geom_polygon(data = UK, aes(x=long, y = lat, group = group), fill="grey", alpha=0.9) +
  geom_sf(data = car_clubs_lad.sf, aes(fill = n_lots_q)) +
  geom_rect(aes(xmin = london_bbox$xmin, xmax = london_bbox$xmax, ymin = london_bbox$ymin , ymax = london_bbox$ymax), fill = NA, colour = "black", size = 1.5) +
  scale_fill_viridis(discrete = TRUE, name = "",na.translate=FALSE, labels = c("1", "2-3", "4-10", "11-374")) + 
  #scale_fill_gradientn(colours=rev(rainbow(5)), name = "") +
  theme_map() +
  ylim(50, 58.5) +
  #scale_fill_manual(values = mypalette2, name = "") +
  labs(title = "The number of car club lots per local authority",
          subtitle = "The blank areas don't have any car club coverage",
          caption = "Data scraped from como.org.uk | Plot by @CaitlinChalk") +
  theme(plot.title = element_text(size = 12, face = "bold"),
        plot.caption = element_text(size = 8),
        legend.text = element_text(size = 10),
        legend.title = element_text(size = 10),
        legend.direction = "horizontal",
        legend.position = "top") 

ggm2 <- ggplot() +
  geom_sf(data = cc_london.sf, aes(fill = n_lots_q)) +
  # scale_fill_viridis(discrete = TRUE, name = "Number of operators",option = "E") +
  scale_fill_viridis(discrete=TRUE) +
  guides(fill = FALSE) +
  ggtitle("London") +
  theme_bw() +
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        plot.title = element_text(size = 10)) 

map2 <- ggdraw() +
  draw_plot(ggm1) +
  draw_plot(ggm2, x = 0.6, y = 0.5, width = 0.25, height = 0.25)

#save as pdf
ggsave("maps/lots_per_lad.pdf", plot = map2, width = 12, units = "cm")

#save as png
png("maps/lots_per_lad.png", units="in", width=8, height=7, res=500)
plot_grid(map2)
dev.off()




