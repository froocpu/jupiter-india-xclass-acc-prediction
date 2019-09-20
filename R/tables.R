ufn_get_holdings_table = function(url){
  tbl = xml2::read_html(url) %>%
    rvest::html_node(xpath = '//*[@id="top-holdings"]/table[1]') %>%
    rvest::html_table()
  tbl[2] = sapply(tbl[2], ufn_clean_weight)
  return(setNames(tbl, c("security", "weight")))
}

ufn_get_equities_table = function(url, jth){
  tbl = xml2::read_html(url) %>%
    rvest::html_node(xpath = '//*[@id="dual-aspect"]/div/table') %>%
    rvest::html_table()
  col_inds = 2:length(tbl)
  tbl[col_inds] = lapply(tbl[col_inds], ufn_clean_weight)
  tbl[2] = ufn_clean_weight(jth$Weight_raw)
  return(tbl)
}
