library(rvest) # install.packages(c("selectr", "rvest","xml2","httr","jsonlite"))
library(xml2) 
library(httr)
library(jsonlite)

# Set up script. ----------------------------------------------------------
# TODO: make a library
source("R/get.R")
source("R/strings.R")
source("R/tables.R")
source("config.R")

# Parse command line args. ------------------------------------------------
main <- function(){
  if (!(config.exchange %in% c("bse","nse"))){
    config.exchange = "bse"
  }
  
  ufn_cat("Using exchange: %s", config.exchange)
  
  # Parse URLs. --------------------------------------------------------------
  base_url = "https://www.hl.co.uk/funds/fund-discounts,-prices--and--factsheets/search-results/j/"
  
  jup_url = paste0(base_url, "jupiter-india-class-x-accumulation")
  jup_china_url = paste0(base_url, "jupiter-china-class-i-accumulation")
  jup_equities_url = paste(jup_url, "fund-analysis", sep = "/")

  # Get tables. -------------------------------------------------------------
  jupiter_top_holdings = ufn_get_holdings_table(jup_url)
  jupiter_equities = ufn_get_equities_table(url=jup_equities_url, 
                                            jth=jupiter_top_holdings)
  
  # Get percentage changes. --------------------------------------------------
  urls = list(
    # India
    hindustan = ufn_parse_url("refineries/hindustanpetroleumcorporation/HPC"),
    godfrey = ufn_parse_url("cigarettes/godfreyphillipsindia/GPI"),
    interglobe_aviation = ufn_parse_url("transport-logistics/interglobeaviation/IA04"),
    biocon = ufn_parse_url("pharmaceuticals/biocon/BL03"),
    state_bank = ufn_parse_url("banks-public-sector/statebankindia/SBI"),
    bharat = ufn_parse_url("refineries/bharatpetroleumcorporation/BPC"),
    icici = ufn_parse_url("banks-private-sector/icicibank/ICI02"),
    hdfc_bank = ufn_parse_url("finance-housing/housingdevelopmentfinancecorporation/HDF"),
    gillette = ufn_parse_url("personal-care/gilletteindia/GI22"),
    fortis = ufn_parse_url("hospitals-medical-services/fortishealthcare/FH")
  )
  
  # Calculate scores and append the index. ----------------------------------
  jupiter_top_holdings$todays_perc_change = sapply(urls, function(url){
    return(ufn_scrape_perc(url, config.exchange))
  })
  
  index_row = data.frame(
    security = "BSE30",
    weight = 100-sum(jupiter_top_holdings$weight),
    todays_perc_change = ufn_get_perc_change_bse30()
  )
  
  jupiter_top_holdings = rbind(jupiter_top_holdings, index_row)
  
  # Calculate weighted average. ----------------------------------------------
  
  prediction = weighted.mean(jupiter_top_holdings$todays_perc_change, jupiter_top_holdings$weight)
  prediction_round = round(prediction, 3)
  
  ufn_cat("Today's Jupiter India Index prediction: %s percent change.", prediction_round)
  
  # View the tables. ---------------------------------------------------------
  print(jupiter_top_holdings) 
}

main()
