library(tidyverse)
library(data.table)
library(sf)
library(sp) 
library(openxlsx)
library(lubridate)
library(PostcodesioR)
library(curl)
library(varhandle)

#Council parking revenue per LAD data 2015-2016 (the pdf was downloaded and converted into an excel file using a free trial of the "pdf.wondershare" software)
#http://www.racfoundation.org/media-centre/parking-profits-break-three-quarters-of-a-billion

car_park_revenue <- read_excel("data/raw/contextual_open_data/Local_Authority_Parking_Operations_Revenue_Outturn_for_England_2015_16.xlsx",
                               range = "A3:G356")

#select LAD and 2015-16 surplus data (the most recent year with data)
car_park_revenue <- select(car_park_revenue, `Local authority`, `2015-16`) %>%
  rename(lad_name = `Local authority`, surplus = `2015-16`)

#convert surplus column from character to numeric
car_park_revenue$surplus <- as.numeric(car_park_revenue$surplus)

#The next bit of code is to edit the lad_names in car_park_revenue so that they coincide with
#those in lad.sf. This was done by visually inspecting the two dataframes for differences

#some lad_name values have " UA" after the name. Replace these:
car_park_revenue$lad_name <- gsub("\\sUA$", "", car_park_revenue$lad_name)

#re-add Reading value (which was in a different format)
car_park_revenue$surplus[car_park_revenue$lad_name == "Reading"] <- 2957

#replace the & with "and"
car_park_revenue$lad_name <- gsub("&", "and", car_park_revenue$lad_name)

### replace incorrect lad names and codes

#read data containing outdated lads with replacements 
lad_replace <- read.csv("data/wrangled/lad_replace.csv")

#convert old name list (separated by " & " into list)
lad_replace$old_names <- lapply(lad_replace$old_names, strsplit, " & ")
#unlist to convert to vector
lad_replace$old_names <- lapply(lad_replace$old_names, unlist)
#add comma to Bournemouth, Christchurch and Poole
lad_replace$new_names[lad_replace$new_names == "Bournemouth Christchurch and Poole"] <- "Bournemouth, Christchurch and Poole"

#combine outdated LAD names according to lad_replace
for (i in seq(1,nrow(lad_replace))){
  #list of old lad names for replacement
  old_lads <- car_park_revenue$lad_name[car_park_revenue$lad_name %in% lad_replace$old_names[[i]]]
  #new, combined lad name
  new_lad <- lad_replace$new_names[[i]] 
  #calculate new surplus value as sum of surplus for old lad names
  new_surplus <- sum(car_park_revenue$surplus[car_park_revenue$lad_name %in% lad_replace$old_names[[i]]])
  #add new data to car_park_revenue, and remove old data
  car_park_revenue <- car_park_revenue %>%
    add_row(lad_name = new_lad, surplus = new_surplus) %>%
    filter(!(lad_name %in% old_lads))
}

#correct the lads that are written differently to those in lad.sf
names_old <- c("Bath and North East Somerset\r", "Bristol", "Derby City", "Herefordshire", "Kingston upon Hull", "Leicester City", "Medway Towns", "Middlesborough", "St Helens","Telford and the Wrekin", "Durham")
names_new <- c("Bath and North East Somerset", "Bristol, City of", "Derby", "Herefordshire, County of", "Kingston upon Hull, City of", "Leicester", "Medway", "Middlesbrough", "St. Helens","Telford and Wrekin", "County Durham")

#replace names_old with names_new
for (i in seq(1,length(names_old))){
  car_park_revenue$lad_name <- gsub(names_old[i], names_new[i], car_park_revenue$lad_name)
}

#save variables to workspace
write.csv(car_park_revenue, file = "data/wrangled/parking_revenue_wrangled.csv", row.names = FALSE)
