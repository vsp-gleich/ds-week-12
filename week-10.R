library(sf)
library(tidyverse)
library(tmap)
#library(tmaptools)
#library(OpenStreetMap)

# 2019 accident data
raw_unfaelle <- read_csv2("unfaelle.csv", locale=locale(encoding="latin1"))

# Create sf object from X/Y coord columns. Lon/Lat is EPSG:4326
unfaelle <- st_as_sf(raw_unfaelle, coords=c("XGCSWGS84","YGCSWGS84"), crs=4326)

# Berlin neighborhoods
bezirke <- st_read("shp-bezirke/bezirke_berlin.shp")

# Base map
# basemap <- read_osm(bezirke, ext=1.1)

# 1. Plot the dots themselves
tmap_mode("view") # tmap_mode("plot")
#tm_basemap("OpenStreetMap.DE") +

unfaelle <- mutate(unfaelle, bike_related=IstRad==1)

tm_shape(bezirke) +
  tm_polygons() +
  tm_shape(unfaelle) +
  tm_dots(size=0.01, col="bike_related", title="2019 Accidents: Bike-related?")


# 2. Plot neighborhood totals
unfaelle <- st_transform(unfaelle, crs=25833)
bezirke <- st_transform(bezirke, crs=25833)

joined_data <- st_join(bezirke, unfaelle["IstRad"])

accident_summary <- joined_data %>%
  group_by(SCHLUESSEL) %>%
  summarize(num_accidents=n())

tm_shape(bezirke) +
  tm_polygons() +
  tm_shape(accident_summary) +
  tm_dots(size="num_accidents", col="num_accidents", title="Collisions by Neighborhood, 2019")

tmap_save(tmap_last(), "ziggy.html")
