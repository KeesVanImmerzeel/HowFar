library(shiny)
library(miniUI)
library(dplyr)
library(magrittr)
library(leaflet)
library(shinyjs)


# Define UI to draw the map of the specified city
shinyUI(fluidPage(

      useShinyjs(),
      # Set up shinyjs to disable a button
      titlePanel(title = "HowFar 28-10-2018"),
      sidebarLayout(
            sidebarPanel(
                  textInput(
                        inputId = "acity",
                        label = strong("City"),
                        value = "Amsterdam"
                  ),
                  shinyjs::disabled(
                        textInput(
                              inputId = "homeLocation",
                              label = "Home Location",
                              value = "Amsterdam"
                        )
                  ),
                  actionButton("setHomeLocationButton", "Make this my home location"),
                  actionButton("helpButton", label = "Help")
            ),
            mainPanel(
                  h4("Current coordinates   "),
                  textOutput("lat"),
                  textOutput("lng"),
                  h4("Home coordinates      "),
                  textOutput("lathome"),
                  textOutput("lnghome"),
                  h4("Distance to home (km) "),
                  textOutput("dist")
            )
      ),
      leafletOutput("mymap")
))

## https://ido-doesburg.shinyapps.io/HowFar/