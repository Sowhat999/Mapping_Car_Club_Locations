library(tidyverse)
library(tmap)
library(ggplot2)
library(cowplot)
library(viridis)
library(gtools)
library(sp)
library(sf)
library(grDevices)

# creates interactive map of car club locations in the UK
# similar to the one displayed on the comouk website: https://como.org.uk/shared-mobility/shared-cars/Where/
#-----------------------------------------------------------------------------------------------

### load data

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

### create logos for each operator

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

#create interactive map
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
  tm_layout(title = "Car club lot locations in the UK, scraped from como.org.uk")

#save map as html
tmap_save(map_cc, file = "maps/car_club_locations.html")

