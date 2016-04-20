library(shinydashboard)

header <- dashboardHeader(
    title = "Next Word Predictor"
)

#sidebar <- dashboardSidebar(disable = TRUE)
sidebar <- dashboardSidebar(
    disable = FALSE,
    sidebarMenu(
        menuItem("Predictor", tabName = "home", icon = icon("pencil")),
        menuItem("Help", tabName = "help", icon = icon("question")),
        menuItem("About", tabName = "about", icon = icon("info")),
        menuItem("Source code", icon = icon("file-code-o"), 
                  href = "https://github.com/nyc9981/word_predictor")
    )
)

body <- dashboardBody(
    # tags$head(
    #     tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.min.css")
    # ),
    tabItems(
        tabItem(tabName = "home",
                fluidRow(
                    column(width = 7,
                           box(width = NULL, #solidHeader = TRUE,
                               status = "warning",
                               h4(strong("Type here")),
                               tags$textarea(id="text", rows=6, cols=70,autofocus=TRUE, placeholder="Type here")
                           ),
                           box(width = NULL, status = "success",
                               h4(strong("Predicted words")),
                               uiOutput("buttons")
                           ),
                           p(
                               #class = "text-primary",
                               paste("Click one of the above predicted words if you wish, ",
                                     "or choose one randomly by clicking the Random Choice button below."
                               )
                           ),
                           box(width = 4, solidHeader = TRUE,
                               actionButton("randomChoice", class="btn btn-default", "Random Choice")
                           )
                    ),
                    column(width = 5,
                           box(width = NULL, status = "warning",
                               h4(strong("Number of Predictions")),
                               selectInput("nPred", NULL, 1:5, selected = 3, width="50%"),
                               p(
                                   class = "text-muted",
                                   paste("Note: maximum 5 predicted words are allowed.",
                                         ""
                                   ),
                                   br(),
                                   br(),
                                   #br(),
                                   br()
                               )
                           ),
                           box(width = NULL, status = "success",
                               h4(strong("Probabilities of the predicted words"), align="center"),
                               plotOutput("plot")
                           )
                    )
                )
        ),
        tabItem(tabName = "help",
                h2("How to use the app"),
                p("You type the text in the text area.  As you type, the predicted next words immediately appear below the text area in the descending order of their probabilities according to the prediction model.  The app also dynamicly generates a plot about the probabilities for all the predicted words."),
                #br(),
                p("You could continue to type, or click one of the predicted words and the clicked word will then be inserted in to the text area.  You can also click the button Random Choice to insert a randomly chosen word from the list of predicted words.  The new predictions are made continuously based on the updated text with newly typed words, or inserted words if you clicked one of the predicted words."),
                p("Just for fun, you can keep clicking the Random Choice button to generate complete sentences."),
                h3("Option"),
                p("The number of predictions is set to 3 as default. You could change it to any number from 1 to 5 before or during typing in the text area. ")
        ),
        tabItem(tabName = "about",
                h2("About this Shiny app"),
                p("This Shiny app is developed as a capstone project to complete Coursera Data Science Specialization offered by John Hopkins University in collaboration with Swiftkey. The goals are to build a predictive text model (like those used by SwiftKey) from unstructured text documents and then to develop it into a Shiny app for end users. "),
                #br(),
                p("The predictive model is built from the text corpora (a body of texts) provided by Coursera. It uses a simple Stupid Backoff algorithm."),
                p("The source code of this app is available at", tags$a("GitHub", href="https://github.com/nyc9981/word_predictor"), ".")
        )
    )
    
)

dashboardPage(
    header,
    sidebar,
    body
    #skin = "black"
)

