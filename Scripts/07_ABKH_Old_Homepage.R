library(tidyverse)
library(rvest)

dfs <- list()


for(i in 1:5171) {
  
  printtext <- paste(i, "Abkhazia | Old Information", sep = ": ")
  print(printtext)
  
  scrape_url <- paste0("http://old.mfaapsny.org/en/information/index.php?ID=", i)
  
  webpage <- xml2::read_html(scrape_url) %>%
    rvest::html_node(".main_content")
  
  ERROR <- rvest::html_node(webpage, ".errortext") %>%
    html_text()
  
  if(is.na(ERROR)) {
    
    news_dates <- rvest::html_nodes(webpage, ".news-date-time") %>%
      html_text()
    
    if(is_empty(news_dates)) {
      news_dates <- NA
    }
    
    news_titles <- rvest::html_nodes(webpage, "h3") %>%
      html_text()
    
    dfs[[i]] <- do.call(rbind, Map(data.frame,
                                   State = "Abkhazia",
                                   Date_of_Scraping = Sys.Date(),
                                   URL = scrape_url,
                                   News_type = "Old Homepage",
                                   News_Dates = news_dates,
                                   News_Titles = news_titles,
                                   News_Shorts = NA
    ))
    
  } else {
    
    dfs[[i]] <- do.call(rbind, Map(data.frame,
                                   State = "Abkhazia",
                                   Date_of_Scraping = Sys.Date(),
                                   URL = scrape_url,
                                   News_type = "Old Homepage",
                                   News_Dates = NA,
                                   News_Titles = NA,
                                   News_Shorts = NA
    ))
    
  }
  
  Sys.sleep(0.4)
}

DF <- dplyr::bind_rows(dfs)
rownames(DF) <- NULL

# remove empty rows
completeFun <- function(data, desiredCols) {
  completeVec <- complete.cases(data[, desiredCols])
  return(data[completeVec, ])
}
DF <- completeFun(DF, c("News_Dates", "News_Titles"))

readr::write_csv(DF, "07_ABKH_Old_Homepage.csv")
