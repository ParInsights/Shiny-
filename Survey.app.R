library(shiny)

# which fields get saved 
fieldsAll <- c("name", "favourite_pkg", "used_shiny", "r_num_years", "os_type")

# which fields are mandatory
fieldsMandatory <- c("name", "favourite_pkg")

# add an asterisk to an input label
labelMandatory <- function(label) {
    tagList(
        label,
        span("*", class = "mandatory_star")
    )
}

# get current Epoch time
epochTime <- function() {
    return(as.integer(Sys.time()))
}

# get a formatted string of the timestamp (exclude colons as they are invalid
# characters in Windows filenames)
humanTime <- function() {
    format(Sys.time(), "%Y%m%d-%H%M%OS")
}

# save the results to a file
saveData <- function(data) {
    fileName <- sprintf("%s_%s.csv",
                        humanTime(),
                        digest::digest(data))
    
    write.csv(x = data, file = file.path("Users/parinppatel/Documents/Shiny/Survey1", "Responses"),
              row.names = FALSE, quote = TRUE)
}

# load all responses into a data.frame
loadData <- function() {
    files <- list.files(file.path(responsesDir), full.names = TRUE)
    data <- lapply(files, read.csv, stringsAsFactors = FALSE)
    #data <- dplyr::rbind_all(data)
    data <- do.call(rbind, data)
    data
}

# directory where responses get stored
responsesDir <- file.path("Users/parinppatel/Documents/Shiny/Survey1")

# CSS to use in the app
appCSS <-
    ".mandatory_star { color: red; }
   .shiny-input-container { margin-top: 25px; }
   #submit_msg { margin-left: 15px; }
   #error { color: red; }
   body { background: #fcfcfc; }
   #header { background: #fff; border-bottom: 1px solid #ddd; margin: -20px -15px 0; padding: 15px 15px 10px; }
  "

############################ui
shinyApp(
    ui = fluidPage(
        DT::dataTableOutput("responses", width = 300), tags$hr(),
        shinyjs::useShinyjs(),
        shinyjs::inlineCSS(appCSS),
        title = "Mimicking a Google Form with a Shiny app",
            
        fluidRow(
            column(6,
                   div(
                       id = "form",
                       textInput("name", labelMandatory("Name"), ""),
                       textInput("favourite_pkg", labelMandatory("Favourite R package")),
                       checkboxInput("used_shiny", "I've built a Shiny app in R before", FALSE),
                       sliderInput("r_num_years", "Number of years using R", 0, 25, 2, ticks = FALSE),
                       selectInput("os_type", "Operating system used most frequently",
                                   c("",  "Windows", "Mac", "Linux")),
                       actionButton("submit", "Submit", class = "btn-primary"),
                       
                       shinyjs::hidden(
                           span(id = "submit_msg", "Submitting..."),
                           div(id = "error",
                               div(br(), tags$b("Error: "), span(id = "error_msg"))
                           )
                       )
                   ),
                   
                   shinyjs::hidden(
                       div(
                           id = "thankyou_msg",
                           h3("Thanks, your response was submitted successfully!"),
                           actionLink("submit_another", "Submit another response")
                       )
                   )
            ),
            column(6,
                   uiOutput("adminPanelContainer")
            )
        )
    ),
    ########server 
    server = function(input, output, session) {
        
        
    
        # Enable the Submit button when all mandatory fields are filled out
        observe({
            mandatoryFilled <-
                vapply(fieldsMandatory,
                       function(x) {
                           !is.null(input[[x]]) && input[[x]] != ""
                       },
                       logical(1))
            mandatoryFilled <- all(mandatoryFilled)
            
            shinyjs::toggleState(id = "submit", condition = mandatoryFilled)
        })
        
        # Gather all the form inputs (and add timestamp)
        formData <- reactive({
            data <- sapply(fieldsAll, function(x) input[[x]])
            data <- c(data, timestamp = epochTime())
            data <- t(data)
            data
        })    
        
        # When the Submit button is clicked, submit the response
        observeEvent(input$submit, {
            
            # User-experience stuff
            shinyjs::disable("submit")
            shinyjs::show("submit_msg")
            shinyjs::hide("error")
            
            # Save the data (show an error message in case of error)
            tryCatch({
                saveData(formData())
                shinyjs::reset("form")
                shinyjs::hide("form")
                shinyjs::show("thankyou_msg")
            },
            error = function(err) {
                shinyjs::html("error_msg", err$message)
                shinyjs::show(id = "error", anim = TRUE, animType = "fade")
            },
            finally = {
                shinyjs::enable("submit")
                shinyjs::hide("submit_msg")
            })
        })
        
        # submit another response
        observeEvent(input$submit_another, {
            shinyjs::show("form")
            shinyjs::hide("thankyou_msg")
        })
        
       
        # Show the responses in the admin table
        output$responsesTable <- DT::renderDataTable({
            data <- loadData()
            data$timestamp <- as.POSIXct(data$timestamp, origin="1970-01-01")
            DT::datatable(
                data,
                rownames = FALSE,
                options = list(searching = FALSE, lengthChange = FALSE)
            )
        })
        
        # Allow user to download responses
        output$downloadBtn <- downloadHandler(
            filename = function() { 
                sprintf("mimic-google-form_%s.csv", humanTime())
            },
            content = function(file) {
                write.csv(loadData(), file, row.names = FALSE)
            }
        )    
    }
)