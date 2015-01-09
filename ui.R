library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Placeholder App"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Sidebar"),
      textInput("hdr", label="Enter header")
    ),
    
    mainPanel(
      h3(textOutput("hdr"), align="center")
    )
  )
))