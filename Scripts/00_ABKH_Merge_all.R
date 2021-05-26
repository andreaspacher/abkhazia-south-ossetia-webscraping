all_abkh <- list.files(pattern = "*.csv") %>% 
  lapply(read_csv) %>% 
  bind_rows 

rownames(all_abkh) <- NULL

readr::write_csv(all_abkh, "00_ABKH_All.csv")
