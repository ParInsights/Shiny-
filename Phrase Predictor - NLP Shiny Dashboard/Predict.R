
suppressWarnings(library(quanteda))
suppressWarnings(library(data.table))

# Load frequency tables into memory

Unigrams   <-readRDS(file="./data/UnigramsTop20.rds")
Bigrams   <-readRDS(file="./data/Bigrams.rds")
Trigrams  <-readRDS(file="./data/Trigrams.rds")
Quadgrams <-readRDS(file="./data/Quadgrams.rds")
Quintgrams <-readRDS(file="./data/Quintgrams.rds")


cleanWord<- function(inputText) {
  
  corpus <- corpus(inputText)
  ## Use same cleaning as in the preparation
  tokens <-tokens(corpus, remove_numbers = TRUE, remove_punct = TRUE,
                remove_symbols = TRUE, remove_separators = TRUE,
                remove_twitter = TRUE, remove_hyphens = TRUE, remove_url = TRUE)  
  # convert to lower case
  tokens <- tokens_tolower(tokens)
  tokens <- tokens$text1
  rm(corpus)  
  #
  return(tokens)
}
  

predictWord <- function(inputText,k=3){
  
  ## Read the inout
  tokens<-cleanWord(inputText)

  # Determine token length
  tokensLength <- length(tokens)
  
  # initialise empty data frame, initialize variables
  results <- data.table(predicted=character(),score=numeric())
  alpha<-0.4
  backoff<-0
  reqPred<-k+3
  runPred<-0
  
  #  get predictions for K+3 in case of duplicated across Ngrams 
  ## Seach 5grams for last 4-word sequence to predict 5th word
  if ((tokensLength > 3) & (runPred<reqPred)) {
    searchString <- paste(tail(tokens,4), collapse=' ')
    numMatched <- Quintgrams[searchString,.N,nomatch=0]
    if (numMatched>0) { 
       numMatched<-pmin(reqPred-runPred,numMatched)
       matches <- Quintgrams[searchString,.(predicted,score),nomatch=0][order(-score)][1:numMatched]
       matches[,score:=(alpha^backoff)*score]
       results <- rbind(results,matches)
       runPred<-runPred+numMatched
    }
    backoff<-backoff+1
  }
  
  ## Seach 4grams for last 3-word sequence or backoff from above
  if ((tokensLength > 2) & (runPred<reqPred)){
    searchString <- paste(tail(tokens,3), collapse=' ')
    numMatched <- Quadgrams[searchString,.N,nomatch=0]
    if (numMatched>0) { 
      numMatched<-pmin(reqPred-runPred,numMatched)
      matches <- Quadgrams[searchString,.(predicted,score),nomatch=0][order(-score)][1:numMatched]
      matches[,score:=(alpha^backoff)*score]
      results <- rbind(results,matches)
      runPred<-runPred+numMatched
    }
    backoff<-backoff+1
  }
  
  ## Seach 3grams for last 2-word sequence or backoff from above
  if ((tokensLength > 1) & (runPred<reqPred)){
    searchString <- paste(tail(tokens,2), collapse=' ')
    numMatched <- Trigrams[searchString,.N,nomatch=0]
    if (numMatched>0) { 
      numMatched<-pmin(reqPred-runPred,numMatched)
      matches <- Trigrams[searchString,.(predicted,score),nomatch=0][order(-score)][1:numMatched]
      matches[,score:=(alpha^backoff)*score]
      results <- rbind(results,matches)
      runPred<-runPred+numMatched
    }
    backoff<-backoff+1
  }
  
  ## Seach 2grams for last 1-word sequence or backoff from above
  if ((tokensLength > 0) & (runPred<reqPred)){
    searchString <- tail(tokens,1)
    numMatched <- Bigrams[searchString,.N,nomatch=0]
    if (numMatched>0) { 
      numMatched<-pmin(reqPred-runPred,numMatched)
      matches <- Bigrams[searchString,.(predicted,score),nomatch=0][order(-score)][1:numMatched]
      matches[,score:=(alpha^backoff)*score]
      results <- rbind(results,matches)
      runPred<-runPred+numMatched
    }
    backoff<-backoff+1
  }

  ## Still no/not enough results? return/add top unigram words 
  if (runPred<reqPred){
    numMatched<-(reqPred-runPred)
    matches <- Unigrams[][order(-score)][1:numMatched]
    matches[,score:=(alpha^backoff)*score]
    results <- rbind(results,matches)
  }
  
  ## Take the top words, remove duplicates
  results<- unique(results, by="predicted")  
  results<- head(results,k)

  return(results)
  
}



