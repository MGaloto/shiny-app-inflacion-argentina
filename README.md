[![Update Data and Deploy](https://github.com/MGaloto/shiny-app-inflacion-argentina/actions/workflows/dashboard_refresh.yml/badge.svg)](https://github.com/MGaloto/shiny-app-inflacion-argentina/actions/workflows/dashboard_refresh.yml)

# Argentina Inflacion


<p>
<a href="https://shiny.rstudio.com/" rel="nofollow"><img src="https://raw.githubusercontent.com/rstudio/hex-stickers/master/PNG/shiny.png" align="right" width="150" style="max-width: 100%;"></a>
</p>



Dashboard de la variacion porcentual de los precios en Argentina. Se incluyen los distintos sectores de la economia para la region GBA.

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




### Contenido:
<br>
</br>

- [**Introduccion**](https://github.com/MGaloto/shiny-app-inflacion-argentina#introduccion)
- [**Github Actions**](https://github.com/MGaloto/shiny-app-inflacion-argentina#github-actions)
- [**Dashboard**](https://github.com/MGaloto/shiny-app-inflacion-argentina#dashboard)
- [**Ejecucion**](https://github.com/MGaloto/shiny-app-inflacion-argentina#ejecucion)


### Incluye

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


## Introduccion


<div style="text-align: right" class="toc-box">
 <a href="#top">Volver al Inicio</a>
</div>

<br>
</br>

Proyecto sobre un aplicacion [bs4Dash](https://rinterface.github.io/bs4Dash/index.html) utilizando datos del Indec para representar la variacion porcentual de los precios en distintos sectores en Argentina

La idea principal es poder tener datos actualizados en el Dashboard todos los meses, por lo tanto, se estara utilizando el flujo de trabajos de github actions para ir actualizando los datos.

Se va a utilizar [Docker](https://www.docker.com/) para crear una imagen y [Github Actions](https://docs.github.com/es/actions) para automatizar el dashboard.



### Estructura del Repositorio

``` shell
.
├── bash
├── docker-compose.yml
├── app.R
├── downloadData.R
├── .github
└── docker
```

- La carpeta `bash` se usa para almacenar scripts de bash que se usan en el flujo de trabajo de Acciones de Github.
- `docker-compose.yml` se utiliza para setear volumes, imagen y puertos para ejecutar el trabajo.
- `app.R` contiene el trabajo principal.
- `downloadData.R` contiene el ETL.
- `.github` contiene el WorkFlow.
- `docker` contiene todos los archivos de configuración de imágenes de Docker (por ejemplo, Dockerfile y algunos archivos auxiliares)

## Github Actions


<div style="text-align: right" class="toc-box">
 <a href="#top">Volver al Inicio</a>
</div>

<br>
</br>

Github Actions es una herramienta de CI/CD que permite programar y activar trabajos (o scripts). Se puede utilizar para:

* Automatizacion de ETL, Dashboards e Informes.

Para este trabajo se utiliza el siguiente workflow:

* El dashboard se actualiza el dia 1, 10 y 17 del mes a las 16 y 17 hs argentina (UTC-3)

``` yaml
name: Dashboard Refresh

on: 
  push:
    branches: [main]
  schedule:  
    - cron: '0 19,20 1,12,17 * *' # el dia 1,10 y 17 del mes a las 16 y 17 hs argentina
```



## Dashboard

<div style="text-align: right" class="toc-box">
 <a href="#top">Volver al Inicio</a>
</div>

<br>
</br>


[Dashboard](https://maxi-galo.shinyapps.io/macrotrends)



## Ejecucion


<div style="text-align: right" class="toc-box">
 <a href="#top">Volver al Inicio</a>
</div>

<br>
</br>

Se puede crear una nueva imagen en base al Dockerfile existente como tambien agregar nuevas dependencias y crear una imagen con un tag. En el caso de que se use la imagen mgaloto/bs4dashiny:01 esta misma ya cuenta con las dependencias para ejecutar el trabajo.

Para correr el script en local hay que ejecutar el siguiente comando de docker compose:

``` shell
docker-compose up -d
```

En el puerto 8787 se va a poder ingresar a R y ejecutar el index.Rmd (Recordar previamente modificar el docker-compose.yml con el directorio local del trabajo.)

Para darle stop al contenedor:

``` shell
docker-compose down
```
