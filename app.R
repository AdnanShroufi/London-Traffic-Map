# LONDON TRAFFIC ACCIDENTS 2016---------------------------------------------------------

# INSTALL NECESSARY PACKAGES

install.packages(c("dplyr", "scales", "ggplot2", "shiny", "leaflet",
                   "lubridate", "RColorBrewer", "shinydashboard"))

# LOAD THE ABOVE PACKAGES


library(dplyr)
library(scales)
library(ggplot2) 
library(shiny)
library(leaflet)
library(lubridate)
library(RColorBrewer)
library(shinydashboard)


# SET WORKING DIRECTORY AND IMPORT DATA------------------------------------------------


setwd("/Users/adnanshroufi/Desktop/")

rawData <- read.csv("dftRoadSafety_Accidents_2016.csv",
                    stringsAsFactors = TRUE,
                    header = TRUE)


# DATA CLEANING AND FACTOR SETTING-----------------------------------------------------

rawData2 = rawData %>%
  filter(Police_Force == 1 | Police_Force == 2 | Police_Force == 48)


# CHANGE DATE TO POSIXCT
# CREATE POSIXCT TIMESTAMP

rawData2$Time = as.POSIXct(rawData2$Time, format = "%H:%M")
rawData2$Date = as.POSIXct(rawData2$Date, format = "%d/%m/%Y")
rawData2$Timestamp = as.POSIXct(paste(rawData2$Date, rawData2$Time, format="%d-%m-%Y %H:%M"))


# ACCIDENT SEVERITY AS A FACTOR

rawData2$Accident_Severity = factor(rawData2$Accident_Severity,
                                    levels = c(1,2,3),
                                    labels = c("Major", "Serious", "Minor"))


# DAY OF WEEK AS A FACTOR

rawData2$Day_of_Week = factor(rawData2$Day_of_Week,
                              levels = c(1,2,3,4,5,6,7),
                              labels = c("Sunday", "Monday", "Tuesday", "Wednesday",
                                         "Thursday", "Friday", "Saturday"))


# GROUP SPEED LIMIT INTO 3 GROUPS

rawData2[rawData2$Speed_limit == 20, "Speed_limit"] = 30
rawData2[rawData2$Speed_limit == 40, "Speed_limit"] = 50
rawData2[rawData2$Speed_limit == 60, "Speed_limit"] = 70


# SPEED LIMIT AS A FACTOR

rawData2$Speed_limit = factor(rawData2$Speed_limit,
                              levels = c(30, 50, 70),
                              labels = c("20-30 mph", "40-50 mph", "60-70 mph"))


# REMOVE NULL VALUES FROM SPEED LIMIT

rawData2 = rawData2 %>%
  filter(Speed_limit != "NULL") %>%
  select(Longitude, Latitude, Accident_Severity, Number_of_Vehicles,
         Number_of_Casualties,Date, Time, Day_of_Week, Speed_limit, Timestamp)


# FILTER NUMBER OF CASUALTIES SO MAX = 10

rawData2 = rawData2 %>%
  filter(Number_of_Casualties <= 10) %>%
  as.data.frame()


# COLOUR SCHEME

pal <- colorNumeric(
  palette = "Reds",
  domain = rev(rawData2$Number_of_Casualties))




# END OF DATA PROCESSING #############################################################
######################################################################################
######################################################################################




#-------------------------------------------------------------------------------------

header <- dashboardHeader(title = "Accident Explorer")


#-------------------------------------------------------------------------------------


sidebar <- dashboardSidebar(
  

  checkboxGroupInput("severity", "Accident Severity:",
                     c("Major", "Serious", "Minor"),
                     selected = c("Major", "Serious", "Minor")
  ),
  
  checkboxGroupInput("speed", "Speed Limit:",
                     c("20-30 mph", "40-50 mph", "60-70 mph"),
                     selected = c("20-30 mph", "40-50 mph", "60-70 mph")
  ),
  
  
  sidebarMenu(
    sliderInput("vehicles",
                "Number of Vehicles:",
                min = min(rawData2$Number_of_Vehicles),
                max = max(rawData2$Number_of_Vehicles),
                value = c(2,9),
                step = 1)
  ),
  
  sidebarMenu(
    sliderInput("casualties",
                "Number of Injuries:",
                min = min(rawData2$Number_of_Casualties),
                max = max(rawData2$Number_of_Casualties),
                value = c(2,10),
                step = 1)
  ),
  
  dateRangeInput('dateRange',
                 label = 'Date Range Input:',
                 start = min(rawData2$Date),
                 end = max(rawData2$Date)
  ),
  
  
  p(
    class = "text",
    paste("Note:",
          "Each dot is a single acident.",
          "The size and colour of each dot signifies the number of injuries.", 
          "Click on a dot on the map for additional information."
    )
  )
  
 )



#------------------------------------------------------------------------------------

body <- dashboardBody(
  
  
  
  fluidRow(
    tags$head(tags$style(HTML("
                                #final_text {
                              text-align: center; font-size: 20px
                              }
                              div.box-header {
                              text-align: center;
                              }
                              "))),
    
    
    box(
      title = "London 2016: Traffic Accident Locations",
      width = 7,
      solidHeader = TRUE,
      background = "black",
      fluidPage(leafletOutput("mymap", width = "100%", height = "600px")
      )),
    fluidRow(
      tags$head(tags$style(HTML("
                                #final_text {
                                text-align: center;
                                }
                                div.box-header {
                                text-align: center;
                                }
                                "))),
      box(
        title = "Traffic Accident Times",
        solidHeader = TRUE,
        background = "black",
        width = 5,
        offset = 7,
        fluidPage(plotOutput("kde", width = "100%", height = "600px"))
    ))
      
        
      )
  
)

#------------------------------------------------------------------------------------


ui = dashboardPage(header, sidebar, body, skin="black")


#------------------------------------------------------------------------------------



server = function(input, output, session) {
  
  
  
  filteredData <- reactive({
    
    rawData2 %>%
      filter(Number_of_Casualties >= input$casualties[1] &
               Number_of_Casualties <= input$casualties[2] &
               Number_of_Vehicles >= input$vehicles[1] &
               Number_of_Vehicles <= input$vehicles[2] &
               Date >= input$dateRange[1] &
               Date <= input$dateRange[2] &
               Accident_Severity %in% input$severity &
               Speed_limit %in% input$speed)
    

  })
  

  
  # FOR THE MAP ITSELF
  
  
  output$kde = renderPlot(
    
    
    filteredData() %>%
      ggplot(aes(Day_of_Week, hour(Time)))+
      geom_point(aes(fill = as.factor(Number_of_Casualties),
                     size = as.factor(Number_of_Casualties),
      ),
      color="black", shape=21, stroke = 0.2)+
      geom_jitter(aes(fill = as.factor(Number_of_Casualties),
                      size = as.factor(Number_of_Casualties),
      ),
      color="black", shape=21, stroke = 0.2)+
      coord_flip()+
      scale_fill_brewer(palette = "Reds", drop=FALSE)+
      theme_minimal()+
      xlab("")+
      ylab("Hour")+
      theme(legend.title = element_blank())+
      scale_x_discrete(drop=FALSE)+
      theme(axis.text=element_text(size=12),
            axis.title=element_text(size=14,face="bold"))
    
    
  )
  

  output$mymap = renderLeaflet({
    
    
    leaflet(rawData2) %>%
      addTiles() %>%
      addProviderTiles(providers$Stamen.TonerLite) %>%
      setView(zoom=10, -0.1, 51.5074)
  })
  
  observe({
    
    leafletProxy("mymap", data = filteredData()) %>%
      clearShapes() %>%
      addCircles(fillColor = ~pal(Number_of_Casualties),
                 color = "black",
                 weight = ~(Number_of_Casualties/5),
                 stroke = TRUE,
                 fillOpacity = ~(Number_of_Casualties/5),
                 radius = ~((Number_of_Casualties+3)^3),
                 popup = ~paste("Date:", Timestamp, "<br>",
                               "Day of Week:", Day_of_Week, "<br>",
                               "Speed Limit:", Speed_limit, "<br>",
                               "Vehicles Involved:", Number_of_Vehicles, "<br>",
                               "Accident Severity:", Accident_Severity, "<br>",
                               "Number of Injuries:", Number_of_Casualties, "<br>")
                 
      )
    
  })
  
}


#------------------------------------------------------------------------------------------


runApp(shinyApp(ui, server), launch.browser = TRUE)


#-----------------------------------------------------------------------------------------

