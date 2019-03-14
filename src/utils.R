# Define some functions. --------------------------------------------------
ufn_clean_weight = function(w){
  return(as.numeric(trimws(gsub("%", "", w))))
}

ufn_scrape_perc = function(url, exchange="nse"){
  cat(sprintf("Pulling %s data from: %s", exchange, url), "\n")
  x = xml2::read_html(url)
  xpath = ifelse(exchange=="nse", '//*[@id="n_changetext"]', '//*[@id="b_changetext"]')
  txt = rvest::html_node(x=x, xpath=xpath) %>%
    rvest::html_text()
  extract_val = gsub("[\\(\\)]", "", regmatches(txt, gregexpr("\\(.*?\\)", txt))[[1]])
  remove_perc = gsub("%", "", extract_val)
  num_char = ifelse(substring(remove_perc, 1, 1) == "+", gsub("\\+", "", remove_perc), remove_perc)
  return(as.numeric(num_char))
}

ufn_get_perc_change_bse30 = function(){
  url = "https://priceapi-aws.moneycontrol.com/pricefeed/notapplicable/inidicesindia/in%3BSEN"
  val = fromJSON(content(GET(url), as = "text"))$data$pricepercentchange
  return(as.numeric(val))
}

ufn_get_perc_change_bse100 = function(){
  url = "http://www.asiaindex.co.in/indices/equity/sp-bse-100"
  xpath = '//*[@id="main-content"]/div[3]/div[2]/div/ul/li[1]/div[2]/div[2]/div[1]/div[3]'
  val = xml2::read_html(url) %>%
    html_node(xpath=xpath) %>%
    html_text()
  return(ufn_clean_weight(gsub("▼", "", val)))
}

ufn_parse_url = function(endpoint){
  return(sprintf("https://www.moneycontrol.com/india/stockpricequote/%s", endpoint))
}