library(tidyverse)
library(rvest)

url <- "http://www.mfa-rso.su/en/node"
webpage <- xml2::read_html(url) %>%
  rvest::html_node("#main")

page_nr <- rvest::html_node(webpage, ".pager-last > a:nth-child(1)") %>%
  html_attr("href")
page_nr <- stringr::str_extract(page_nr, "(?<=page=).*") %>%
  as.numeric()
page_nr <- page_nr + 1

dfs <- list()

Sys.sleep(5)

for(i in 1:page_nr) {
  
  printtext <- paste(i, "South Ossetia | Homepage", sep = ": ")
  print(printtext)
  
  ii = i-0
  
  scrape_url <- paste0("http://www.mfa-rso.su/en/node?page=", ii)
  
  webpage <- xml2::read_html(scrape_url) %>%
    rvest::html_node("#main")
  
  news_dates <- rvest::html_nodes(webpage, "div.submitted") %>%
    html_text()
  
  news_titles <- rvest::html_nodes(webpage, "h1") %>%
    html_text()
  
  news_shorts <- rvest::html_nodes(webpage, "div.content") %>%
    html_text()
  
  dfs[[i]] <- do.call(rbind, Map(data.frame,
                                 State = "South Ossetia",
                                 Date_of_Scraping = Sys.Date(),
                                 URL = scrape_url,
                                 News_type = "Homepage",
                                 News_Dates = news_dates,
                                 News_Titles = news_titles,
                                 News_Shorts = news_shorts
  ))
  
  Sys.sleep(1)
}

DF <- dplyr::bind_rows(dfs)
rownames(DF) <- NULL

readr::write_csv(DF, "08_SOSSET_Webpage.csv")
