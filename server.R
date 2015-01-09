library(shiny)

shinyServer(function(input, output) {
  
  output$hdr <- renderText({
    input$hdr
  })
})