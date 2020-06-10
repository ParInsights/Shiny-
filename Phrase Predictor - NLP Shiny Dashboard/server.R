#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
source("./Predict.R", local = TRUE)

shinyServer(function(input, output) {
  
  
  predictFromText <- reactive({
    text <- trimws(input$text)
    predictWord(text,input$numPrediction)
  })
  
  output$prediction <- renderUI({
    
    if(nrow(predictFromText())==0) {
      return()
    }
    
    if(input$text != ''){
      list <- predictFromText()$predicted

      html_string <- character()
      for(word in list){
        string <- c("<button><a data-val='",trimws(word),"' class='prediction'>",word,"</a></button>")
        html_string = c(html_string, string)
      }
      
      html <- c("<p>", html_string, "</p>")
      results <- HTML(html)
      results
    } 
  })

  ### Generate Word Cloud 
  output$wordcloud = renderPlot({
    if(nrow(predictFromText())==0) {
      return()
    }
    
    if(input$text != ''){
      freqTerms = predictFromText()
      mu = mean(freqTerms$score)
      sigma = sd(freqTerms$score)
      freqTerms$score = round((((freqTerms$score - mu) / sigma) + 1.0)*10, 0)
      pal2 = brewer.pal(8,"Dark2")
      par(mar = rep(0, 4))
      wordcloud(freqTerms$predicted, freqTerms$score, scale = c(10, 0.8)
      , min.freq = 1, random.order = FALSE, rot.per = 0.15, colors = pal2)
    }
  })  
  
    
})