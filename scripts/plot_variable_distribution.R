library(tidyverse)
library(sf)
library(sp)
library(tmap)
library(RColorBrewer)
library(readxl)
library(ggmap)
library(hexbin)
library(viridis)
library(gtools)
library(cowplot)
library(plotly)

### read data

#read variable data (already includes some comouk data)
transport_vars <- read.csv("data/open_transport_data.csv")

#get LAD shapefile
load("workspace_temp/LAD")

#get como data
comouk <- read.csv("data/comoukdata.csv")

#gather data at the LAD level
como_lad <- comouk %>%
  group_by(lad) %>%
  summarise(lad_name = lad_name[1], n_lots = n(), n_vehicles = sum(number_of_vehicles),
            n_operators = length(unique(operator)))

#extract england only
transport_vars_eng <- left_join(select(data.frame(lad_england.sf),lad),select(transport_vars,!n_other_lots))

#add como data
transport_vars_eng <- left_join(transport_vars_eng, select(como_lad, !lad_name))


#transport_vars_long2 <- pivot_longer(transport_vars, cols = c(surplus, town_time), names_to = "variable")

#extract only LADs with car clubs
car_clubs <- transport_vars_eng %>%
  filter(!is.na(n_lots))

#calculate quantiles for plotting
car_clubs$n_lots_q <- quantcut(car_clubs$n_lots)
car_clubs$n_vehicles_q <- quantcut(car_clubs$n_vehicles)

p1 <- ggplot(car_clubs, aes(x = n_lots, y = surplus, fill = n_lots)) +
  geom_point(shape = 21, alpha = 0.8, size = 5) +
  scale_fill_viridis(option = "D", name = "Number of bays") +
  labs(x = "Number of car club bays", y = "Council parking surplus (£, 000)") +
  ggtitle("The number of car club bays per Local Authority (2020) vs council parking revenue (2015-2016)") +
  scale_x_log10() + 
  scale_y_log10() +
  theme_classic() +
  theme(legend.position = c(0.85,0.3))


p2 <- ggplot(car_clubs, aes(x = n_lots, y = town_time, fill = n_lots)) +
  geom_point(shape = 21, alpha = 0.8, size = 5) +
  scale_fill_viridis(option = "D", name = "Number of bays") +
  labs(x = "Number of car club bays", y = "Time to nearest town on foot or by public transport (minutes)") +
  ggtitle("The number of car club bays per Local Authority (2020) vs the average time to the \n nearest town on foot or by public transport (2015-2016)") +
  scale_x_log10() + 
  scale_y_log10() +
  theme_classic() +
  theme(legend.position = c(0.85,0.7))


p1b <- ggplot(car_clubs, aes(x = n_vehicles, y = surplus, fill = n_vehicles)) +
  geom_point(shape = 21, alpha = 0.8, size = 5) +
  scale_fill_viridis(option = "D", name = "Number of vehicles") +
  labs(x = "Number of car club vehicles available", y = "Council parking surplus (£, 000)") +
  ggtitle("The number of car club vehicles per Local Authority (2020) vs council parking revenue (2015-2016)") +
  scale_x_log10() + 
  scale_y_log10() +
  theme_classic() +
  theme(legend.position = c(0.85,0.3))

p2b <- ggplot(car_clubs, aes(x = n_vehicles, y = town_time, fill = n_vehicles)) +
  geom_point(shape = 21, alpha = 0.8, size = 5) +
  scale_fill_viridis(option = "D", name = "Number of vehicles") +
  labs(x = "Number of car club vehicles available", y = "Time to nearest town on foot or by public transport (minutes)") +
  ggtitle("The number of car club vehicles per Local Authority (2020) vs the average time to the \n nearest town on foot or by public transport (2015-2016)") +
  scale_x_log10() + 
  scale_y_log10() +
  theme_classic() +
  theme(legend.position = c(0.85,0.7))

p <- plot_grid(p1, p2, p1b, p2b, nrow = 2, align = "hv")

#read in tourism data
tourism <- read.csv("data/contextual_open_data/tourism_wrangled.csv")

#add to car_clubs
car_clubs <- left_join(car_clubs, select(tourism, lad_name, tourism_cluster), by = "lad_name")

#plot number of lots per tourism cluster
car_clubs$tourism_cluster <- factor(car_clubs$tourism_cluster)

ggplot(car_clubs, aes(x = tourism_cluster, y = n_lots, fill = tourism_cluster)) +
  geom_boxplot() +
  scale_fill_viridis(discrete = TRUE) +
  guides(fill = FALSE) #+
  
ggplot(filter(car_clubs,!tourism_cluster == 4), aes(x = tourism_cluster, y = n_lots, fill = tourism_cluster)) +
  geom_boxplot() +
  scale_fill_viridis(discrete = TRUE) +
  guides(fill = FALSE)

ggplot(car_clubs, aes(x = tourism_cluster, y = n_lots, fill = tourism_cluster)) +
  geom_bar(stat = "identity") +
  scale_fill_viridis(discrete = TRUE) +
  guides(fill = FALSE) +
  labs(x = "Tourism cluster", y = "Number of car club bays") +
  ggtitle("The number of car club bays per tourism cluster")


#number of local authorities with car clubs
car_clubs <- car_clubs %>%
  group_by(lad_name) %>%
  mutate(lad_count = n())

p1 <- ggplot(car_clubs, aes(x = tourism_cluster, y = lad_count, fill = tourism_cluster)) +
  geom_bar(stat = "identity") +
  scale_fill_viridis(discrete = TRUE) +
  guides(fill = FALSE) +
  labs(x = "Tourism cluster", y = "Number of local authorities with car club bays") +
  ggtitle("Distribution of local authorities with car club bays per tourism cluster")

p2 <- ggplot(car_clubs, aes(x = tourism_cluster, y = n_lots, fill = tourism_cluster)) +
  geom_bar(stat = "identity") +
  scale_fill_viridis(discrete = TRUE) +
  guides(fill = FALSE) +
  labs(x = "Tourism cluster", y = "Number of car club bays") +
  ggtitle("Distribution of car club bays per tourism cluster")


p <- plot_grid(p1,p2, align = "hv")

#plot of the number of lots vs the number of vehicles per lad (high +ve correlation as expected)

pl <- ggplot(car_clubs, aes(x = n_lots, y = n_vehicles, text = lad_name)) +
  geom_point(shape = 21, alpha = 0.8, size = 5)

ggplotly(pl)






