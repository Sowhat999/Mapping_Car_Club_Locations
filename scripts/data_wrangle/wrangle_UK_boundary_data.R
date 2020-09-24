#script to read in UK boundary data at different scales
library(tidyverse)
library(sf)
library(sp)
library(tmap)
library(RColorBrewer)
library(readxl)
library(curl)


### Local Authority District boundaries 
#source:
#https://data.gov.uk/dataset/d6f97a1a-25dc-485c-9af3-0e5681465d77/counties-and-unitary-authorities-december-2016-full-clipped-boundaries-in-england-and-wales
#----------------------------------------------------------------------------------------------
lad.sf <- st_read(dsn = "data/raw/UK_boundaries/Local_Authority_Districts_UK",layer = "la_boundaries")

#select relevant columns and remove islands (they don't have any car club lots and make the map longer)
lad.sf <- lad.sf %>%
  rename(lad_name = lad17nm, lad = lad17cd) %>%
  select(lad_name, lad, geometry) %>%
  filter(!(lad_name %in% c("Orkney Islands", "Shetland Islands", "Na h-Eileanan Siar")))

lad_original <- data.frame(lad.sf) %>% select(!geometry)

# Edit some outdated LAD names and codes for consistency with other data sets 
#(also for consistency with the lad codes and names from the ggmap package)

#combine Bournemouth, Christchurch and Pool as one (for consistency with other LA codes)
#combine Suffolk Coastal and Waveney as East Suffolk
#combine Forest Heath and St Edmundsbury as West Suffolk
#combine Aylesbury Vale and South Bucks as Buckinghamshire
#combine Weymouth and Portland, Purbeck, East and North Dorset as Dorset
#combine Taunton Deane and West Somerset as Somerset West and Taunton 

BCP <- lad.sf %>%
  filter(lad_name %in% c("Bournemouth","Christchurch", "Poole"))

ES <- lad.sf %>% 
  filter(lad_name %in% c("Suffolk Coastal", "Waveney"))

WS <- lad.sf %>% 
  filter(lad_name %in% c("St Edmundsbury","Forest Heath")) 

Buck <- lad.sf %>%
  filter(lad_name %in% c("Aylesbury Vale", "South Bucks"))

NED <- lad.sf %>% 
  filter(lad_name %in% c("North Dorset", "East Dorset", "West Dorset", "Purbeck", "Weymouth and Portland"))

TDWS <- lad.sf %>%
  filter(lad_name %in% c("Taunton Deane", "West Somerset"))

BCP2 <- st_combine(BCP)
ES2 <- st_combine(ES)
WS2 <- st_combine(WS)
Buck2 <- st_combine(Buck)
NED2 <- st_combine(NED)
TDWS2 <- st_combine(TDWS)

old_names <- list(c("Bournemouth", "Christchurch", "Poole"), c("Suffolk Coastal", "Waveney"),
                  c("St Edmundsbury", "Forest Heath"), c("Aylesbury Vale", "South Bucks", "Chiltern", "Wycombe"),
                  c("North Dorset", "East Dorset", "West Dorset", "Weymouth and Portland", "Purbeck"), c("Taunton Deane", "West Somerset"))

old_names_total <- unlist(old_names)


lad.sf <- lad.sf %>%
  add_row(lad_name = "Bournemouth, Christchurch and Poole", lad = "E06000058", 
          geometry = BCP2) %>%
  add_row(lad_name = "East Suffolk", lad = "E07000244", geometry = ES2) %>%
  add_row(lad_name = "West Suffolk", lad = "E07000245", geometry = WS2) %>%
  add_row(lad_name = "Buckinghamshire", lad = "E06000060", geometry = Buck2) %>%
  add_row(lad_name = "Dorset", lad = "E06000059", geometry = NED2) %>%
  add_row(lad_name = "Somerset West and Taunton", lad = "E07000246", geometry = TDWS2) %>%
  filter(!(lad_name %in% old_names_total))

#make a dataframe of these replacements for reference in other scripts: (also add West Dorset which is relevant in some cases)

new_names <- list("Bournemouth Christchurch and Poole","East Suffolk", "West Suffolk",
                  "Buckinghamshire", "Dorset", "Somerset West and Taunton")

new_codes <- list("E06000058","E07000244","E07000245","E06000060", "E06000059","E07000246")

old_codes <- lad_original %>%
  filter(lad_name %in% old_names_total)

lad_replace <- data.frame(old_name = old_names_total)
lad_replace <- left_join(lad_replace, old_codes, by = c("old_name" = "lad_name"))

lad_replace$new_codes <- as.character(new_codes)
lad_replace$new_names <- NA

n = length(old_names)
for (i in seq(1,n)){
  l = length(old_names[[i]])
  for (j in seq(1,l)){
    old_name2 <- old_names[[i]][j]
    lad_replace$new_names[lad_replace$old_name == old_name2] <- as.character(new_names[[i]])
  }
}

write.csv(lad_replace, 'data/wrangled/lad_replace.csv', row.names = FALSE)


#correct Glasgow city, Fife, North Lanarkshire and Perth and Kinross lad codes:
#(according to google)
lad.sf$lad[lad.sf$lad_name == "Glasgow City"] <- "S12000049" 
lad.sf$lad[lad.sf$lad_name == "Fife"] <- "S12000047" 
lad.sf$lad[lad.sf$lad_name == "Perth and Kinross"] <- "S12000048" 
lad.sf$lad[lad.sf$lad_name == "North Lanarkshire"] <- "S12000050" 

#download UK Regions data
#------------------------

temp <- tempfile()
source <- "https://opendata.arcgis.com/datasets/0c3a9643cc7c4015bb80751aad1d2594_0.csv"
temp <- curl_download(url=source, destfile=temp, quiet=FALSE, mode="wb")
LADtoRegion <- read.csv(temp)[,c(1,4)]
colnames(LADtoRegion) <- c("lad", "Region")

#add region to lad.sf
lad.sf <- left_join(lad.sf,LADtoRegion)

#convert regions to factor
lad.sf$Region <- factor(lad.sf$Region)

#add Wales, Scotland and Northern Ireland as regions
levels(lad.sf$Region) <-  c(levels(lad.sf$Region),"Scotland", "Wales", "Northern Ireland")

lad.sf$Region[grepl("^S",lad.sf$lad)] <- "Scotland"
lad.sf$Region[grepl("^W",lad.sf$lad)] <- "Wales"
lad.sf$Region[grepl("^N",lad.sf$lad)] <- "Northern Ireland"

#add Bournemouth, Dorset, and Somerset and Taunton to South West
lad.sf$Region[lad.sf$lad_name %in% c("Bournemouth, Christchurch and Poole", "Dorset", "Somerset West and Taunton" )] <- "South West"
#add East and West Suffolk to East of England
lad.sf$Region[lad.sf$lad_name %in% c("East Suffolk","West Suffolk")] <- "East of England"
#add Buckinghamshire to South East
lad.sf$Region[lad.sf$lad_name == "Buckinghamshire"] <- "South East"


### Unitary Authority boundaries
#source:
#https://geoportal.statistics.gov.uk/datasets/counties-and-unitary-authorities-december-2017-ultra-generalised-clipped-boundaries-in-uk-wgs84/data
#-----------------------------------------------------------------------------------------------

ua.sf <- st_read(dsn = "data/raw/UK_boundaries/Counties_and_UAs",layer = "UA")
ua.sf <- select(ua.sf,ua = ctyua17cd, ua_name = ctyua17nm, geometry)

#read LAD (lower tier) to Unitary Authority & county (upper tier) conversion data
#source - 

LADtoUA <-  read_csv("data/raw/UK_boundaries/Lower_tier_Upper_tier.csv")
LADtoUA <- select(LADtoUA,!FID)
colnames(LADtoUA) <- c("lad","lad_name","ua", "ua_name")

lad.sf <- left_join(lad.sf, select(LADtoUA, !lad_name))

#add UA name and code for Buckinghamshire:
lad.sf$ua_name[lad.sf$lad_name == "Buckinghamshire"] <- "Buckinghamshire"
lad.sf$ua[lad.sf$lad_name == "Buckinghamshire"] <- LADtoUA$ua[LADtoUA$ua_name == "Buckinghamshire"][1]  

#save shapefile
st_write(lad.sf, "data/wrangled/LAD_shapefile/LAD.shp", row.names = FALSE)


