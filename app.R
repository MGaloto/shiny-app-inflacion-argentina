
library(bs4Dash)
library(tidyverse)
library(dplyr)
library(shinycssloaders)
library(waiter)
library(readxl)
library(highcharter)
library(shiny)


traducir_mes <- function(mes_ingles) {
  meses <- c("january", "february", "march", "april", "may", "june", "july", "august", "september", "october", "november", "december")
  meses_espanol <- c("enero", "febrero", "marzo", "abril", "mayo", "junio", "julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre")
  
  mes_ingles <- tolower(mes_ingles)
  
  if (mes_ingles %in% meses) {
    indice <- match(mes_ingles, meses)
    mes_traducido <- meses_espanol[indice]
    return(mes_traducido)
  } else {
    return(mes_ingles)
  }
}


indec = read_excel("data/indecnacional.xlsx")

indec_colnames = sort(c("Nivel general",
                        "Alimentos y bebidas", 
                        "Bebidas alcoholicas y tabaco", 
                        "Prendias y Calzado",
                        "Vivienda Agua y Elec", 
                        "Equip y Mant del Hogar",
                        "Salud", 
                        "Transporte",
                        "Comunicacion", 
                        "Recreacion y cultura",
                        "Educacion",
                        "Restaurantes y hoteles",
                        "Bienes y servicios varios"))





interanual <- function(df, val){
  values = c()
  for (i in 0:11) {
    value_lag = lag((pull((df[,c(val)]) / 100) + 1), i)[nrow(df)]
    values[i + 1] <- value_lag}
  product = (prod(values) - 1) * 100
  return(round(product,1))
}


interanual_df = function(df, cols){
  names = c()
  values = c()
  for (i in 1:length(cols)){
    interanual_rate = interanual(df, cols[i])
    values[i  + 1] <- interanual_rate
    names[i + 1] <- cols[i]
  }
  return(na.omit(tibble(sector = names, tasa = values)))
}




data_bar = function(df, colnames){
  fecha_fin = max(df$periodos)
  
  value = c()
  name = c()
  count = 0
  for (c in colnames){
    count = count + 1
    val = df[[c]][df[["periodos"]] == fecha_fin]
    name[count] = c
    value[count] = val
  }
  return(tibble(sector = name, tasa = value))
}



# Crear la UI del dashboard

# UI ----------------------------------------------------------------------



ui <- dashboardPage(
  options = F,
  preloader = list(
    html = tagList(spin_6(), "Loading..."), color = "#3c8dbc"),
  header = dashboardHeader(
    skin = "dark",
    fixed = T,
    title = dashboardBrand(
      title ="Precios Argentina",
      image = "https://upload.wikimedia.org/wikipedia/commons/6/64/Logo_Indec.png")
  ),
  # dashboardSidebar ----------------------------------------------------------------------
  sidebar = dashboardSidebar(
    background = "lightgray",
    background_dark = "darkgray",
    skin = "light",
    width = 500,
    sidebarMenu(
      menuItem(
        text = "Principal",
        tabName = "dashboard",
        startExpanded = T,
        icon = icon("home")
      ),
      selectInput(
        inputId = "input1",
        label = "Sectores",
        choices = indec_colnames, 
        selected = "Nivel general"),
      menuItem(
        text = "Bar Plot",
        tabName = "bp",
      icon = icon("chart-bar")),
    menuItem(
      text = "Acerca de",
      tabName = "about",
      icon = icon("info-circle"))
  )
),
body = dashboardBody(
  tags$style(
    type = 'text/css', 
    '.rt-align-left {color: black!important; }',
    '.rt-align-center {color: black!important; }',
    '.ReactTable {color: black!important; }',
    '.sidebar .shiny-input-container {padding: 0px 21px 0px 16px!important; }',
    '.btn-primary {color: #fff!important; background-color: #5d6b7a!important; border-color: #007bff!important; box-shadow: none!important;}',
    '.small-box .inner {padding: 12px!important; text-align: center!important; font-size: 37px!important;}'
  ),
  tabItems(
    tabItem(
      # Sección Principal ----------------------------------------------------------------------
      
      tabName = "dashboard",
      h3("Precios Economia Argentina"),
      p("Dashboard sobre la variacion de los precios en ", 
        span("Argentina", style = "color: blue;"), paste0(" desde enero 2017 hasta ",traducir_mes(format(max(indec$periodos), "%B"))," de ", as.character(max(indec$year)))),
      fluidRow(
        bs4ValueBoxOutput("valuebox_mensual"),
        bs4ValueBoxOutput("valuebox_interanual"),
        bs4ValueBoxOutput("valuebox_mayor")
      ),
      fluidRow(
        column(
          width = 7,
          tabBox(
            width = 12,
            tabPanel(
              # UI timeserie ----------------------------------------------------------------------
              title = "Time Serie",
              withSpinner(
                highchartOutput("timeserie"),
                type = 1
              )
            )
          )
        ),
        column(
          width = 5,
          tabBox(
            width = 12,
            tabPanel(
              # UI barplot ----------------------------------------------------------------------
              title = "Bar Plot",
              withSpinner(
                highchartOutput("barplot"),
                type = 1
              )
            )
          )
        )
      )),
    # UI about ----------------------------------------------------------------------
    tabItem(
      tabName = "bp",
      h3("Grafico de Barras por Sector"), 
      br(),  
      p("Variacion mensual e interanual de los precios en Argentina."),
      column(
        width = 12,
        radioButtons(
          inputId = "barplotperiodo",
          label = "Seleccionar:",
          choices = c("Interanual","Mensual"), 
          selected = "Mensual",
          inline = TRUE,
          width = '400px'),
        tabBox(
          width = 12,
          tabPanel(
            # UI timeserie ----------------------------------------------------------------------
            title = "Bar Plot",
            withSpinner(
              highchartOutput("barplot2"),
              type = 1
            )
          )
        )
      )
    ),
    
    
    tabItem(
      tabName = "about",
      h2("Acerca de"),
      fluidRow(
        box(
          title = strong("Dashboard sobre los precios en Argentina"), solidHeader = TRUE,
          p("Este Dashboard tiene la finalidad de mostrar la variación mensual e interanual de los distintos sectores de la economía para la ", strong("región GBA"), "."),
          p("Podemos ver las siguientes métricas:"),
          tags$ol(
            tags$li("Variación interanual de la inflación."),
            tags$li("Variación mensual de la inflación."),
            tags$li(" Variación anual acumulada.")
          ),
          p("Los datos utilizados provienen de la pagina oficial de:"),
          tags$ul(
            tags$li(tags$a(href="https://www.indec.gob.ar/", "Indec"))
          ),
          p("Packages:"),
          tags$ul(
            tags$li(tags$a(href="https://jkunst.com/highcharter/index.html", "highcharter")),
            tags$li(tags$a(href="https://rinterface.github.io/bs4Dash/index.html", "bs4Dash")),
            tags$li(tags$a(href="https://dplyr.tidyverse.org/", "dplyr"))
          )
          
        ),
        box(
          title = strong("Trabajo hecho por:"), solidHeader = TRUE,
          h5("Galoto Maximiliano"),
          tags$ul(
            tags$li(tags$a(href="https://www.linkedin.com/in/maximilianogaloto", "Linkedin")),
            tags$li(tags$a(href="https://github.com/MGaloto", "GitHub")))
          
        )
      )
      
      
    )
  )
)
)

# SV ----------------------------------------------------------------------
server <- function(input, output,session) {
  
  
  # reactiveValues----------------------------------------------------------------------
  
  rv <- reactiveValues()
  
  
  observeEvent(input$input1, {
    
    
    # SV search_tweets ----------------------------------------------------------------------
    # 
    rv$indec = indec
    
    rv$indec$period_filter = substr(as.Date(rv$indec$periodos), 1, 7)
    
    
    rv$data = tibble(		
      x = as.Date(rv$indec$periodos[12:nrow(rv$indec)]),		
      y = round(((((pull(rv$indec[,c(input$input1)])/100)+1) *  		
                    ((lag(pull(rv$indec[,c(input$input1)]), 1)/100)+1) *  		
                    ((lag(pull(rv$indec[,c(input$input1)]), 2)/100) + 1)	*  	
                    ((lag(pull(rv$indec[,c(input$input1)]), 3)/100)+1)*  		
                    ((lag(pull(rv$indec[,c(input$input1)]), 4)/100)+1)		*  
                    ((lag(pull(rv$indec[,c(input$input1)]), 5)/100)+1)	*  	
                    ((lag(pull(rv$indec[,c(input$input1)]), 6)/100)+1)	*  	
                    ((lag(pull(rv$indec[,c(input$input1)]), 7)/100)+1)		*  
                    ((lag(pull(rv$indec[,c(input$input1)]), 8)/100)+1)	*  	
                    ((lag(pull(rv$indec[,c(input$input1)]), 9)/100)+1)	*  	
                    ((lag(pull(rv$indec[,c(input$input1)]), 10)/100)+1)	*  	
                    ((lag(pull(rv$indec[,c(input$input1)]), 11)/100)+1) - 1 ) * 100),1)[12:nrow(rv$indec)])
    
    
    
    
    rv$data2 = rv$indec %>% 
      select(input$input1, 'year','Mes') %>% 
      mutate(interanual = format(round((pull(rv$indec[,c(input$input1)]) / 100 ) + 1, 3), nsmall = 3))  %>%
      filter(rv$indec$Mes <= rv$indec$Mes[nrow(rv$indec)]) %>% 
      select('interanual', 'year') %>% 
      group_by(year) %>% 
      summarise(prod = format(round(prod(as.numeric(interanual)), 4), nsmall = 2)) %>% 
      mutate(interanual = (as.numeric(prod) - 1)*100)%>% 
      mutate(interanual = round(as.numeric(interanual),4))
    
    
    
  }, ignoreNULL = FALSE)
  
  
  
  
  # SV timeserie ----------------------------------------------------------------------
  output$timeserie <- renderHighchart({
    req(rv$data)
    rv$data %>% head()
    
    highcharter::hchart(
      rv$data, type = "line",  highcharter::hcaes(x = "x", y = "y"),
      color = "#007bff",
      name = str_to_title(gsub("_", " ", input$input1)), 
      id = "trend",
      showInLegend = TRUE) %>%
      highcharter::hc_tooltip(crosshairs = TRUE, pointFormat = "Tasa Interanual: {point.y}") %>%
      
      highcharter::hc_plotOptions(
        line = list(
          color = "blue",
          marker = list(
            fillColor = "white",
            lineWidth = 2,
            radius=1,
            lineColor = NULL
          )
        )
      ) %>%
      highcharter::hc_legend(enabled = FALSE) %>%
      highcharter::hc_xAxis(
        title = list(text = ""),
        gridLineWidth = 0,
        dateTimeLabelFormats = list(day = '%Y'),
        type = "datetime",
        reversed = FALSE,
        labels = list(
          style = list(color = "black", fontWeight = "bold")
        )
      ) %>%
      highcharter::hc_yAxis(
        title = list(text = "% Interanual",
                     style = list(color = "black", fontWeight = "bold")),
        gridLineWidth = 0,
        reversed = FALSE,
        labels = list(
          style = list(color = "black", fontWeight = "bold")
        )
      ) %>%
      
      highcharter::hc_caption(
        text = paste0("Serie Temporal de  ",str_to_title(gsub("_", " ", input$input1)),". <br>Fuente: Indec."),
        style = list(fontSize = '12px', fontWeight = 'bold', color = "black")) %>%
      highcharter::hc_tooltip(
        crosshairs = TRUE,
        backgroundColor = "#F0F0F0",
        shared = TRUE, 
        borderWidth = 5
      ) %>% 
      hc_title(
        text = paste0('Inflacion ', gsub('_', ' ', colnames(rv$indec[,c(input$input1)]))),
        style = list(fontSize = '16px', fontWeight = 'bold', color = "black")) %>% 
      hc_subtitle(
        text = 'Desde 2017.',
        style = list(fontSize = '12px', fontWeight = 'bold', color = "black")) %>% 
      
      hc_credits(enabled = TRUE, text = "INDEC",align = "right",verticalAlign = "bottom",
                 style = list(color = "#2b908f", fontSize = '10px', fontWeight = 'bold', color = "black"),
                 href = " https://www.indec.gob.ar/") 
  })
  # SV barplot ----------------------------------------------------------------------
  
  output$barplot <- renderHighchart({
    req(rv$data2)
    
    
    highcharter::hchart(
      rv$data2, 
      type = "column",  
      highcharter::hcaes(x = "year", y = "interanual"),
      color = "#007bff",
      name = str_to_title(gsub("_", " ", input$input1)), 
      showInLegend = F,
      maxSize = "15%",
      dataLabels = list(enabled = TRUE,
                        format = '{point.y:.2f} %')) %>%
      hc_legend(enabled = FALSE) %>% 
      highcharter::hc_tooltip(
        crosshairs = FALSE, 
        pointFormat = "Inflacion: {point.y:.2f} %") %>%
      highcharter::hc_xAxis(
        title = list(text = ""),
        gridLineWidth = 0,
        dateTimeLabelFormats = list(day = '%Y'),
        type = "date",
        reversed = FALSE,
        labels = list(
          style = list(color = "black", fontWeight = "bold")
        )
      ) %>%
      highcharter::hc_yAxis(
        title = list(text = "% Acumulado",
                     style = list(color = "black", fontWeight = "bold")),
        gridLineWidth = 0,
        reversed = FALSE,
        labels = list(
          style = list(color = "black", fontWeight = "bold")
        )
      ) %>%
      
      highcharter::hc_caption(
        text = paste0("Grafico de barras de ",str_to_title(gsub("_", " ", input$input1)),". <br>Fuente: Indec."),
        style = list(fontSize = '12px', fontWeight = 'bold', color = "black")) %>%
      hc_title(
        text = paste0('Inflacion ', gsub('_', ' ', colnames(indec[,c(input$input1)]))),
        style = list(fontSize = '16px', fontWeight = 'bold', color = "black")) %>% 
      hc_subtitle(
        text = paste0('Acumulada por año hasta ', as.character(rv$indec$Mes[nrow(rv$indec)]), "/", as.character(rv$indec$year[nrow(rv$indec)])),
        style = list(fontSize = '12px', fontWeight = 'bold', color = "black")) %>% 
      highcharter::hc_tooltip(
        crosshairs = TRUE,
        backgroundColor = "#F0F0F0",
        shared = TRUE, 
        borderWidth =1
      ) %>% 
      hc_credits(enabled = TRUE, text = "INDEC",align = "right",verticalAlign = "bottom",
                 style = list(color = "#2b908f", fontSize = '10px'),
                 href = " https://www.indec.gob.ar/")
    
    
    
  })
  
  
  
  # SV bar ----------------------------------------------------------------------
  output$barplot2 <- renderHighchart({
    if (input$barplotperiodo == "Mensual"){
      data = data_bar(rv$indec, indec_colnames)
      
    } else {
      data = interanual_df(rv$indec, indec_colnames)
    }
    
    
    data %>% 
      arrange(desc(tasa)) %>% 
      hchart('column', hcaes(x = sector, y = round(tasa,2), color = viridis::mako(n = 13)),
             showInLegend = F,
             maxSize = "15%",
             dataLabels = list(enabled = TRUE,
                               format = '% {point.y: .2f}')) %>%
      highcharter::hc_tooltip(crosshairs = TRUE, pointFormat = paste0("Tasa ",input$barplotperiodo,": {point.y}")) %>%
      highcharter::hc_plotOptions(
        line = list(
          color = "blue",
          marker = list(
            fillColor = "white",
            lineWidth = 2,
            radius=1,
            lineColor = NULL
          )
        )
      ) %>%
      highcharter::hc_legend(enabled = FALSE) %>%
      highcharter::hc_xAxis(
        title = list(text = "Sectores"),
        gridLineWidth = 0,
        reversed = FALSE,
        labels = list(
          style = list(color = "black", fontWeight = "bold",style = list(color = "black", fontWeight = "bold"))
        )
      ) %>%
      highcharter::hc_yAxis(
        title = list(text = paste0("% ",input$barplotperiodo),
                     style = list(color = "black", fontWeight = "bold")),
        gridLineWidth = 0,
        reversed = FALSE,
        labels = list(
          style = list(color = "black", fontWeight = "bold")
        )
      ) %>%
      
      highcharter::hc_caption(
        text = paste0("Tasa ",input$barplotperiodo," de Inflacion por Sector. <br>Fuente: Indec."),
        style = list(fontSize = '12px', fontWeight = 'bold', color = "black")) %>%
      highcharter::hc_tooltip(
        crosshairs = TRUE,
        backgroundColor = "#F0F0F0",
        shared = TRUE, 
        borderWidth = 5
      ) %>% 
      hc_title(
        text = paste0("Tasa ",input$barplotperiodo," de Inflacion por Sector."),
        style = list(fontSize = '16px', fontWeight = 'bold', color = "black")) %>% 
      
      hc_credits(enabled = TRUE, text = "INDEC",align = "right",verticalAlign = "bottom",
                 style = list(color = "#2b908f", fontSize = '10px', fontWeight = 'bold', color = "black"),
                 href = " https://www.indec.gob.ar/") 
  })
  
  
  
  
  # value box ----------------------------------------------------------------------
  # 
  
  
  
  
  output$valuebox_mensual <- renderbs4ValueBox({
    
    bs4ValueBox(
      value = paste0(pull(rv$indec[,c(input$input1)])[nrow(rv$indec)], ' %'),
      subtitle = input$input1,
      icon = icon("table"),
      color = "info",
      width = NULL,
      footer = div(paste0("Tasa mensual ",traducir_mes(format(max(rv$indec$periodos), "%B"))," de ", as.character(max(rv$indec$year))))
    )
    
    
  })
  
  
  
  
  
  
  output$valuebox_interanual <- renderbs4ValueBox({
    
    bs4ValueBox(
      value = paste0(interanual(rv$indec, input$input1), ' %'),
      subtitle = input$input1,
      icon = icon("user-circle"),
      color = "gray",
      width = 3,
      gradient = T,
      footer = div(paste0("Interanual hasta ",traducir_mes(format(max(rv$indec$periodos), "%B"))," de ", as.character(max(rv$indec$year))))
    )
    
  })
  
  
  
  output$valuebox_mayor <- renderbs4ValueBox({
    
    bs4ValueBox(
      value = paste0(t(apply(rv$indec[nrow(rv$indec), 1:(ncol(rv$indec) - length(c('periodos', 'year', 'Mes', 'month', 'period_filter')))], 1, sort))[ncol(t(apply(rv$indec[nrow(rv$indec), 1:(ncol(rv$indec) - length(c('periodos', 'year', 'Mes', 'month', 'period_filter')))], 1, sort)))], ' %'),
      subtitle = colnames(t(apply(rv$indec[nrow(rv$indec), 1:(ncol(rv$indec) - length(c('periodos', 'year', 'Mes', 'month', 'period_filter')))], 1, sort)))[ncol(t(apply(rv$indec[nrow(rv$indec), 1:(ncol(rv$indec) - length(c('periodos', 'year', 'Mes', 'month', 'period_filter')))], 1, sort)))],
      icon = icon("hourglass-half"),
      color = "pink",
      width = NULL,
      footer = div(paste0("Mayor incremento en ",traducir_mes(format(max(rv$indec$periodos), "%B"))," de ", as.character(max(rv$indec$year))))
    )
    
  })
  
  
}

shinyApp(ui = ui, server = server)