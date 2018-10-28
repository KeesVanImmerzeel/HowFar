library(shiny)

library(maps)
data(world.cities)
cities <- world.cities
cities %<>% subset(select = -c(country.etc, pop, capital)) %>%
      rename(city = name) %>% rename(lng = long) %>% arrange(city)

library(geosphere)
##distm (c(lon1, lat1), c(lon2, lat2), fun = distHaversine)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
      ## The call to modalDialog() generates the HTML.
      observeEvent(input$helpButton, {
            showModal(
                  modalDialog(
                        title = "Hint",
                        "After you specify the current location as your home location,
                        the distance to your home location is calculated if you visit
                        a new city. The distance is calculated with the distm function of the geosphere package (option distHaversine).",
                        easyClose = TRUE
                  )
            )
      })
      
      ## Whenever a reactive value changes, any reactive expressions
      ## that depended on it are marked as "invalidated" and will automatically re-execute if necessary.
      aRecord = reactive({
            acity <- input$acity
            subdata <-  cities %>% filter(city == acity)
            return(subdata)
      })
      
      df = reactive({
            adf = data.frame(lat = aRecord()$lat, lng = aRecord()$lng)
            return(adf)
      })
      output$lat <- renderText({
            paste("lat=", toString(df()$lat))
      })
      output$lng <- renderText({
            paste("lng=", toString(df()$lng))
      })
      
      output$mymap <-  renderLeaflet({
            df() %>% leaflet() %>% addTiles() %>%
                  addMarkers()
      })
      
      # Use eventReactive to create a calculated value that only updates in
      # response to an event.it ONLY invalidates in response to the given event.
      # In this case, when the value of input$goButton becomes out of date
      # (i.e., when the button is pressed),
      ## the object ntext will get updated
      ## or the app starts (ignoreNULL = FALSE).
      homeLocation <-
            eventReactive(input$setHomeLocationButton, {
                  input$acity
            }, ignoreNULL = FALSE)
      
      lathome <- eventReactive(input$setHomeLocationButton, {
            df()$lat
      }, ignoreNULL = FALSE)
      lnghome <- eventReactive(input$setHomeLocationButton, {
            df()$lng
      }, ignoreNULL = FALSE)
      
      ## Use observeEvent whenever you want to PERFORM AN ACTION IN RESPONSE TO
      ## AN EVENT. In this case, when the setHomeLocationButton is pressed,
      ## update the text in the (disabled) homeLocation textInput field.
      observeEvent(input$setHomeLocationButton, {
            updateTextInput(session, "homeLocation",
                            value = input$acity)
      })
      
      output$lathome <-
            renderText({
                  paste("lat=", toString(lathome()))
            })
      
      output$lnghome <-
            renderText({
                  paste("lng=", toString(lnghome()))
            })
      
      output$dist <- renderText({
            dist <-
                  distm (c(df()$lng, df()$lat), c(lnghome(), lathome()), fun = distHaversine)[1]
            
            toString(as.integer(dist[1] / 1000))
      })
      
      ## Automatically stop Shiny app when closing the browser tab
      session$onSessionEnded(stopApp)
})
