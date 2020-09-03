#script to read and wrangle data regarding transport accessibility in the UK 
library(tidyverse)
library(sf)
library(sp)
library(tmap)
library(RColorBrewer)
library(readxl)
library(gtools)
library(openxlsx)

### 2017 travel times to nearest town by public transport or walking 
#https://www.gov.uk/government/statistical-data-sets/journey-time-statistics-data-tables-jts

#read in data  
travel_town <- read.xlsx("data/raw/contextual_open_data/journey_time_towns.xlsx", sheet = 2)
#organise column names and select columns of interest
colnames(travel_town) <- travel_town[5,]
travel_town <- travel_town[6:nrow(travel_town),]
travel_town <- select(travel_town, lad = LA_Code, lad_name = LA_Name, town_time = TownPTt, town_30mins_pct = TownPT30pct,
                      town_60mins_pct = TownPT60pct,town_30mins_cycle_pct = TownCyc30pct, town_30mins_car_pct = TownCar30pct)
travel_town$town_time <- as.numeric(travel_town$town_time)  
travel_town$town_30mins_pct <- as.numeric(travel_town$town_30mins_pct)
travel_town$town_60mins_pct <- as.numeric(travel_town$town_60mins_pct)
travel_town$town_30mins_cycle_pct <- as.numeric(travel_town$town_30mins_cycle_pct)
travel_town$town_30mins_car_pct <- as.numeric(travel_town$town_30mins_car_pct)

### replace incorrect lad names and codes

#read data containing outdated lads with replacements 
lad_replace <- read.csv("data/wrangled/lad_replace.csv")

#convert old name list (separated by " & " into list)
lad_replace$old_names <- lapply(lad_replace$old_names, strsplit, " & ")
#unlist to convert to vector
lad_replace$old_names <- lapply(lad_replace$old_names, unlist)
#add comma to Bournemouth, Christchurch and Poole
lad_replace$new_names[lad_replace$new_names == "Bournemouth Christchurch and Poole"] <- "Bournemouth, Christchurch and Poole"

#remove spaces from lad_names for better matching
travel_town$lad_name2 <- lapply(travel_town$lad_name, function(x)gsub('\\s+','',x))
lad_replace$old_names2 <- lapply(lad_replace$old_names, function(x)gsub('\\s+','',x))

#correct some LAD codes directly
travel_town$lad[travel_town$lad_name2 == "Stevenage"] <- lad_england.sf$lad[lad_england.sf$lad_name == "Stevenage"]
travel_town$lad[travel_town$lad_name2 == "StAlbans"] <- lad_england.sf$lad[lad_england.sf$lad_name == "St Albans"]
travel_town$lad[travel_town$lad_name2 == "WelwynHatfield"] <- lad_england.sf$lad[lad_england.sf$lad_name == "Welwyn Hatfield"]
travel_town$lad[travel_town$lad_name2 == "EastHertfordshire"] <- lad_england.sf$lad[lad_england.sf$lad_name == "East Hertfordshire"]
travel_town$lad[travel_town$lad_name2 == "Gateshead"] <- lad_england.sf$lad[lad_england.sf$lad_name == "Gateshead"]
travel_town$lad[travel_town$lad_name2 == "Northumberland"] <- lad_england.sf$lad[lad_england.sf$lad_name == "Northumberland"]

for (i in seq(1,nrow(lad_replace))){
  #list of old lad names for replacement
  old_lads <- travel_town$lad_name2[travel_town$lad_name2 %in% lad_replace$old_names2[[i]]]
  if (length(old_lads) > 0){
    #new, combined lad name
    new_lad <- lad_replace$new_names[[i]] 
    #new codes
    new_codes <- lad_replace$new_codes[[i]]
    #calculate the average travel times
    new_town_time <- mean(travel_town$town_time[travel_town$lad_name2 %in% lad_replace$old_names2[[i]]])
    new_town_30mins_pct <- mean(travel_town$town_30mins_pct[travel_town$lad_name2 %in% lad_replace$old_names2[[i]]])
    new_town_60mins_pct <- mean(travel_town$town_60mins_pct[travel_town$lad_name2 %in% lad_replace$old_names2[[i]]])
    new_town_30mins_cycle_pct <- mean(travel_town$town_30mins_cycle_pct[travel_town$lad_name2 %in% lad_replace$old_names2[[i]]])
    new_town_30mins_car_pct <- mean(travel_town$town_30mins_car_pct[travel_town$lad_name2 %in% lad_replace$old_names2[[i]]])
    
    #add new data to travel_town and remove old data
    travel_town <- travel_town %>%
      add_row(lad = new_codes, lad_name = new_lad, town_time = new_town_time, town_30mins_pct = new_town_30mins_pct,
              town_60mins_pct = new_town_60mins_pct, town_30mins_cycle_pct = new_town_30mins_cycle_pct, 
              town_30mins_car_pct = new_town_30mins_car_pct) %>%
      filter(!(lad_name2 %in% old_lads))
  }
}

#remove lad_name and temporary lad_name2
travel_town <- select(travel_town,!c(lad_name,lad_name2))

#write to file
write.csv(travel_town, file = "data/wrangled/accessibility_wrangled.csv", row.names = FALSE)





  

