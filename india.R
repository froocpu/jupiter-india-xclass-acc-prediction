library(rvest) # install.packages(c("selectr", "rvest","xml2","httr","jsonlite"))
library(xml2) 
library(httr)
library(jsonlite)

# Set up script. ----------------------------------------------------------
source("src/utils.R")
source("src/tables.R")
write_out_prediction = TRUE

# Parse command line args. ------------------------------------------------
exchange = commandArgs()[length(commandArgs())]

if (!(exchange %in% c("bse","nse"))){
  exchange = "bse"
}
cat(sprintf("Using exchange: %s", exchange), "\n")

# Get tables. --------------------------------------------------------------
jup_url = "https://www.hl.co.uk/funds/fund-discounts,-prices--and--factsheets/search-results/j/jupiter-india-class-x-accumulation"
jup_equities_url = "https://www.hl.co.uk/funds/fund-discounts,-prices--and--factsheets/search-results/j/jupiter-india-class-x-accumulation/fund-analysis"

jupiter_top_holdings = ufn_get_holdings_table(jup_url)
jupiter_equities = ufn_get_equities_table(jup_equities_url)
  
# Get percentage changes. --------------------------------------------------
urls = list(
  hindustan = ufn_parse_url("refineries/hindustanpetroleumcorporation/HPC"),
  biocon = ufn_parse_url("pharmaceuticals/biocon/BL03"),
  godfrey = ufn_parse_url("cigarettes/godfreyphillipsindia/GPI"),
  state_bank = ufn_parse_url("banks-public-sector/statebankindia/SBI"),
  fortis = ufn_parse_url("hospitals-medical-services/fortishealthcare/FH"),
  gillette = ufn_parse_url("personal-care/gilletteindia/GI22"),
  interglobe_aviation = ufn_parse_url("transport-logistics/interglobeaviation/IA04"),
  hdfc_bank = ufn_parse_url("finance-housing/housingdevelopmentfinancecorporation/HDF"),
  nestle = ufn_parse_url("food-processing/nestleindia/NI"),
  icici = ufn_parse_url("banks-private-sector/icicibank/ICI02")
)

# Calculate scores and append the index. ----------------------------------
jupiter_top_holdings$todays_perc_change <- sapply(urls, function(url){
  return(ufn_scrape_perc(url, exchange))
})

index_row = data.frame(
  security = "BSE30",
  weight = 100-sum(jupiter_top_holdings$weight),
  todays_perc_change = ufn_get_perc_change_bse30()
)

jupiter_top_holdings = rbind(jupiter_top_holdings, index_row)

# Calculate weighted average. ----------------------------------------------
prediction = weighted.mean(jupiter_top_holdings$todays_perc_change, jupiter_top_holdings$weight)
cat("\n", sprintf("Today's Jupiter India Index prediction: %s percent change.", 
              round(prediction, 3)), "\n")

# View the tables. ---------------------------------------------------------
print(jupiter_top_holdings)

# Write a prediction. -----------------------------------------------------
predictions_fn = "data/predictions.csv"
today = as.character(Sys.Date())

predictions = if(file.exists(predictions_fn)){
  predictions = read.csv(predictions_fn)
} else {
  predictions = data.frame(predicted_date=c(), 
                           predicted_perc_change=c(),
                           using_exchange=c(),
                           actual_perc_change=c(),
                           actual_date=c())
}
actual = ufn_get_actual_change()
if(actual$ts %in% predictions$actual_date || today %in% predictions$predicted_date) {
  stop(sprintf("Prediction already in %s", predictions_fn))
} else {

  this_row = data.frame(
    predicted_date=today, 
    predicted_perc_change=prediction,
    using_exchange=exchange,
    actual_perc_change=actual$val,
    actual_date=actual$ts
  )
  
  write.csv(rbind(prediction, this_row), 
            predictions_fn,
            row.names = FALSE)
}



