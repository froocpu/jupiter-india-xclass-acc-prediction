ufn_clean_weight = function(w){
  return(as.numeric(trimws(gsub("%", "", w))))
}

ufn_extract_brackets = function(x){
  return(gsub("[\\(\\)]", "", regmatches(x, gregexpr("\\(.*?\\)", x))[[1]]))
}

ufn_parse_url = function(endpoint){
  return(sprintf("https://www.moneycontrol.com/india/stockpricequote/%s", endpoint))
}

