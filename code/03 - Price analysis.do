/*~ 03 - Price Analysis.do ~*/

/*******************************************************************************
** 03a. Prepare data
*******************************************************************************/

use "${DECKS_DTA}", clear
merge m:1 card using "${CARD_PRICES_DTA}", gen(_merge_price) keep(1 3)

/* Price of deck */
bysort deck: egen double totalprice = total(price)
gen double logprice = log(totalprice)/log(10)

/*******************************************************************************
** 03b. Analysis
*******************************************************************************/

/* Commander specific summary stats */
sum totalprice if firstobs_deck & commander=="atraxa", detail
sum totalprice if firstobs_deck & commander=="breya", detail
sum totalprice if firstobs_deck & commander=="kynaios", detail
sum totalprice if firstobs_deck & commander=="saskia", detail
sum totalprice if firstobs_deck & commander=="yidris", detail

/* Estimated probabilities of having either or both */
probit has_either logprice if firstobs_deck
predict est_has_either

probit has_both logprice if firstobs_deck
predict est_has_both

/*******************************************************************************
** 03c. Figures
*******************************************************************************/

tempvar cmdr_proper
gen `cmdr_proper' = proper(commander)

local source "Source: EDHREC.com, TappedOut.net, " ///
	"MTGPrice.com, and author's calculations"

#delimit ;

histogram
	totalprice if firstobs_deck & totalprice<=1000, by(commander) 
	by(
		commander,
		note("`source'")
		graphregion(color(gs15))
		title("Distribution of Decklist Prices (Excluding >$1,000)")
		subtitle("for C16 Commanders")
		total
	)
	bgcolor(gs15) subtitle(, bcolor(gs11))
	xtitle("Total Deck Price" " ")
	color(gs11)
;

graph export "${OUTPUT_DIR}/analysis_price_dist.png", replace;

sort est_has_both;
twoway
	(line est_has_either logprice if firstobs_deck,
		color(blue)
	)
	(line est_has_both logprice if firstobs_deck,
		color(red)
	),
	title("Probability of Having City of Brass and/or Mana Confluence")
	subtitle("as a Function of Total Deck Price")
	xtitle("Price of deck (log scale)") ///
	legend(
		label(1 "Has either")
		label(2 "Has both")
		order(2 3 1)
	) ///
	xlabel(1.5 "$32" 2 "$100" 2.5 "$316" 3 "$1,000" 3.5 "$3,162")
	ylabel(0 "0%" .2 "20%" .4 "40%" .6 "60%" .8 "80%" 1 "100%")
	graphregion(color(gs15))
	note("`source'")
;
	
graph export "${OUTPUT_DIR}/analysis_price_function.png", replace;

#delimit cr
