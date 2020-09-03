# Mapping car club locations in the UK

Plots and analysis related to car club locations in the UK.
This work is part of a data science project with Leeds Institute for Data Analytics and the Department of Transport, University of Leeds, exploring car clubs as a sustainable alternative to privately owned vehicles.  

1) Obtaining the car club locations 
[webscraping_car_club_locations.R](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/scripts/webscraping_car_club_locations.R) uses a web-scraping technique to extract the locations (with lat long coordinates)
of all car club *lots* (i.e. parking bay/pick-up location) in the UK. These locations were extracted from an existing interactive map of car club locations on the CoMoUK website (https://como.org.uk/shared-mobility/shared-cars/where/). 
CoMoUK, short for Collaborative Mobility UK, are researching and developing shared transport and integrated mobility options in the UK. As well as the lot locations, the scraped car club data also includes the operator of the car club in question.
There are five operators in total - Co-Wheels, Enterprise Car Club, Ubeeqo, Zipcar and Zipcar Flex.
The processed data is stored in [car_club_locations.csv](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/data/wrangled/car_club_locations.csv).

2) Plotting the car club locations
[car_club_locations.R](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/scripts/car_club_locations.R) produces maps showing the distribution of car clubs in the UK.
First, the interactive map on the CoMoUK website is recreated, showing the car club locations and the corresponding operator. This is in html format, and can be downloaded from 
[car_club_locations.html](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/maps/car_club_locations.html). This file is too big to view in github - a static snapshot is provided below: 

![car_clubs_html_preview.PNG](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/maps/car_clubs_html_preview.PNG)  

3) Analysing car club distribution at the Upper Tier Local Authority level
[car_clubs_lad_level.R](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/scripts/car_clubs_lad_level.R) gets local authority level variables,
 including the number of car club operators in use per local authority:

![operators_per_lad.pdf](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/maps/operators_per_lad.png)  

This map shows that car clubs are distributed across all regions of the UK.
Outside of London, there is typically only one or two operators in use (mostly Enterprise and/or Co-wheels). 
London has the highest concentration of car clubs in the UK, with upto five different operators servicing a single local authority (Wandsworth).
There is a considerable section of the UK with no car club coverage, extending from South Wales and up to the East coast.

The number of *lots* per local authority is also analysed, giving an idea of which areas are car club "hot spots".

![lots_per_lad.pdf](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/maps/lots_per_lad.png)  

Unsurprisingly, the local authorities with the highest number of car club lots are in London. Lewisham has the most, with 374 lots. 
There are however areas outside of London with a high number of lots, suggesting that car clubs are also popular in these areas.
Edinburgh, with 151 car club lots, contains the most lots outside of London. All 151 lots belong to Enterprise Car Club. Bristol and Brighton and Hove also 
appear to be popular for car club use, with 125 and 113 lots respectively. The following table displays the five local authorities outside of London with 
the most car club lots.

| Local Authority       | Number of car club lots | Operators  |
|:---------------------:|:-----------------------:|:----------:|
| Edinburgh     | 151 | Enterprise Car Club|
| Bristol      | 125 | Co-Wheels, Enterprise Car Club, Zipcar|
| Brighton and Hove     | 113 | Enterprise Car Club|
| Glasgow 	   | 70  | Co-Wheels, Enterprise Car Club |
| Cambridge    | 59  | Enterprise Car Club, Zipcar |

The local authority level data is stored in [car_clubs_lad.csv](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/data/wrangled/car_clubs_lad.csv).

