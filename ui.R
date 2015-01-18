library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  fluidRow(column(width=10, offset=1, 
                  h1("Mouse-itis predictor"))),
  
#  fluidRow(column(width=10, offset=1, )),
  
  fluidRow(
    column(width=10, offset=1,
      h3("Introduction"),
      p("Mouse-itis is a neurological condition found in a 
         small fraction of the population. It's principle
         symptom is an increased level of frustration (measured
         on a scale from 0 to 100) which however due to differences
         in inherent levels of frustration is not a binary indicator.
         Fortunately the condition is detectable by a test but 
         not surprisingly this test is
         not completely reliable, giving occasional false 
         positives and missing the occasional sufferer.")
    )    
  ),
  
  fluidRow(column(width=10, offset=1, h3("The model"))),

  fluidRow(
    column(width = 5, offset=1,
      sliderInput("pct_occurence", 
                  label="Occurence of the condition in the population (%)",
                  min=1, max=100, value=50),
      br(),
      sliderInput("non_sufferer_mean_frust",
                  label="Mean frustration of non-sufferer",
                  min=30, max=50, value=35),
      br(),
      sliderInput("sufferer_mean_frust",
                  label="Mean frustration of sufferer",
                  min=50, max=70, value=65),
      br()
    ),
    column(width = 5,
      plotOutput("frustration")
    )
  ),
  
  fluidRow(column(width=10, offset=1, h3("Generate some sample data") )),

  fluidRow(
    column(width = 5, offset=1,
           numericInput("n", label="Number of samples to generate", 100,
                        min=100, max=1000),
           br(),
           sliderInput("test_false_positive", 
                       label="Probability (false positive) (%)",
                       min=0, max=10, value=5),
           br(),
           sliderInput("test_true_positive", 
                       label="Probability (true positive) (%)",
                       min=80, max=100, value=90),
           br(),
           actionButton("generate", label="Generate samples")
    ),
    column(width = 5,
           plotOutput("samples_graphic"),
           #tableOutput("samples"),
           br()
    )
  ),

fluidRow(column(width=10, offset=1, h3("Train a prediction algorithm") )),

  fluidRow(
    column(width = 10, offset=1,
      p("We would like to know if a given person is afflicted by
         this condition. Since the condition results in an increased
         level of frustration our first thought might be that anyone
         with a frustration level above a certain threshold should
         be considered afflicted. This will obviously produce some
         miss classifications and by varying the level of the threshold
         we can vary in which direction we have a tendency to 
         missclassify; whether we miss actual positive cases or determine
         to be afflicted people who in reality are not. The result of 
         the test bring additional information which we can include in
         such an analysis. Let's do it with and without the test results"),
      br(),
      p("Our interest is in determining the value of the variable",code("Afflicted"),
        "which is binary. Let's perform a logistic regression using the model:"),
      code("Afflicted ~ FrustrationLevel"),
      #br(),
      #actionButton("doLogit_1", label="Do basic logistic regression on the 
      #             frustration level"),
      br(),
      p("When affliction results in ", em("significant"), "additional frustration
         a simple frustration threshold may be used to recognize the condition.
         In general though, this is not effective. The test for the condition is 
         not related to the frustration level and provides an additional source
         of information for identifying sufferers. A more useful model is thus:"),
      code("Afflicted ~ FrustrationLevel + TestResult"),
      #br(),
      #actionButton("doLogit_2", label="Do regression on frustration level and 
      #             test result"),
      br()
    )
  ),

  fluidRow(column(width=10, offset=1, h3("Simpe logistic regression") )),

  fluidRow(
    column(width=5, offset=1,
           verbatimTextOutput("logistic_regression_1")
    ),
    column(width = 5,
           plotOutput("logistic_regression_1_plot"),
           br()
    )
  ),
  
  fluidRow(column(width=10, offset=1, h3("Logistic regression including the test result") )),

  fluidRow(
    column(width=5, offset=1,
           verbatimTextOutput("logistic_regression_2"),
           br(),
           p("In the plot red crosses correspond to correctly diagnosed
             sufferers, black circles correspond to correctly diagnosed
             non-suffers and the others are incorrect diagoses.")
    ),
    column(width=5,
           plotOutput("logistic_regression_2_plot")
    )
  ),

  fluidRow(column(width=10, offset=1, h3("Diagnosis") )),

  fluidRow(
    column(width = 5, offset=1,
           p("It remains to use the results to diagnose the condition. We do this
         by choosing a threshold probability, above which we diagnose the 
         condition. By varying the level of this threshold we can control 
         whether we are more inclined to diagnose the condition in people
         who in reality do not have it, or conversly be conservative in the
         diagnosis and risk missing people who actually do have it."),
           br(),
           sliderInput("threshold", label="Threshold", min=0, max=1, value=0.8),
           br(),
           p("In order to see some effect from changing the threshold you must
        reduce the fidelity of the test. A perfect test allows no room for
        tinkering."),
           br()
    ),
    column(width = 5,
           p("A comparison of the real state of health of the test subjects
         and the diagnoses is shown in the table"),
           tableOutput("confusion_matrix")
    )
  ),
  
  fluidRow(
    column(width=10, offset=1,
           h3("Diagnose yourself")
    )
  ),
  
  fluidRow(
    column(width = 10, offset=1, 
           p("Based upon this model, enter your own frustration level and 
         (imagined) test result for diagnosis."),
           br()
    )
  ),
  
  fluidRow(
    column(width=5, offset=1,
           sliderInput("client_frustration_level", label="Frustration level",
                       min=0, max=100, value=50),
           selectInput("client_test_result", label="Test result", 
                       choices=list("Negative", "Positive")),
           br(),
           br() # Force some space at the bottom of the page 
    ),
    column(width = 5,
           p("The result of the diagnosis is that you are: "), 
           textOutput("client_diagnosis")
           
    )
  )
))
