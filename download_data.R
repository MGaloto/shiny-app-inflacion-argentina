

library(datasets)
library(flexdashboard)
library(plotly)
library(crosstalk)
library(tidyverse)
library(ggplot2)
library(dplyr)
library(tidymodels)
library(shiny)
library(dplyr)
library(lubridate)
library(readxl)
library(highcharter)
library(rlang)
library(broom)
library(writexl)
library(readr)
library(DBI)
library(RMySQL)




if (as.numeric(substr(today(),9,10)) >= 15){
  file = paste0('https://www.indec.gob.ar/ftp/cuadros/economia/sh_ipc_',substr(today(),6,7),'_',substr(today(),3,4), '.xls')
  
  destfile = "indec_nacional.xls"
  
  download.file(file, destfile, mode = "wb")
  
  
  indec = read_excel('indec_nacional.xls')
  
  
  indec = indec[9:21,]
  
  n_col = ncol(indec) - 1
  
  
  periodos = seq(as.Date("2017/1/1"), by = "month", length.out = n_col)
  
  
  indec = data.frame(t(indec))
  
  colnames(indec) = c(indec[1,])
  
  row.names(indec) = 1:nrow(indec)
  
  indec = indec[-1,]
  
  indec[ , c(1:(ncol(indec)))] = apply(indec[ , c(1:(ncol(indec)))], 2, trimws )
  
  
  indec[ , c(1:(ncol(indec)))] = apply(indec[ , c(1:(ncol(indec)))], 2,
                                       function(x) as.numeric(as.character(x)))
  
  indec$periodos = periodos
  
  indec$year = year(indec$periodos)
  
  indec$Mes = as.numeric(substr(indec$periodos, 6 , 7))
  
  indec$periodos = as.Date(indec$periodos)
  
  
  
  colnames(indec) = gsub(',', '',colnames(indec))
  colnames(indec) = gsub('á', 'a',colnames(indec))
  colnames(indec) = gsub('é', 'e',colnames(indec))
  colnames(indec) = gsub('í', 'i',colnames(indec))
  colnames(indec) = gsub('ó', 'o',colnames(indec))
  colnames(indec) = gsub('ú', 'u',colnames(indec))
  
  
  colnames(indec)[2] = 'Alimentos y bebidas'
  colnames(indec)[5] = 'Vivienda Agua y Elec'
  colnames(indec)[4] = 'Prendias y Calzado'
  colnames(indec)[6] = 'Equip y Mant del Hogar'
  
  
  indec$month = month.abb[indec$Mes]
  
  
  write_xlsx(indec, 'indecnacional.xlsx' )
  
  
  
  ######################################################
  

  
  file_total = 'https://www.indec.gob.ar/ftp/cuadros/economia/sh_ipc_aperturas.xls'
  
  destfile_total = "indec_nacional_total.xls"
  
  download.file(file_total, destfile_total, mode = "wb")
  
  indec_total = read_excel('indec_nacional_total.xls')
  
  
  indec_total = indec_total[8:52,]
  
  n_col_total = ncol(indec_total) - 1
  
  
  periodos_total = seq(as.Date("2017/1/1"), by = "month", length.out = n_col_total)
  
  
  
  indec_total = data.frame(t(indec_total))
  
  colnames(indec_total) = c(indec_total[1,])
  
  row.names(indec_total) = 1:nrow(indec_total)
  
  indec_total = indec_total[-1,]
  
  indec_total[ , c(1:(ncol(indec_total)))] = apply(indec_total[ , c(1:(ncol(indec_total)))], 2, trimws )
  
  
  
  
  indec_total[ , c(1:(ncol(indec_total)))] = apply(indec_total[ , c(1:(ncol(indec_total)))], 2,
                                                   function(x) as.numeric(as.character(x)))
  
  
  indec_total$periodos = periodos_total
  
  
  indec_total$year = year(indec_total$periodos)
  
  indec_total$Mes = as.numeric(substr(indec_total$periodos, 6 , 7))
  
  indec_total$periodos = as.Date(indec_total$periodos)
  
  
  colnames(indec_total) = gsub(',', '',colnames(indec_total))
  
  colnames(indec_total) = gsub('á', 'a',colnames(indec_total))
  colnames(indec_total) = gsub('é', 'e',colnames(indec_total))
  colnames(indec_total) = gsub('í', 'i',colnames(indec_total))
  colnames(indec_total) = gsub('ó', 'o',colnames(indec_total))
  colnames(indec_total) = gsub('ú', 'u',colnames(indec_total))
  
  
  colnames(indec_total)[2] = 'Alimentos y bebidas'
  
  
  indec_total$month = month.abb[indec_total$Mes]
  write_xlsx(indec_total, 'indecnacional_total.xlsx' )
  

} else {

  cat('Faltan: ', 15 - as.numeric(substr(today(),9,10)), ' dias')
  
}




txt = read.delim('values.txt', header = FALSE)

mysqlconnection = dbConnect(RMySQL::MySQL(),
                            dbname = 'inflacion',
                            host = txt$V1[1],
                            port = as.numeric(txt$V1[2]),
                            user = txt$V1[3],
                            password = txt$V1[4])



dbListTables(mysqlconnection)



query = 'CREATE SCHEMA IF NOT EXISTS inflacion;'

dbGetQuery(mysqlconnection, query)

query = 'USE inflacion;'

dbGetQuery(mysqlconnection, query)


query = 'select * from inflacion_argentina'

indec_q = as_tibble(dbGetQuery(mysqlconnection, query))

indec_q$periodos = as.Date(indec$periodos)

colnames(indec_q) = c("Nivel general" ,"Alimentos y bebidas" ,"Bebidas alcoholicas y tabaco", "Prendias y Calzado" ,         
                    "Vivienda Agua y Elec", "Equip y Mant del Hogar" , "Salud"  , "Transporte" ,
                    "Comunicacion" ,"Recreacion y cultura" , "Educacion" ,  "Restaurantes y hoteles" ,
                    "Bienes y servicios varios"  ,  "periodos"    , "year"  ,   "Mes" ,"month"  )



if (indec_q$periodos[nrow(indec_q)] == indec$periodos[nrow(indec)]) {
  
  print('Mismo Mes')
  
} else {
  
  indec = indec[nrow(indec), ]
  
  query_values <- "insert into inflacion_argentina (nivel_general,
                                                  alimentos_bebidas,
                                                  bebidas_alchol_tabaco,
                                                  prendas_calzado,
                                                  vivienda_agua_ele,
                                                  equip_mant_hogar,
                                                  salud, transporte,
                                                  comunicacion,
                                                  recreacion_cultura,
                                                  educacion,
                                                  restaurante_hoteles,
                                                  bienes_servicios, 
                                                  periodos, 
                                                  year, 
                                                  mes, 
                                                  month) VALUES"
  
  
  
  
  query_insert <- paste0(query_values, paste(sprintf("('%s', '%s','%s', '%s','%s', '%s','%s', '%s','%s', '%s'
                                         ,'%s', '%s','%s', '%s','%s', '%s','%s')", indec$`Nivel general`, indec$`Alimentos y bebidas`, 
                                                     indec$`Bebidas alcoholicas y tabaco`, indec$`Prendias y Calzado`, 
                                                     indec$`Vivienda Agua y Elec`,
                                                     indec$`Equip y Mant del Hogar` , indec$Salud, indec$Transporte,
                                                     indec$Comunicacion, indec$`Recreacion y cultura`, indec$Educacion,
                                                     indec$`Restaurantes y hoteles`, indec$`Bienes y servicios varios`, 
                                                     indec$periodos, indec$year, indec$Mes, indec$month ), collapse = ","))
  
  
  dbGetQuery(mysqlconnection, query_insert)
  
  
}




# 
# query = '
#           CREATE TABLE IF NOT EXISTS inflacion_argentina (
#           nivel_general FLOAT,
#           alimentos_bebidas FLOAT,
#           bebidas_alchol_tabaco FLOAT,
#           prendas_calzado FLOAT,
#           vivienda_agua_ele FLOAT,
#           equip_mant_hogar FLOAT,
#           salud FLOAT,
#           transporte FLOAT,
#           comunicacion FLOAT,
#           recreacion_cultura FLOAT,
#           educacion FLOAT,
#           restaurante_hoteles FLOAT,
#           bienes_servicios FLOAT,
#           periodos DATE,
#           year INT,
#           mes  INT,
#           month VARCHAR(50)
#           );'
# 
# 
# dbGetQuery(mysqlconnection, query)





