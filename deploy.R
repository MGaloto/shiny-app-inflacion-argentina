library(rsconnect)

# a function to stop the script when one of the variables cannot be found
# and to strip quotation marks from the secrets when you supplied them
values_function <- function(name) {
  var <- Sys.getenv(name, unset = NA)
  if(is.na(var)) {
    stop(paste0("cannot find ", name, " !"), call. = FALSE)
  }
  gsub("\"", "", var)
}

# Authenticate
setAccountInfo(name = values_function("SHINY_ACC_NAME"),
               token = values_function("TOKEN"),
               secret = values_function("SECRET"))

# Deploy the application.
deployApp(appName="macrotrends",
          appFiles = c("app.R", 
                       "downloadData.R",
                       "indecnacional.xlsx"))



