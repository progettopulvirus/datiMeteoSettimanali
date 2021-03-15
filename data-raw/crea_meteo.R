rm(list=objects())
library("tidyverse")
library("lubridate")
## code to prepare `meteo` dataset goes here
readr::read_delim("datiMeteo_nuovoVento.csv",delim=";",col_names = TRUE)->meteo



#aggrega dati a livello settimanale

#precipitazione
meteo %>% 
  mutate(week=isoweek(date),year=year(date)) %>% 
  dplyr::select(year,week,station_code,station_eu_code,date,tp,ptp)->temp

temp %>% 
  dplyr::select(-date) %>%
  group_by(station_code,station_eu_code,year,week) %>%
  summarise(across(c(tp,ptp),sum,na.rm=TRUE)) %>%
  ungroup()->aggregati1

rm(temp)

meteo %>%
  mutate(week=isoweek(date),year=year(date)) %>% 
  dplyr::select(year,week,station_code,station_eu_code,date,matches("^t.*2m$"),matches("^pb.+"),dtr,nirradiance,sp,rh,matches("^.?w.+"),u10m,v10m,altitude,altitudedem)->temp

temp %>% 
  dplyr::select(-date) %>%
  group_by(station_code,station_eu_code,year,week) %>%
  summarise(across(.cols=everything(),mean,na.rm=TRUE)) %>%
  ungroup()->aggregati2
rm(temp)

stopifnot(nrow(aggregati1)==nrow(aggregati2))

left_join(aggregati1,aggregati2)->meteo_settimanali
stopifnot(nrow(aggregati1)==nrow(meteo_settimanali))
rm(aggregati1)
rm(aggregati2)


usethis::use_data(meteo_settimanali, overwrite = TRUE)


meteo_settimanali %>%
  mutate(across(c(starts_with("t"),starts_with("p"),wspeed,wdir,sp,rh,dtr,nirradiance,altitude,altitudedem,v10m,u10m),scale))->meteo_settimanali_standardizzati


usethis::use_data(meteo_settimanali_standardizzati, overwrite = TRUE)
