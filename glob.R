
library(datasets)
library(flexdashboard)
library(crosstalk)
library(tidyverse)
library(dplyr)
library(tidymodels)
library(shiny)
library(dplyr)
library(lubridate)
library(readxl)
library(highcharter)
library(rlang)
library(broom)
library(DBI)
library(RMySQL)



indec_total = read_excel('indecnacional_total.xlsx')



txt = read.delim('values.txt', header = FALSE)

mysqlconnection = dbConnect(RMySQL::MySQL(),
                            dbname = 'inflacion',
                            host = txt$V1[1],
                            port = as.numeric(txt$V1[2]),
                            user = txt$V1[3],
                            password = txt$V1[4])


dbListTables(mysqlconnection)

query = 'USE inflacion;'

dbGetQuery(mysqlconnection, query)

query = 'select * from inflacion_argentina'

indec = as_tibble(dbGetQuery(mysqlconnection, query))

indec$periodos = as.Date(indec$periodos)

colnames(indec) = c("Nivel general" ,"Alimentos y bebidas" ,"Bebidas alcoholicas y tabaco", "Prendias y Calzado" ,         
                    "Vivienda Agua y Elec", "Equip y Mant del Hogar" , "Salud"  , "Transporte" ,
                    "Comunicacion" ,"Recreacion y cultura" , "Educacion" ,  "Restaurantes y hoteles" ,
                    "Bienes y servicios varios"  ,  "periodos"    , "year"  ,   "Mes" ,"month"  )