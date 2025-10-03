library(alphavantager)
library(dplyr)
library(lubridate)
library(googlesheets4)

# AUTENTICACIÓN
googledrive::drive_auth(path = "key.json")
gs4_auth(token = googledrive::drive_token())

# PARAMETROS
# Hojas existentes en el documento
tabs <- sheet_properties(ss)

# Nombre de la hoja a buscar/crear
mes_actual <- format(today(), "%B")

# Fechas inicial/final del mes
in_date <- floor_date(today(), "months")
end_date <- floor_date(today(), "months") %m+% months(1) - 1

# DATOS GENERALES 
range_clear(ss = ss,
            sheet = "Raw data",
            range = "B:G")


range_write(ss = ss,
            sheet = "Raw data",
            range = "B2",
            data = data |> 
              filter(timestamp >= as_date("2025-01-01")),
            reformat = FALSE)

# HOJAS INDIVIDUALES 
# Condición si no existe la hoja del mes actual
if (length(tabs$name[tabs$name == mes_actual ]) == 0 ){
  
  sheet_add(ss = ss, sheet = mes_actual)
  
  range_write(ss = ss,
              sheet = mes_actual,
              range = "B2",
              data = data |> 
                filter(between(timestamp, in_date, end_date)) |> 
                mutate(
                  timestamp = floor_date(timestamp, "weeks")
                ),
              reformat = FALSE
  )

# Condición si ya existe la hoja del mes actual    
}else{
  
  range_clear(
    ss = ss,
    sheet = mes_actual,
    range = "B:G"
  )
  
  range_write(ss = ss,
              sheet = mes_actual,
              range = "B2",
              data = data |> 
                filter(between(timestamp, in_date, end_date)) |> 
                mutate(
                  timestamp = floor_date(timestamp, "weeks")
                ),
              reformat = FALSE
  )
  
}
