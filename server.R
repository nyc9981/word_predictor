library(shinydashboard)

function(input, output, session){
    # Make predictions
    result <- reactive ({
        #cat(input$nPred, file=stderr())
        predict_sbf(freq.table, input$text)[1:input$nPred,]
    })
    
    # Generate a bar plot about probabilities for each predicted words
    output$plot <- renderPlot({
        ggplot(result(), aes(predicted, freq)) + 
            geom_bar(stat="identity", fill="grey") + 
            scale_x_discrete(limits= result()$predicted) +
            #ggtitle("Probabilities Of The Predicted Words") + 
            xlab("Predicted Word") + 
            ylab("Probability") +             
            coord_flip() +
            theme_bw() +
            theme(plot.title = element_text(size=22)) +
            theme(axis.text.y=element_blank(),
                  axis.text=element_text(size=12),
                  axis.title=element_text(size=14,face="bold")) +
            geom_text(aes(label=predicted), hjust="inward", color="blue", size=7)  
    })
    
    # Prepare predicted words to make buttons
    sepWords <- reactive( { 
        if(length(result()$predicted)<5) {
            c(result()$predicted, rep("", 5-length(result()$predicted)))
        } else { result()$predicted 
        } 
    })
    
    # Generate dynamicly a button-group based on predicted words
    output$buttons <- renderUI( {
        div(class="btn-group btn-group-justified",
            actionLink(inputId = "action1", class="btn btn-default", label = sepWords()[1]),
            actionLink(inputId = "action2", class="btn btn-default", label = sepWords()[2]),
            actionLink(inputId = "action3", class="btn btn-default", label = sepWords()[3]),
            actionLink(inputId = "action4", class="btn btn-default", label = sepWords()[4]),
            actionLink(inputId = "action5", class="btn btn-default", label = sepWords()[5])
        )
    })
    
    # Generate updated text when one of the predicted words is clicked, or
    # random choice button is clicked
    my_clicks <- reactiveValues(data = NULL)
    
    observeEvent(input$action1, {
        my_clicks$data <- paste(input$text, sepWords()[1])
    })
    
    observeEvent(input$action2, {
        my_clicks$data <- paste(input$text, sepWords()[2])
    })
    
    observeEvent(input$action3, {
        my_clicks$data <- paste(input$text, sepWords()[3])
    })
    
    observeEvent(input$action4, {
        my_clicks$data <- paste(input$text, sepWords()[4])
    })
    
    observeEvent(input$action5, {
        my_clicks$data <- paste(input$text, sepWords()[5])
    })
    
    observeEvent(input$randomChoice, {
        my_clicks$data <- paste(input$text, random_from(result()$predicted))
    })
    
    # Update the text area with updated text
    observe({
        #x <- input$controller
        updateTextInput(session, "text",
                        value = stringr::str_trim(my_clicks$data))
    })
    
} 
