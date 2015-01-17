library(shiny)
library(ggplot2)
library(reshape2)

fl <- seq(0,100)    # frustration levels
sd_frust <- 10.0   # std deviation of frustration (equal for both populations)


shinyServer(function(input, output) {
  
  # React to changes in model inputs
  non_sufferer_mean_frust <- reactive({input$non_sufferer_mean_frust})
  sufferer_mean_frust <- reactive({input$sufferer_mean_frust})
  pct_occurence <- reactive({input$pct_occurence})
  
  # Frustration model data for plots
  model_data <- reactive({df<- data.frame(level=fl, 
                                          suff_occur = pct_occurence() * dnorm((fl-sufferer_mean_frust())/sd_frust),
                                          non_suff_occ = (100 - pct_occurence()) * dnorm((fl-non_sufferer_mean_frust())/sd_frust)
                                         )
                          melt(df, c("level"),  variable.name=c("SubPopulation"), value.name=c("Occurence"))
  })
  
  output$frustration <- renderPlot({
    ggplot(model_data()) + geom_area(aes(x=level, y=Occurence, group=SubPopulation, fill=SubPopulation), alpha=0.5) +
                           xlab("Frustration level")
  })

  # Generate data sample
  n_samples <- reactive({input$n})

  # Generate data sample only when the button is pushed
  # not when the number of samples is changed
  sample_data <- reactive({
    input$generate
    n <- isolate(n_samples())
    # cat("Generate: ", n, "\n", sep="")
    
    # Random vector of Afflicted/Not afflicted
    df = data.frame(Afflicted=sample(c(TRUE,FALSE), n, replace=TRUE, 
                                     prob=c(isolate(pct_occurence()/100.), 1 - isolate(pct_occurence()/100.) ))
                    )
    
    # Get means for afflicted and unaflicted people
    smf <- isolate(sufferer_mean_frust())
    nsmf <- isolate(non_sufferer_mean_frust())
    
    # Determine random level of frustration dependent on affliction status
    df$FrustrationLevel <- rnorm(n, ifelse(df$Afflicted, smf, nsmf), sd_frust)

    # Get probabilities
    P_TP <- isolate(reactive({input$test_true_positive/100.}))
    P_FP <- isolate(reactive({input$test_false_positive/100.}))
  
    # Determine random test result also dependent of affliction status
    df$TestResult <- sapply(df$Afflicted, function(x) { ifelse(x,
                                            sample(c("Positive","Negative"), 1, prob=c(P_TP(), 1-P_TP())),
                                            sample(c("Positive","Negative"), 1, prob=c(P_FP(), 1-P_FP())))})
    df
  })

  # Render the data frame in a table 
  output$samples <- renderTable({ sample_data()[1:3,] })

  # Display the sample data graphically
  output$samples_graphic <- renderPlot({
    ggplot(sample_data()) + geom_point(aes(x=FrustrationLevel, y=Afflicted, color=TestResult))
  })
  
  # Apply some machine learning
  # Simple logistic regression on the level of frustration
  logistic_regression_1 <- reactive({
    model <- glm( Afflicted ~ FrustrationLevel, family=binomial(logit), data=sample_data())
    model
  })
  
  output$logistic_regression_1 <- renderPrint({ logistic_regression_1() })
  output$logistic_regression_1_plot <- renderPlot({
    predictions_df <- data.frame(FrustrationLevel=fl)
    predictions_df$Prob <- predict(logistic_regression_1(), data.frame(FrustrationLevel=fl),type="response")
    ggplot(sample_data()) + geom_point(aes(x=FrustrationLevel, y=ifelse(Afflicted,1,0), color=Afflicted),size=5) + 
                            geom_line(data=predictions_df, aes(x=FrustrationLevel, y=Prob),size=1.5) +
                            labs(x="Frustration level", y="Probability of afflication")
  })

  
  # Add test result to regression model 
  logistic_regression_2 <- reactive({
    model <- glm( Afflicted ~ FrustrationLevel + TestResult, family=binomial(logit), data=sample_data())
    model
  })
  
  expanded_data <- reactive({
    data <- sample_data()
    data[["ProbAffliction"]] <- predict(logistic_regression_2(), data, type="response")
    data[["Diagnosis"]] <- ifelse(data[["ProbAffliction"]] > input$threshold,"Afflicted","Healthy")
    data
  })
  
  output$logistic_regression_2 <- renderPrint({ logistic_regression_2() })
  output$logistic_regression_2_plot <- renderPlot({
    #data <- sample_data()
    #data[["ProbAffliction"]] <- predict(logistic_regression_2(), data, type="response")
    #data[["Diagnosis"]] <- ifelse(data[["ProbAffliction"]] > input$threshold,"Afflicted","Healthy")
    #print(data)
    ggplot(expanded_data()) + geom_point(aes(x=FrustrationLevel, y=TestResult, shape=Afflicted, 
                                  color=Diagnosis), size=5, alpha=0.4) + 
        scale_shape_manual(values=c(1,4)) + scale_colour_manual(values=c("red", "black")) + 
        labs(x="Frustration level", y="Test result") 
  })
  
  output$confusion_matrix <- renderTable({
    data <- expanded_data()
    x <- table(ifelse(data$Afflicted,"Afflicted","Healthy"), data$Diagnosis)
    n <- sum(x)
    A <- (x[1,1] + x[2,2]) / n
    P <- x[1,1] / colSums(x)[1]
    R <- x[1,1] / rowSums(x)[1]
    data.frame(Statistic=c("Accuracy", "Precision", "Recall"), Value=c(A,P,R))
  })
  
  output$client_diagnosis <- renderText({
    client_data <- data.frame(FrustrationLevel=input$client_frustration_level, TestResult=input$client_test_result)
    probability <- predict(logistic_regression_2(), newdata=client_data, type="response")
    ifelse(probability > input$threshold, "Afflicted", "Healthy")
  })
})