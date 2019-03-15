# Jupiter India Accumulation Fund Script

## What is this?
A simple and dirty script for pulling data about specific Indian stocks and indices.

## Why?
The [Jupiter India X Class Accumulation Fund](https://www.hl.co.uk/funds/fund-discounts,-prices--and--factsheets/search-results/j/jupiter-india-class-x-accumulation) updates once a day. Indian stocks can be quite volatile, so it'd be nice to know how much the fund's value **might** fluctuate throughout the day. This script scrapes data from various sources to make a rough estimate of what the day's percentage change might be.

## How?
- Scrape a table with fund metadata from the website linked above.
- Using a list of hard-coded URLs pointing to [www.moneycontrol.com](https://www.moneycontrol.com), scrape the percentage change value for the day.
- Scrape the BSE30 value for that day, and use that percentage change as an assumption for the rest of the portfolio (not listed in the top 10 holdings.)
- Use these assumptions to perform a weighted average and print a prediction for the percentage change for the day.

## Requirements
Install the following packages:
```r
install.packages(c("selectr", "rvest","xml2","httr","jsonlite"))
```

### Gotchas
- On Mac machines, `xml2` is required for the `read_html()` function and `rvest` is used for the other scraping functions. This is to avoid a weird error where R cannot find specific functions.
- `selectr` is required, but not specified.

## Examples

### Usage
Run from the command line to get prices from the BSE:

```sh
Rscript india.R
```

Or run with an input parameter of "bse" or "nse" to specify the exchange to get prices from:

```sh
Rscript india.R "bse"
```

### Output	
| Security | Weight_raw | Weight | todays_perc_change |
|---|---|---|---|
|Hindustan Petroleum|5.91%|5.91|-0.2600|
|Biocon|5.82%|5.82|-0.1700|
|Godfrey Phillips India|4.68%|4.68|1.5100|
|State Bank of India|3.13%|3.13|-0.4300|
|Fortis Healthcare|3.08%|3.08|-2.4400|
|Gillette India|3.08%|3.08|-0.1400|
|InterGlobe Aviation|2.95%|2.95|-0.1500|
|HDFC Bank|2.88%|2.88|0.3200|
|Nestle India|2.87%|2.87|0.1500|
|ICICI Bank|2.87%|2.87|-1.0200|
|BSE30|NA|62.73|0.0072|

## TODO
- [ ] Incorporate a dynamic way of querying a specific website based on ticker codes, rather than hard-coded URLs.
- [x] Use BSE100 instead of BSE30.
- [ ] Find an appropriate API instead of scraping.
- [ ] Incorporate other pieces of data from the HL website into the final prediction calculation (number of holdings, cash holdings, etc.)
- [x] Devise a better way of storing the results of multiple calls.
- [ ] Make script more configurable.
