# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(wordcloud)
library(RColorBrewer)

# Define UI for application that draws a histogram

shinyUI(fluidPage(
  
  # Application title
  
  titlePanel("Phrase Predictor"),
  
  # Sidebar with a slider input for number of bins 
  
  sidebarLayout(
    
    sidebarPanel(
  
      h4("Lets See What The Following Word in the Phrase Is...."),
      textAreaInput("text", "Type or Copy & Paste below:", width="100%", rows=4),
      br(),
      sliderInput("numPrediction", "Number of Words to Predict In the Phrase (Between 3 and 20):", 
                  min=3, max=20, value=5),
      ),
    
    # Show a plot of the generated distribution
    
    mainPanel(
      # Output: Tabset w/ plot, summary, and table ----
      tabsetPanel(type = "tabs",
                  tabPanel("Predictions", 
                           h4("How Do You Use This App?"),
                           p("Type a phrase in the box and let the Phrase Predictor list the potential following  words. Click on the suggested word you like to use and it will be added to your sentence."),      
                           
                           htmlOutput("prediction"),
                           hr(),
                           h4("Lets See If We Can Figure Out What Your Phrase Is...."),
                           br(),
                           div(style = "padding: 0px 0px; margin-top:-2em", align="center", 
                               plotOutput("wordcloud", width="500px",height="500px")
                           )
                           
                  ),
                  tabPanel("About",  
                           h3("Background"),
                           p("SwiftKey, software company, has built a smart keyboard that makes it easier for people to type on their mobile devices by utilizing predictive text modeling to createa smart keyboard. For example,say someone types “I am leaving the”, the keyboard would then show three options for what is likely the next word in the sentence. For example, the phrase might be following by either store, house, or gym. In general, a smart keyboard that makes it easier for people to type on their personal devices and increases communication time.The goal of this project was to build a predictive model that could be used in the SwiftKey keyboards to help predict the next word a person might type while also correcting any misspelling. "),
                           h3("How Do You Use This App?"),
                           p("Type a phrase in the box and let the Phrase Predictor list the potential following  words. Click on the suggested word you like to use and it will be added to your sentence."),
                           h3("Why Does It Work?"),
                           p("The predictive model is created through the extration of text lines from twitter, news, and other text-based blogs. The corpuses of these mined products was first cleansed using natural language processing methodology like normalization. For example we converted letters to lowercase and numbers, while special characters, hastags, and any urls were removed."),
                           p("We then maintained and tagged nGrams that were between the sizes fo 2 to 5 to be created."),
                           p("The logic follows the model where we start with a search on the highest Ngram, and then back-off to the lower Ngrams. The score is multiplied by a factor of 0.4  for each level we backed- down."),
                           p("Finally, we apply Discount/ and smoothing is applied in the model to speed up computation of the predicted words."),
                           h3("Thanks For Checking This Out"),
                           p("Thanks for checking out my fun app project! It was originally created as a fun way to continue my natural language processing work and build my skillset. The project was done in with collaboration from John Hopkins University and software, SwiftKey. "),
                           br()
                  )
      )
      
    )
    
  ),
  
  includeHTML("./addword.HTML")
  
))