library(rvest) # install.packages(c("selectr", "rvest","xml2","httr","jsonlite"))
library(xml2) 
library(httr)
library(jsonlite)

# Set up script. ----------------------------------------------------------
source("src/functions.R")
exchange = commandArgs()[length(commandArgs())]

if (!(exchange %in% c("bse","nse"))){
  exchange = "bse"
}
cat(sprintf("Using exchange: %s", exchange))

# Get table. ---------------------------------------------------------------
jup_url = "https://www.hl.co.uk/funds/fund-discounts,-prices--and--factsheets/search-results/j/jupiter-india-class-x-accumulation"

jupiter_top_holdings = xml2::read_html(jup_url) %>%
  rvest::html_node(xpath = '//*[@id="top-holdings"]/table[1]') %>%
  rvest::html_table()

names(jupiter_top_holdings) = c("Security", "Weight_raw")

# Clean table. -------------------------------------------------------------
jupiter_top_holdings$Weight = ufn_clean_weight(jupiter_top_holdings$Weight_raw)

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
jupiter_top_holdings$todays_perc_change <- sapply(urls, function(i){
  ufn_scrape_perc(i, )})

index_row = data.frame(
  Security = "BSE30",
  Weight_raw = NA,
  Weight = 100-sum(jupiter_top_holdings$Weight),
  todays_perc_change = ufn_get_perc_change_bse30()
)

jupiter_top_holdings = rbind(jupiter_top_holdings, index_row)

# Calculate weighted average. ----------------------------------------------
prediction = sum(jupiter_top_holdings$Weight * jupiter_top_holdings$todays_perc_change)/nrow(jupiter_top_holdings)
print(sprintf("Today's Jupiter India Index prediction: %s percent change.", round(prediction, 3)))

# View the table. ----------------------------------------------------------
print(jupiter_top_holdings)


