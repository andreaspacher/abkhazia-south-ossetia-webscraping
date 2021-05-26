library(tidyverse)
library(rvest)

url <- "http://mfaapsny.org/en/allnews/news/embassies/"
webpage <- xml2::read_html(url) %>%
  rvest::html_node("#content")

page_nr <- rvest::html_node(webpage, ".nav-title") %>%
  html_text()
page_nr <- stringr::str_extract(page_nr, "(?<=of ).*") %>%
  as.numeric()
page_nr <- ceiling(page_nr / 10)

dfs <- list()

Sys.sleep(5)

for(i in 1:page_nr) {
  
  printtext <- paste(i, "Abkhazia | Embassy News", sep = ": ")
  print(printtext)
  
  scrape_url <- paste0("http://mfaapsny.org/en/allnews/news/embassies/?PAGEN_1=", i)
  
  webpage <- xml2::read_html(scrape_url) %>%
    rvest::html_node("#content")
  
  news_dates <- rvest::html_nodes(webpage, "span.date") %>%
    html_text()
  
  news_titles <- rvest::html_nodes(webpage, "h2") %>%
    html_text()
  
  news_shorts <- rvest::html_nodes(webpage, "div.text") %>%
    html_text()
  
  dfs[[i]] <- do.call(rbind, Map(data.frame,
                                 State = "Abkhazia",
                                 Date_of_Scraping = Sys.Date(),
                                 URL = scrape_url,
                                 News_type = "Embassy News",
                                 News_Dates = news_dates,
                                 News_Titles = news_titles,
                                 News_Shorts = news_shorts
  ))
  
  Sys.sleep(5)
}

DF <- dplyr::bind_rows(dfs)
rownames(DF) <- NULL

readr::write_csv(DF, "06_ABKH_Embassy.csv")
