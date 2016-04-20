library(shiny)
library(dplyr)
library(ggplot2)

freq.table<-readRDS(file="freq.tableB.RDS")

####### CONSTANTs ######### 
TOP_RANK <- 5
MAX_NGRAM <- 4
####### functions #########
clean_input <- function(txt_input) {
    sens <- unlist(stringr::str_split(txt_input, "[.!?]"))
    # choose the last sentence
    sens <- sens[length(sens)]
    
    # preprocess the text input the same way as with training text
    stringr::str_trim(sens)
    sens<- tolower(sens)
    sens <- gsub("’", "'", sens)
    sens <- gsub("[^[:alnum:][:space:]\']", " ", sens)
    sens<-iconv(sens, "latin1", "ASCII", sub="_0_")
    sens <- gsub("\\w*[0-9]\\w*"," ", sens)
    sens <- gsub(" www(.+) ", " ", sens)
    sens <- gsub("\\s+[b-hj-z]\\s+"," ", sens)
    #sens <- paste(sens, collapse = " 0EOS0 ")
    sens <- gsub("\\s+", " ", sens)
    sens <- stringr::str_trim(sens)
    
    # if "", return the tag indicating the end of the sentence
    # otherwise, return the last incomplete sentence
    if(sens=="") 
        return("0EOS0")
    else 
        return(sens)
}

predict_sbf <- function(freq.table, typed_context, n_pred=3) {
    stopifnot(n_pred<=TOP_RANK & n_pred>0)
    require(dplyr)
    
    capitalize_prediction <- FALSE
    typed_context <- clean_input(typed_context)
    
    typed_context <- get_last_n_words(typed_context, n=MAX_NGRAM-1)
    # treat empty string and space as end of sentence tag 0EOS0
    if (typed_context==""|typed_context==" ") {
        typed_context<-"0EOS0"
    }
    nGramToStartSearch <- nWords(typed_context)+1
    # the predicted words, based on contexts ending with end of sentence 
    # tag 0EOS0, will be capitalized.
    if (get_last_word(typed_context) == "0EOS0")
        capitalize_prediction <- TRUE
    
    # find all possible search context terms, including "" empty string
    searchTerms <- sapply((nGramToStartSearch-1):1, function(i) {
        get_last_n_words(typed_context, i)
    })
    searchTerms <- c(searchTerms, "") # seach 1-gram
    
    finalResult<-freq.table %>% 
        filter(as.character(context) %in% searchTerms)
    
    finalResult <-
        finalResult %>% 
        select(predicted, freq, ngram, everything()) %>% 
        mutate(predicted = as.character(predicted)) %>%
        mutate(freq=as.numeric(as.character(freq))) %>%
        mutate(ngram=as.integer(as.character(ngram))) %>%
        mutate( freq = freq * ((0.40)^(nGramToStartSearch-ngram)) ) %>%
        arrange(desc(ngram), desc(freq) ) %>%
        distinct(predicted)
    
    # set the # of predictions to return
    #n_pred <- ifelse (nrow(finalResult)<n_pred, nrow(finalResult), n_pred)
    if (nrow(finalResult)>n_pred) {
        finalResult <- finalResult[1:n_pred,]
    } 
    
    # if the prediction is 0EOS0, then change it to "." 
    finalResult$predicted[finalResult$predicted=="0EOS0"] <- "."
    finalResult$predicted[finalResult$predicted=="i"] <- "I"
    
    # if the context ends with 0EOS0, then captalize all predictions
    if(capitalize_prediction) {
        finalResult$predicted <- stringi::stri_trans_totitle(finalResult$predicted)
        #finalResult$predicted <- Hmisc::capitalize(finalResult$predicted)
    }
    
    finalResult
}

random_from <- function(words) {
    words[sample(length(words), 1)]
}


get_last_word <- function(s, sep=" ") {
    #stringr::word(s, -1)
    get_last_n_words(s, n=1L, sep = sep)
}

get_last_n_words <- function(s, n, sep=" ") {
    #stringr::word(s, (-1)*n, -1)
    stopifnot(n>=1)
    words <- unlist(strsplit(s, split = sep))
    len<-length(words)
    if (len<=n)
        return(paste(words, collapse = sep))
    paste(words[-(1:(len-n))], collapse = sep)
}

get_first_n_words <- function(s, n, sep=" ") {
    #stringr::word(s, 1, n)
    stopifnot(n>=1)
    #stopifnot(nchar(s)>0)
    words <- unlist(strsplit(s, split = sep))
    len<-length(words)
    if(len<n) 
        return(paste(words, collapse = sep))
    paste(words[1:n], collapse = sep)
}

nWords <- function(s, sep=" ") {
    #qdap::wc(s)
    #stringr::str_count(s, "\\S+")
    #stringr::str_count(s,"[[:alpha:]]+") 
    s<-as.character(s)
    n=0
    if (nchar(s)!=0) { 
        n=length(unlist( strsplit(s, split = sep)  )) 
    }
    n
}