#reads car club location data and produces maps showing their locations in the UK

library(tmap)
library(ggplot2)
library(cowplot)
library(viridis)
library(gtools)
library(sp)
library(sf)

### interactive map of car club locations in the UK
#similar to the one displayed on the comouk website: https://como.org.uk/shared-mobility/shared-cars/Where/
#-----------------------------------------------------------------------------------------------

#read csv file containing comouk locations
car_clubs <- read.csv("data/wrangled/car_club_locations.csv")

#create sf object
coords.tmp <- cbind(car_clubs$lon, car_clubs$lat)
car_clubs.sp <- SpatialPointsDataFrame(coords.tmp, data = data.frame(car_clubs))
car_clubs.sf <- st_as_sf(car_clubs.sp)
st_crs(car_clubs.sf) <- 4326 #set coordinate reference system

#move operator to the front (which makes it the label in tmap viewing mode)
car_clubs.sf <- select(car_clubs.sf, operator, everything())

#read dataframe containing link to logos of each operator (scraped from como website)
logos <- read.csv("logos/car_club_logos.csv")

#the logos will be used as markers on the map of the car club locations using tmap_icons
#tmap_icons requires logos to be .png. The Enterprise logo is jpeg, so a png version has been saved separately in the logos folder

### create logos

#define logo dimensions
logo_size = 30

logo_enterprise <- tmap_icons(
  "logos/enterprise.png",
  width = logo_size,
  height = logo_size,
  keep.asp = TRUE,
  just = c("center", "center"),
  as.local = TRUE
) 

logo_cowheels <- tmap_icons(
  logos$logo[logos$operator == "Co-Wheels"],
  width = logo_size,
  height = logo_size,
  keep.asp = TRUE,
  just = c("center", "center"),
  as.local = TRUE
) 

logo_ubeeqo <- tmap_icons(
  logos$logo[logos$operator == "Ubeeqo"],
  width = logo_size,
  height = logo_size,
  keep.asp = TRUE,
  just = c("center", "center"),
  as.local = TRUE
) 

logo_zipcar <- tmap_icons(
  logos$logo[logos$operator == "Zipcar"],
  width = logo_size,
  height = logo_size,
  keep.asp = TRUE,
  just = c("center", "center"),
  as.local = TRUE
) 

logo_zipcarflex <- tmap_icons(
  logos$logo[logos$operator == "Zipcar Flex"],
  width = logo_size,
  height = logo_size,
  keep.asp = TRUE,
  just = c("center", "center"),
  as.local = TRUE
) 

### plot with tmap

#interactive viewing
tmap_mode("view")

#create map
map_cc <- tm_shape(filter(car_clubs.sf, operator == "Co-Wheels")) +
  tm_markers(shape = logo_cowheels, clustering = TRUE) +
  tm_shape(filter(car_clubs.sf, operator == "Enterprise Car Club")) +
  tm_markers(shape = logo_enterprise, clustering = TRUE) +
  tm_shape(filter(car_clubs.sf, operator == "Ubeeqo")) +
  tm_markers(shape = logo_ubeeqo, clustering = TRUE) +
  tm_shape(filter(car_clubs.sf, operator == "Zipcar")) +
  tm_markers(shape = logo_zipcar, clustering = TRUE) +
  tm_shape(filter(car_clubs.sf, operator == "Zipcar Flex")) +
  tm_markers(shape = logo_zipcarflex, clustering = TRUE) +
  tmap_options(basemaps = "OpenStreetMap") +
  tm_layout(title = "Car club lot locations in the UK, scraped from car_clubs.org.uk")

tmap_save(map_cc, file = "maps/car_club_locations.html")


### car clubs at the Local Authority District (LAD) scale 
#-----------------------------------------------------------------------------------------------
#lad variables - number of operators, and number of lots


#read car club data at lad level
car_clubs_lad <- read.csv("data/wrangled/car_clubs_lad.csv")

#compute quantiles for the number of lots
car_clubs_lad$n_lots_q <- quantcut(car_clubs_lad$n_lots, q = 4)

#convert plotting variables to factors
car_clubs_lad$n_lots_q <- factor(car_clubs_lad$n_lots_q)
car_clubs_lad$n_operators <- factor(car_clubs_lad$n_operators)

#read lad shapefile
lad.sf <- st_read("data/wrangled/LAD_shapefile/LAD.shp")

#create sf object
car_clubs_lad.sf <- left_join(lad.sf,car_clubs_lad)
#car_clubs_lad.sf$n_operators <- factor(car_clubs_lad.sf$n_operators)

#extract London only:
cc_london.sf <- car_clubs_lad.sf %>% filter(Region == "London")

#bounding box
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
        plot.caption = element_text(size = 6),
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

ggsave("maps/operators_per_lad.pdf", plot = map1, width = 15, units = "cm")


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
        plot.caption = element_text(size = 6),
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

map_cc3 <- ggdraw() +
  draw_plot(ggm1) +
  draw_plot(ggm2, x = 0.6, y = 0.5, width = 0.25, height = 0.25)

ggsave("maps/lots_per_lad.pdf", plot = map_cc3, width = 12, units = "cm")





