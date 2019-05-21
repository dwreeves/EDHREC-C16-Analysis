/*~ 01 - Import data.do ~*/

/*******************************************************************************
* 01a. Import and prepare EDHREC Data
*******************************************************************************/

/* Import individual files */
foreach cmdr in $COMMANDERS {
	import delimited "${RAW_DIR}/`cmdr'.csv", delimiter("|") clear
	rename v2 card
	gen commander = "`cmdr'"
	save "${DATA_DIR}/edhrec/`cmdr'.dta", replace
}
clear

/* Combine */
foreach cmdr in $COMMANDERS {
	append using "${DATA_DIR}/edhrec/`cmdr'.dta"
}

/* Trim down deck link, then encode */
replace v1 = trim(substr(v1,strlen("http://tappedout.net/mtg-decks/")+1,.))
compress v1
encode v1, gen(deck)
drop v1

/* Observe whether a deck has COB or MC */
sort deck card
by deck: gen byte firstobs_deck = _n==1
by deck: egen byte has_cobrass = max(card=="City of Brass")
by deck: egen byte has_mconflu = max(card=="Mana Confluence")
gen byte has_either = has_cobrass | has_mconflu
gen byte has_both = has_cobrass & has_mconflu

/* Save */
order deck commander card
save "${DECKS_DTA}", replace

/*******************************************************************************
* 01b. Import Price Data
*******************************************************************************/

import excel "${CARD_PRICES_RAW}", sheet("Sheet1") firstrow clear

/* Consistent names for merge */
rename CardName card
rename FairTradePrice price

/* Drop unnecessary data */
drop BestBuylistPrice
replace card=substr(card,1,strlen(card)-4) if match(card,"*(?)")
drop if inlist(card,"Swamp","Forest","Mountain","Island","Plains")
drop if price==0

/* Lowest price */
sort card price
by card : gen lowestprice = _n==1
drop if !lowestprice
drop lowestprice

/* Save */
save "${CARD_PRICES_DTA}", replace

/*******************************************************************************
* 01c. Import Precon Deck Lists
*******************************************************************************/

/* These were imported manually and saved as .dta's in /data/precons from
   magic.wizards.com . An example is provided for Yidris if cleaning the lists
   up in the Stata console:
*/

*drop if !inlist(substr(var1,1,1),"1","3","4","5","7")
*replace var1 = substr(var1,3,.)
*gen commander = "yidris"
*rename var1 card
*save precon_yidris.dta, replace
