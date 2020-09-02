#maps to explore the relationship between tourism and car club locations in the UK
library(tidyverse)
library(ggplot2)
library(cowplot)
library(viridis)
library(gtools)
library(sp)
library(sf)


### plot of tourism  classification over the UK
#----------------------------------------------

#read wrangled tourism data (on Unitary Authority and LAD level)
tourism <- read.csv("data/wrangled/tourism_wrangled.csv")

#load LAD shapefile
lad.sf <- st_read("data/wrangled/LAD_shapefile/LAD.shp")

#create sf object
tourism.sf <- left_join(select(lad.sf,lad,Region,geometry),select(tourism,lad,tourism_cluster)) %>%
  filter(!(Region %in% c("Scotland","Northern Ireland")) & tourism_cluster > 0) 

tourism.sf$tourism_cluster <- factor(tourism.sf$tourism_cluster) 

map1 <- ggplot() +
  geom_sf(data = tourism.sf, aes(fill = tourism_cluster)) +
  scale_fill_viridis(discrete = TRUE, name = "Tourism cluster",na.translate=FALSE) +
  theme_map() +
  ggtitle("Tourism clusters in England and Wales", 
          subtitle = "The clusters represent areas with similar tourism characteristics") +
  theme(plot.title = element_text(size = 12, face = "bold"),
        legend.text = element_text(size = 10),
        legend.title = element_text(size = 10),
        legend.direction = "horizontal",
        legend.position = "top") 


char1 <- "The smallest cluster which is characterised by higher than average inbound visits for purposes other than business, holiday, or visiting friends and relatives (VFR). \n
The cluster does not share the characteristics of areas where holiday, \n
VFR and business trips (overnight or day visit) are more prevalent."

char2 <- "This cluster is dominated by inbound tourism characteristics, including higher % of nights stayed and expenditure by Asian and African tourists, and higher % of nights stayed and expenditure on studying by all inbound visitors. This cluster highlights the study purpose of trip from overseas visitors." 

char3 <- "This cluster has the following characteristics; higher % age 16-19 tourism workers, also as main job; higher % 65-69 year olds in tourism as main job; higher % day visits with the purpose of exploring an area; higher % trips 4-7 nights for holiday and business, higher % nights stayed and expenditure by European visitors. This cluster, therefore, has tourism importance shown in terms of certain types of day visit, domestic overnight and inbound tourism."

char4 <- "This cluster has high percentage of holiday trips of length 1-3 nights, a characteristic of urban tourism. Inbound tourists also have a much higher percentage of expenditure on holidays and domestic tourists have a higher expenditure per trip ratio, again consistent with urban tourism. There is a higher than average % of nights stayed for holiday purposes, compared to business, studying, VFR or ‘other’ trips, by all inbound visitors. Tourism is also important in this cluster in terms of the tourism economy with a higher % tourism enterprises; a higher % of tourism workers are aged 30 to 39; a higher % of workers have a degree or higher education qualification, and a higher % workers in England and Wales age 25 to 64 are working in the tourism industry."


char5 <- "Cluster 5 is characterised by higher % jobs in accommodation for visitors; higher % day visits for outdoor leisure activities and exploring an area; higher % 16 to 19 workers in the tourism industry; higher % nights stayed and expenditure by European inbound visitors; higher % holiday and VFR length 4-7 nights; higher nights per trip ratio; and higher % nights stayed and expenditure on holidays. There is a higher than average expenditure per trip. This cluster is characterised, therefore with holiday and outdoor activity in keeping with the geographical areas covered."


geog1 <- "Kingston upon Hull; City of, North East Lincolnshire and North Lincolnshire."

geog2 <- "Northern and mid England urban areas, urban areas to the west of London and some larger counties throughout the Midlands and South England."

geog3 <- "South, South-East and North-East Wales (excluding Cardiff), Mid-West England, North-East England, East Riding of Yorkshire, locations bordering North-West to South-East of London, West Sussex and Plymouth."

geog4 <- "Greater London and York"

geog5 <- "Mid, North and West Wales, South West England, with parts of East Anglia, the North, the Isle of Wight and East Sussex"

tourism_table <- data.frame(`Tourism cluster` = c("Cluster 1", "Cluster 2", "Cluster 3", "Cluster 4", "Cluster 5"), `Characteristics` = c(char1,char2,char3,char4,char5),
                      `Geography` = c(geog1, geog2, geog3, geog4, geog5))

library(gridExtra)
pdf("tourism_cluster_table.pdf", height=20, width=20)
grid.table(tourism_table)
dev.off()

#https://www.ons.gov.uk/peoplepopulationandcommunity/leisureandtourism/bulletins/subnationaltourism/aspatialclassificationofareasinenglandandwalestoshowtheimportanceoftourismatcountyandunitaryauthoritylevel2011to2013



### map of tourism with car club lots plotted on top 
#get centroid of each LAD that contains car club lots

como_lad_c <- como_lad.sf %>%
  filter(!is.na(n_lots)) %>%
  select(lad_name, n_lots, n_lots_q, Region, geometry) %>%
  st_centroid()

como_lad_c2 <- como_lad_c %>%
  filter(!(Region %in% c("Scotland","Northern Ireland")))

p2 <- ggplot() +
  geom_sf(data = tourism.sf, aes(fill = tourism_cluster)) +
  scale_fill_viridis(discrete = TRUE, name = "",na.translate=FALSE) +
  geom_sf(data = como_lad_c2, aes(size = n_lots_q, colour = n_lots_q), alpha = 0.7) +
  # guides(size = guide_legend("Number of car club lots"),
  #      fill = FALSE) +
  guides(fill = FALSE, size = guide_legend("Number of car club lots"), colour = guide_legend("Number of car club lots")) +
  scale_colour_brewer(guide = "legend", palette = "Reds",labels = c("1","2-3","4-10","11-374")) +
  #scale_colour_viridis(guide = "legend") +
  scale_size_discrete(labels = c("1","2-3","4-10","11-374")) +
  #  scale_colour_discrete(labels = c("1","2-3","4-10","11-374")) +
  theme_map() +
  ggtitle(" ") +
  theme(plot.title = element_text(size = 12, face = "bold"),
        legend.text = element_text(size = 10),
        legend.title = element_text(size = 10),
        legend.direction = "horizontal",
        legend.position = "top") 

