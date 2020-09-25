#A script to extract car club locations from como.org.uk

library(tidyverse)
library(osmdata)
library(rvest)    
library(stringr)   
library(rebus)     
library(httr) # Parsing of HTML/XML files 
library(rjson)
library(jsonlite)
library(PostcodesioR) #for geocoding (Getting lsoa etc for given lat lon coords)

#used some steps found in the following guide to httr (which is designed to map underlying http protocol):
#https://cran.r-project.org/web/packages/httr/vignettes/quickstart.html

#generate request to obtain car club locations from como website
#the correct URL was obtained using the following guide:
#https://onlinejournalismblog.com/2017/05/10/how-to-find-data-behind-chart-map-using-inspector/

r <- GET("https://como.org.uk/wp-json/comouk/v1/share-locations?type=location")

#check structure of request
#str(content(r))

#check request status
http_status(r)
#r$status_code #(200 = successful, 404 = file not found, 403 = permission denied)

#get content of request (json file) as character vector
r_body <- content(r, "text")

#convert character json to dataframe
como0 <- fromJSON(r_body)

#extract variables of interest to como dataframe
como <- como0 %>%
  select(location, lng, lat, number_of_vehicles)

#get operator name, and add to dataframe
operator <- como0$scheme$name
como$operator <- operator

#extract logos for plotting later
logos <- como0$scheme$logo
como_logo <- como
como_logo$logo <- logos
como_logo <- como_logo %>%
  group_by(operator) %>%
  summarise(logo = logo[1])

#complete list of operators
operator_list <- unique(como$operator)

#find how many entries exist for each operator:
operator_count <- como %>%
  group_by(operator) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

#filter the five top operators: Enterprise, Zipcar (+ Zipcar flex), Ubeeqo, Co-wheels
operator_keep <- head(operator_count,5)$operator

como <- como %>% 
  filter(operator %in% operator_keep) %>%
  rename(lon = lng)

como_logo <- como_logo %>%
  filter(operator %in% operator_keep)

#save logos to file
write.csv(como_logo, file = "logos/car_club_logos.csv", row.names = FALSE)

#get lsoa and lad of each lot
#(takes a few minutes to run)
#---------------------------------------------------------------

como$lad <- NA
como$lad_name <- NA
como$lsoa_name <- NA
#Ian Edit:  added postcode so that we can later use a lookup 
#to add a link to the LSOA code.  
#the lsoa name is not a reliable way to do joins

como$postcode <- NA
for (i in seq(nrow(como))){
  geo_code <- reverse_geocoding(como[i,'lon'],como[i,'lat'])
  l = length(geo_code)
  # search with wideSearch on if no results are produced
  if (l == 0){
    geo_code <- reverse_geocoding(como[i,'lon'],como[i,'lat'], wideSearch = TRUE)
    l = length(geo_code)  
  }
  if (l > 0){
    como$lad[i] <- geo_code[[l]]$codes$admin_district
    como$lad_name[i] <- geo_code[[l]]$admin_district
    como$lsoa_name[i] <- geo_code[[l]]$lsoa
    #Ian edit: 
    como$postcode[i] <- geo_code[[l]]$postcode
  }
}

#convert lat lon to numeric
como$lon <- as.numeric(como$lon)
como$lat <- as.numeric(como$lat)

#convert operator to a factor
como$operator <- factor(como$operator)

#remove duplicates
como <- distinct(como)

#save data to file
write.csv(como, file = "data/wrangled/car_club_locations_with_postcode.csv", row.names = FALSE)

#Ian edit: 
lookup <- read_csv("data/wrangled/lookup_postcode_lsoa.csv")
names(lookup)

#join carclubs to the lookup so that 
#car club locations have an lsoa code as a reference.  

como_lsoacd <- left_join(como,lookup,by = c("postcode" = "pcds"))
write.csv(como_lsoacd, file = "data/wrangled/car_club_locations_with_postcode_lsoacd.csv", row.names = FALSE)


