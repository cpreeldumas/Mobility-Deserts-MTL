library(tidyverse)

collisions <- read_csv("Accidents_2012_2017.csv")

daily_total_cars <- collisions %>% 
  filter(nb_automobile_camion_leger > 0) %>%
  summarise((n()/6)/365)

daily_total_taxis <- collisions %>% 
  filter(nb_taxi > 0) %>% 
  summarise((n()/6)/365)

daily_taxi_cars <- daily_total_cars + daily_total_taxis 

daily_total_bikes <- collisions %>% 
  filter(nb_bicyclette > 0) %>%
  summarise((n()/6)/365)

daily_total_bus <- collisions %>% 
  filter(nb_tous_autobus_minibus > 0) %>%
  summarise((n()/6)/365)

a <- c("Daily car accidents", "Daily Bike Accidents", "Daily Bus Accidents")
b <- c(57, 2, 1)
daily_accidents <- data.frame(a,b)

##########

yearly_total_cars <- collisions %>% 
  filter(nb_automobile_camion_leger > 0) %>%
  summarise(n()/6)

yearly_total_taxis <- collisions %>% 
  filter(nb_taxi > 0) %>% 
  summarise(n()/6)

yearly_taxi_cars <- yearly_total_cars + yearly_total_taxis 

yearly_total_bikes <- collisions %>% 
  filter(nb_bicyclette > 0) %>%
  summarise(n()/6)

yearly_total_bus <- collisions %>% 
  filter(nb_tous_autobus_minibus > 0) %>%
  summarise(n()/6)

c <- c("Yearly car accidents", "Yearly Bike Accidents", "Yearly Bus Accidents")
d <- c(24191, 971, 608)
yearly_accidents <- data.frame(c,d)




