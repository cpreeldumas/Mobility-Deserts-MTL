library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(leaflet)
library(rsconnect)

shinyApp(
  ui = dashboardPage(skin = "yellow",
                     dashboardHeader(title = "PODS Hackathon 3", dropdownMenu(type = "notifications")),
                     dashboardSidebar(sidebarMenu(
                       menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
                       menuItem("More on PODS", icon = icon("send",lib='glyphicon'), 
                                href = "https://www.policyanddatascience.org/")
                     )),
                     dashboardBody(
                       
                       fluidRow(
                         infoBox("Yearly Car Collisions", 24177, color= "teal", icon = icon("car"), fill = TRUE),
                         infoBox("Yearly Bike Collisions", 970, color = "teal", icon = icon("bicycle"), fill = TRUE),
                         infoBox("Yearly Bus Collisions", 608, color= "teal", icon = icon("bus"), fill = TRUE)),
                       
                       
                       fluidRow(boxPlus("To visualize mobility deserts, we created a Mobility Index 
      to give each borough a transit score. More broadly, this index can be defined as the percentage of area within 
                   a borough that falls outside of the following criteria:", br(), br(), "- 100m from a bixi stand", br(), 
                                        "- 100m from a bike lane", br(), "- 100m from a metro or bus line", br(), 
                                        "- 500m from a hospital/urgent care center", br(),
                                        title = "How did this map come to be, you may ask", status = "primary", solidHeader = T, width = 10, enable_label = T,
                                        label_text = "info",
                                        label_status = "warning", height = 220),
                                gradientBox(width =2, height = 215, gradientColor = "maroon", boxToolSize = "m", footer = "Let us know what you think!",
                                            icon = "fa fa-users", title = "Get Our Code & follow us!", 
                                            status = "info", enable_label = F, collapsible = F, 
                                            socialButton(url = "http://github.com", type = "github" ), 
                                            socialButton(url = "https://www.facebook.com/McGillUniversity/", type = "facebook"), 
                                            socialButton(url = "https://twitter.com/PodsProgram", type = "twitter"), 
                                            socialButton(url = "https://www.policyanddatascience.org/", type = "wordpress"))),
                       
                       fluidRow(boxPlus(title = "Let's visualize", solidHeader = T, status = "warning", width = 12, enable_label = T,
                                        label_text = "Map",
                                        label_status = "danger", leafletOutput("map2"), footer = "This map presents the score given to each borough based on the Mobility Index we designed")),
                       
                       fluidRow
                       (gradientBox(title = "Numbers & Axes",  width = 4, icon = "fa fa-chart-bar", gradientColor = "green", boxToolSize = "s", closable = TRUE,
                                    footer = "This graph presents the number of car collisions by year for each municipality", plotOutput("myplot")),
                         
                         
                         boxPlus(title = "Another Geographic Visualisation", status = "warning", solidHeader= F, width = 8,enable_label = T,
                                 label_text = "Map",
                                 label_status = "danger", leafletOutput("mymap"), footer = "This has been calculated using data 
                           provided by the City of Montreal for the last 6 years.")), 
                       
                       fluidRow((boxPlus(title = "Annual Bike Collisions by Montreal Municipality", width = 6, plotOutput("myplot2"), solidHeader = T, status = "info", enable_label = T, 
                                         label_text = "Graph")), 
                                boxPlus(title = "Annual Bus Collisions by Montreal Municipality", plotOutput("myplot3"),solidHeader = T, status = "info", enable_label = T, 
                                        label_text = "Graph"))
                       
                       
                     )),
  
  
  server = function(input, output) { output$mymap <- output$mymap <- renderLeaflet({leaflet_map})
  {output$myplot <- output$myplot <- renderPlot(mtl_cars_notml)}
  {output$myplot2 <- output$myplot2 <- renderPlot(mtl_bikes_notml)}
  {output$myplot3 <- output$myplot3 <- renderPlot(mtl_bus_notml)}
  {output$map2 <- output$map2 <- renderLeaflet(leaflet_map2)}
  
  })



