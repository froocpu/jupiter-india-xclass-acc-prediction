# Define some functions. --------------------------------------------------
ufn_clean_weight = function(w){
  return(as.numeric(trimws(gsub("%", "", w))))
}

ufn_extract_brackets = function(x){
  return(gsub("[\\(\\)]", "", regmatches(x, gregexpr("\\(.*?\\)", x))[[1]]))
}

ufn_scrape_perc = function(url, exchange="nse"){
  cat(sprintf("Pulling %s data from: %s", exchange, url), "\n")
  x = xml2::read_html(url)
  xpath = ifelse(exchange=="nse", '//*[@id="n_changetext"]', '//*[@id="b_changetext"]')
  txt = rvest::html_node(x=x, xpath=xpath) %>%
    rvest::html_text()
  extract_val = ufn_extract_brackets(txt)
  remove_perc = gsub("%", "", extract_val)
  num_char = ifelse(substring(remove_perc, 1, 1) == "+", gsub("\\+", "", remove_perc), remove_perc)
  return(as.numeric(num_char))
}

ufn_get_perc_change_bse30 = function(){
  url = "https://priceapi-aws.moneycontrol.com/pricefeed/notapplicable/inidicesindia/in%3BSEN"
  val = fromJSON(content(GET(url), as = "text"))$data$pricepercentchange
  return(as.numeric(val))
}

ufn_parse_url = function(endpoint){
  return(sprintf("https://www.moneycontrol.com/india/stockpricequote/%s", endpoint))
}

ufn_get_actual_change = function(){
  xpath_val = '//*[@id="security-price"]/div/div/div[1]/div/div[1]/div[1]/span[6]/span[3]'
  xpath_date = '//*[@id="security-price"]/div/div/div[1]/div/div[1]/div[2]/div'
  # Get page.
  url = "https://www.hl.co.uk/funds/fund-discounts,-prices--and--factsheets/search-results/j/jupiter-india-class-x-accumulation"
  html_page = xml2::read_html(url)
  # Extract percentage change and clean.
  txt = html_node(x=html_page, xpath=xpath_val) %>%
    html_text()
  val = as.numeric(ufn_clean_weight(ufn_extract_brackets(txt)))
  # Do the same for the date parsed.
  date_txt = html_node(x=html_page, xpath=xpath_date) %>%
    html_text()
  ts = gsub("Prices as at ", "", trimws(date_txt))
  # Return a list
  return(list(
    ts = ts,
    val = val
  ))
}

ufn_cat = function(msg, input){
  cat("\n", sprintf(msg, input), "\n")
}
