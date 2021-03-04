ui <- fluidPage(
  
  titlePanel("SHS Map Test"),
  
  sidebarLayout(
    
    sidebarPanel(
      selectInput("DateCodeBC",
                  "Year:",
                  choices=sort(DateCode, decreasing = TRUE),
                  selected = max(DateCode)),
      
      selectInput("LocalAuthorityServicesAndPerformanceBC",
                  "Statement:",
                  choices=LocalAuthorityServicesAndPerformance)
    ),
    
    mainPanel(
      leafletOutput("map")
    )
  )
)
