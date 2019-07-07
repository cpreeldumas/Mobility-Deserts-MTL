#Authors: Beatrice, Camille, Saeesh
#Date: Fri Jun 28 10:24:04 2019
#Title: Mapping Transit deserts in Montreal

#Libraries
library(tidyverse)
library(sf)
library(osmdata)
library(tmap)
library(gbfs)
library(mapedit)
library(raster)

#Part 1: Getting data. List of Required data:
# - Montreal administrative boundaries
# - Montreal buildings 
# - Montreal transit network (bus and subway)
# - Montreal Bike Lanes 
# - Montreal Bixi Stations
# - Montreal Hospitals

#1. Montreal's administrative boundaries:
url <- "http://donnees.ville.montreal.qc.ca/dataset/00bd85eb-23aa-4669-8f1b-ba9a000e3dd8/resource/e9b0f927-8f75-458c-8fda-b5da65cc8b73/download/limadmin.json"

#Use url to download the file from online
download.file(url, destfile = "mtllimits.geojson")

#Read the file into r using sf.
mtl <- read_sf("mtllimits.geojson")

#Examine
#glimpse(mtl)
#plot(mtl["TYPE"])

#Getting the outline and its bounding box so as to use it to clip the rest of the data:
mtl_outline <- mtl %>% st_union()
mtl_bbox <- st_bbox(mtl_outline)

#2.1 Montreal's Buildings from Open data montreal:
#url <- "http://donnees.ville.montreal.qc.ca/dataset/fab160ae-c81d-46f8-8f92-4a01c10d4390/resource/fc1a0cc8-9460-4555-903f-800372c4db24/download/empreinte_batiment_wgs84.geojson"

#Use url to download the file from online
#download.file(url, destfile = "mtlbuildings.geojson")

#Read the file into r using sf.
#build_mtl <- read_sf("mtlbuildings.geojson")

#Examine
#build_mtl
#plot(build_mtl["producteur"])

#2 Montreal's buildings from open street map (Montreal city data seems weird)
#build_osm_import <- opq(bbox = "Montreal") %>% 
#  add_osm_feature(key = "building", value = "residential") %>% 
##  osmdata_sf()

#Selecting only the polygon data from this dataset, clipping it with Montreal bbox and plotting 
#to explore:
#build_osm <- build_osm_import$osm_polygons %>% 
#  st_intersection(mtl_outline) %>% 
#  dplyr::select(osm_id,geometry)
#glimpse(build_osm)
#plot(build_osm["osm_id"])

#3.Montreal's transit network (bus and subway)
url <- "http://www.stm.info/sites/default/files/gtfs/stm_sig.zip"

#Use url to download the file from online
download.file(url, destfile = "mtltransit.zip")

#unzipping the file:
unzip("mtltransit.zip")

#Read the file into r using sf.
transit_mtl <- read_sf("stm_lignes_sig.shp") %>% 
  dplyr::select(route_id,geometry)

#Examine
#glimpse(transit_mtl)
#plot(transit_mtl["headsign"])

#4. Montreal Bike Lanes 
url <- "http://donnees.ville.montreal.qc.ca/dataset/5ea29f40-1b5b-4f34-85b3-7c67088ff536/resource/0dc6612a-be66-406b-b2d9-59c9e1c65ebf/download/reseau_cyclable_2018_c.geojson"

#Use url to download the file from online
download.file(url, destfile = "mtlbikelanes.geojson")

#Read the file into r using sf.
bikelanes_mtl <- read_sf("mtlbikelanes.geojson") %>% 
  dplyr::select(ID,geometry)

#Examine
#glimpse(bikelanes_mtl)
#plot(bikelanes_mtl["NOM_ARR_VI"])

#5. Montreal bixi stations (using the gbfs package):
#Saving station information in a file
get_station_information("Montreal", directory = getwd(), file = "bixi.rds")

#Reading in the file
bixi <- readRDS("bixi.rds")

#Converting to sf:
bixi <- bixi %>% 
  st_as_sf(coords = c("lon","lat"), crs = 4326) %>% 
  dplyr::select(station_id,geometry)

#Exploring:
#glimpse(bixi)
#plot(bixi["name"]) #plot for bixis

#6. Montreal Hospitals:
hospital_osm <- opq(bbox = "Montreal") %>% 
  add_osm_feature(key = "amenity", value = "hospital") %>% 
  osmdata_sf()

#Selecting only the polygon data from this dataset, clipping it with Montreal bbox and plotting 
#to explore:
hospital_osm <- hospital_osm$osm_polygons %>% 
  st_intersection(mtl_outline) %>% 
  dplyr::select(osm_id,name,geometry)
#glimpse(hospital_osm)
#plot(hospital_osm["osm_id"])

#Part 2: Finding mobility deserts
#First creating buffers around the hospitals, transit lines, bixi stations, bike lanes:

#Hospital:
hospital_buffer <- st_buffer(st_transform(hospital_osm,crs = 2959), dist = 500)

#Transit lines:
transit_buffer <- st_buffer(st_transform(transit_mtl,crs = 2959), dist = 100)
transit_union <- transit_buffer %>% st_union()

#Bixi Buffer 
bixi_buffer <- st_buffer(st_transform(bixi, crs = 2959), 100)

#Bike Lane Buffer
bikelanes_buffer <- st_buffer(st_transform(bikelanes_mtl, crs = 2959), 100)
bikelanes_union <- bikelanes_buffer %>% st_union()

desert_transit <- mtl %>% 
  st_transform(crs = 2959) %>% 
  st_difference(transit_union) %>% 
  st_transform(crs = 4326)

desert_bike_transit <- desert_transit %>% 
  st_transform(crs = 2959) %>% 
  st_difference(bikelanes_union) %>% 
  st_transform(crs = 4326)

plot(desert_bike_transit["NOM"])
st_area(desert_bike_transit)

#dsrt_bike_trans_hosp <- desert_bike_transit %>% 
# st_transform(crs = 2959) %>% 
#st_difference(hospital_buffer) %>% 
#st_transform(crs = 4326)

#dsrt_all <- dsrt_bike_trans_hosp %>% 
# st_transform(crs = 2959) %>% 
#  st_difference(bixi_buffer) %>% 
# st_transform(crs = 4326)

#plot(desert_bike_transit["NOM"])
#plot(dsrt_bike_trans_hosp["NOM"])

#The leaflet map:
map <- tm_shape(desert_bike_transit) +
  tm_fill(col = "NOM",legend.show = FALSE)
map

tmap_options(max.categories = 34)
#HERE IT IS!
leaflet_map <- tmap_leaflet(map)



map2 <- tm_shape(mtl) +
  tm_fill(col = "index",legend.show = FALSE, tm_borders(col = "white") )
map2

tmap_options(max.categories = 34)
#HERE IT IS!
leaflet_map2 <- tmap_leaflet(map2)


mtl
#Calculating areas:
mtl <- mtl %>% 
  mutate(area = st_area(desert_bike_transit))

#Cacluating the index
mtl <- mtl %>% 
  filter(NOM != "L'Île-Dorval") %>%
  mutate(index = round(area/AIRE, digits = 2))

#HERE IS THE INDEX!
mtl$index
