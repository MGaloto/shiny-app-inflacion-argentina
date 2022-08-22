# Argentina Macro Trends


Proyecto en Curso que consiste en un dashboard dinámico de Variables Macroeconómicas para Argentina usando el Framework Shiny. 

Este dashboard se alimenta de los datos suministrados por el Indec.

<ui>
<li>
Inflación mensual por rubro.
</li>
<li>
Inflación interanual por rubro.
</li>
<li>
Serie Temporal de la inflación interanual por rubro
</li>
</ui>

La siguiente etapa del proyecto es generar gráficos interactivos en donde el usuario va a poder seleccionar variables macroeconómicas en un Scatter Plot y observar la relación de las mismas en valores absolutos y en tasas de cambio.


<p>
<a href="https://pkgs.rstudio.com/flexdashboard/" rel="nofollow"><img src="https://raw.githubusercontent.com/rstudio/hex-stickers/master/PNG/flexdashboard.png" align="right" width="150" style="max-width: 100%;"></a>
<a href="https://shiny.rstudio.com/" rel="nofollow"><img src="https://raw.githubusercontent.com/rstudio/hex-stickers/master/PNG/shiny.png" align="right" width="150" style="max-width: 100%;"></a>
</p>



# Incluye

<ui>
<li>
Extraccion, Transformacion y Carga.
</li>
<li>
Graficos Dinamicos y Estaticos.
</li>
<li>
Interactividad con Shiny.
</li>
</ui>




# Paquetes de R

<ui>
<li>
{tidyverse}
</li>
<li>
{plotly}
</li>
<li>
{highcharter}
</li>
<li>
{Shiny}
</li>
<li>
{flexdashboard}
</li>
</ui>


# Estructura

runtime: shiny le da interactividad al dashboard, es decir, mantiene la estructura de Flexdashboard pero suma las opciones que tiene Shiny para interactuar con la App.


```r
---
title: "Macro Trends Argentina"
output:
  flexdashboard::flex_dashboard:
     theme : cosmo
     orientation : rows 
     self_contained : TRUE
     css: css/styles.css
     navbar:
       - { title: "Indec", href: "https://www.indec.gob.ar/", align: right}
runtime: shiny
---

```


# Gif

<p align="center">
  <img 
    width="650"
    height="450"
    src="Img/shinyarg.gif"
  >
</p>





# Datos

<ui>
<li>
https://www.indec.gob.ar/
</li>
</ui>


# App

<ui>
<li>
https://maxi-galo.shinyapps.io/MacroTrends
</li>
</ui>