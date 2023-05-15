

library(httr)
library(readxl)
library(lubridate)
library(writexl)




url = paste0('https://www.indec.gob.ar/ftp/cuadros/economia/sh_ipc_',substr(today(),6,7),'_',substr(today(),3,4), '.xls')


get_dataframe = function(url, time_out){
  
  if (as.numeric(substr(today(),9,10)) >= 10){
  
    
    tryCatch({
      
      GET(url, 
          timeout(time_out),
          write_disk(file <- tempfile(fileext = ".xls")))
     
      indec = read_excel(file)
      
      
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
      
      
      if ( is.na(indec[nrow(indec), 1]) == TRUE){
        indec <- indec[-c(nrow(indec)), ]
      }
      
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
  
      
    }, error = function(e) {
      
      indec = read_xlsx('indecnacional.xlsx')
      return(indec)
      
    })
  } 
  
  else {
    indec = read_xlsx('indecnacional.xlsx')
    return(indec)
    
  }
  
  
}

indec = get_dataframe(url,10000)
