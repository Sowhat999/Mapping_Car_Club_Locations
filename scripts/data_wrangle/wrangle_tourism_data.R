library(tidyverse)
library(data.table)
library(sf)
library(sp) 
library(openxlsx)
library(lubridate)
library(PostcodesioR)
library(curl)
library(varhandle)


#UK tourism clusters 2011-13 (Unitary Authority level) 
#https://www.ons.gov.uk/peoplepopulationandcommunity/leisureandtourism/datasets/subnationaltourismaspatialclassificationofareasinenglandandwalestoshowtheimportanceoftourismatcountyandunitaryauthoritylevel2011to2013

tourism <- read.xlsx("data/contextual_open_data/tourism.xlsx", sheet = 5)
#organise col names and gather variables of interest
colnames(tourism) <- tourism[1,]
tourism <- tourism[2:nrow(tourism),] 
tourism <- tourism %>% 
  select(Code, Name, `Final cluster groupings`) 
colnames(tourism) <- c("ua","ua_name","tourism_cluster")  

#get tourism at lad level - (using lad.sf)

tourism_lad <- left_join(select(data.frame(lad.sf),lad,lad_name,Region,ua_name),tourism) %>%
  filter(!(Region %in% c("Scotland", "Northern Ireland")))

#add London score
tourism_lad$tourism_cluster[tourism_lad$Region == "London"] <- 
  tourism$tourism_cluster[tourism$ua_name == "Greater London"]

#add Bournemouth, Christchurch & Pool (Combined score of 5)
tourism_lad$tourism_cluster[tourism_lad$lad_name == "Bournemouth, Christchurch and Poole"] <- 5

#save tourism data
write.csv(tourism_lad, file = "data/contextual_open_data/tourism_wrangled.csv", row.names = FALSE)




