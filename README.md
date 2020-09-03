# Mapping car club locations in the UK

Plots and analysis related to car club locations in the UK.
This work is part of a data science project with Leeds Institute for Data Analytics and the Department of Transport, University of Leeds, exploring car clubs as a sustainable alternative to privately owned vehicles.  

1) **Obtaining the car club locations** 
[webscraping_car_club_locations.R](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/scripts/webscraping_car_club_locations.R) uses a web-scraping technique to extract the locations (with lat long coordinates)
of all car club *lots* (i.e. parking bay/pick-up location) in the UK. These locations were extracted from an existing interactive map of car club locations on the CoMoUK website (https://como.org.uk/shared-mobility/shared-cars/where/). 
CoMoUK, short for Collaborative Mobility UK, are researching and developing shared transport and integrated mobility options in the UK. As well as the lot locations, the scraped car club data also includes the operator of the car club in question, and the
number of vehicles stationed at each lot.
There are five operators in total - Co-Wheels, Enterprise Car Club, Ubeeqo, Zipcar and Zipcar Flex.
The processed data is stored in [car_club_locations.csv](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/data/wrangled/car_club_locations.csv).

2) **Plotting the car club locations**
[car_club_locations.R](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/scripts/car_club_locations.R) produces maps showing the distribution of car clubs in the UK.
First, the interactive map on the CoMoUK website is recreated, showing the car club locations and the corresponding operator. This is in html format, and can be downloaded from 
[car_club_locations.html](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/maps/car_club_locations.html). This file is too big to view in github - a static snapshot is provided below: 

<p align="center">
 <img src="https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/maps/car_clubs_html_preview.PNG"  
</p>

3) **Analysing car club distribution at the Upper Tier Local Authority level**<br>
[car_clubs_lad_level.R](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/scripts/car_clubs_lad_level.R) gets local authority level variables,
 including the number of car club operators in use per local authority:<br>
![operators_per_lad.png](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/maps/operators_per_lad.png) <br> 
This map shows that car clubs are distributed across all regions of the UK.
Outside of London, there is typically only one or two operators in use (mostly Enterprise and/or Co-wheels). 
London has the highest concentration of car clubs in the UK, with upto five different operators servicing a single local authority (Wandsworth).
There is a considerable section of the UK with no car club coverage, extending from South Wales and up to the East coast. <br>
The number of available car club vehicles per local authority is also analysed, giving an idea of which areas are car club "hot spots". <br>
![vehicles_per_lad.png](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/maps/vehicles_per_lad.png) <br> 
Unsurprisingly, the local authorities with the highest number of available vehicles are in London. Wandsworth has the most, with 386 vehicles. 
There are however areas outside of London with a high number of vehicles, suggesting that car clubs are also popular in these areas.
Edinburgh, with 211 car club vehicles, contains the most of London. All vehicles are belong to Enterprise Car Club. Bristol and Brighton and Hove also 
appear to be popular for car club use, with 130 and 128 vehicles respectively. The table below displays the five local authorities outside of London with 
the most car club vehicles. The local authority level data is stored in [car_clubs_lad.csv](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/data/wrangled/car_clubs_lad.csv). 


| Local Authority       | Number of car club vehicles | Operators  |
|:---------------------:|:-----------------------:|:----------:|
| Edinburgh     | 211 | Enterprise Car Club|
| Bristol      | 130 | Co-Wheels, Enterprise Car Club, Zipcar|
| Brighton and Hove     | 128 | Enterprise Car Club|
| Glasgow 	   | 87  | Co-Wheels, Enterprise Car Club |
| Cambridge    | 63  | Enterprise Car Club, Zipcar | 


4) **Car clubs and council parking revenue**<br>
[car_clubs_and_parking_surplus.R](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/scripts/car_clubs_and_parking_surplus.R) compares car club distribution with council parking surplus for
English local authorities. The parking data is provided by the RAC Foundation - a transport policy and research organisation - for the year 2015-2016, when English council parking profits exceeded three quarters of a billion pounds (an 11 % increase from the previous year)
The data is available online in pdf format (http://www.racfoundation.org/media-centre/parking-profits-break-three-quarters-of-a-billion). This has been converted to an excel file using *pdf.wondershare* software, and is stored in [parking_revenue_wrangled.csv](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/data/wrangled/parking_revenue_wrangled.csv).  
A high parking revenue for a local authority suggests that a significant number of journeys are made to the area by car. <br>
![parking_surplus_with_car_clubs.png](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/maps/parking_surplus_with_car_clubs.png) <br> 
Plotting the data as a scatter plot shows that local authorities with more car club vehicles in use generally have a higher parking surplus: 
![parking_surplus_cc_vehicles.png](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/maps/parking_surplus_cc_vehicles.png) <br> 
This indicates that car clubs are most established in areas that are popular travel destinations in general.

5) **Car clubs and accessibility**<br>
[car_clubs_and_accessibility.R](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/scripts/car_clubs_and_accessibility.R) explores the number of car club vehicles per local authority with respect to
the accessibility of the nearest town. The accessibility data is provided by the Department for Transport (https://www.gov.uk/government/statistical-data-sets/journey-time-statistics-data-tables-jts), and contains the
average time taken per local authority to travel to the nearest town using public transport or by walking. <br>
![travel_time_with_car_clubs.png](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/maps/travel_time_with_car_clubs.png) <br> 
Plotting the travel time against the number of car club vehicles shows that there are generally fewer vehicles available in areas that are less accessibile:
![travel_time_cc_vehicles.png](https://github.com/CaitlinChalk/Mapping_Car_Club_Locations/blob/master/maps/travel_time_cc_vehicles.png) <br> 


