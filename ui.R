library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Mouse-itis predictor: An exercise in Shiny"),
  
  sidebarLayout(
    sidebarPanel(
      
      
      h3("The model"),
      p("Mouse-itis is a neurological condition found in a 
         small fraction of the population. It's principle
         symptom is an increased level of frustration (measured
         on a scale from 0 to 100) which however due to differences
         in inherent levels of frustration is not a binary indicator.
         Fortunately the condition is detectable by a test but 
         not surprisingly this test is
         not completely reliable, giving occasional false 
         positives and missing the occasional sufferer."),
      sliderInput("pct_occurence", 
                  label="Occurence of the condition in the population (%)",
                  min=1, max=10, value=2),
      br(),
      sliderInput("non_sufferer_mean_frust",
                  label="Mean frustration of non-sufferer",
                  min=30, max=50, value=40),
      br(),
      sliderInput("sufferer_mean_frust",
                  label="Mean frustration of non-sufferer",
                  min=50, max=70, value=60),
      br(),
      
      
      h3("Some samples"),
      numericInput("n", label="Number of samples to generate", 10,
                   min=10, max=100),
      br(),
      actionButton("generate", label="Generate samples"),
      
      h3("The test"),
      sliderInput("test_false_positive", 
                  label="Probability (false positive) (%)",
                  min=0, max=5, value=1),
      br(),
      sliderInput("test_true_positive", 
                  label="Probability (true positive) (%)",
                  min=90, max=100, value=95),
      br()
    ),
    
    mainPanel(
      h3("Visualization of condition"),
      plotOutput("frustration"),
      br(),
      h3("Generated data"),
      plotOutput("samples_graphic"),
      tableOutput("samples")
    )
  )
))