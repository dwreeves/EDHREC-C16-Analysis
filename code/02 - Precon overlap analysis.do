/*~ 02 - Precon Overlap Analysis.do ~*/

/*******************************************************************************
** 02a. Prepare data
*******************************************************************************/

use "${DECKS_DTA}", clear

/* Merge with Precon Deck Lists */
gen in_precon = 0
foreach cmdr in $COMMANDERS {
	merge m:1 commander card ///
		using "${DATA_DIR}/precons/precon_`cmdr'.dta", ///
		gen(_merge_`cmdr')
	replace in_precon = 1 if commander=="`cmdr'" & _merge_`cmdr'==3
	drop _merge_`cmdr'
}

/* Measure Overlap */
sort deck card
by deck: egen int precon_overlap = total(in_precon)
gen int precon_diff = 100-precon_overlap

/*******************************************************************************
** 02b. Figures
*******************************************************************************/

/* Commander specific summary stats */
summ precon_diff if firstobs_deck & commander=="atraxa", detail
summ precon_diff if firstobs_deck & commander=="breya", detail
summ precon_diff if firstobs_deck & commander=="kynaios", detail
summ precon_diff if firstobs_deck & commander=="saskia", detail
summ precon_diff if firstobs_deck & commander=="yidris", detail

/* Commander specific probits */
foreach cmdr in $COMMANDERS {
	probit has_either precon_overlap if commander=="`cmdr'"
}

/* PDF of decks by how much they overlap with the precon */
bysort precon_overlap : egen totdecks = total(firstobs_deck)
count if firstobs_deck
replace totdecks = totdecks/`r(N)'

/* Actual and estimated probability of having either */
bysort precon_overlap : egen avg_has_either = mean(has_either)
probit has_either precon_overlap
predict est_has_either

/* Actual and estimated probability of having both */
bysort precon_overlap : egen avg_has_both = mean(has_both)
probit has_both precon_overlap
predict est_has_both

/*******************************************************************************
** 02c. Tables
*******************************************************************************/

tempvar cmdr_proper
gen `cmdr_proper' = proper(commander)

#delimit ;

histogram
	precon_overlap if firstobs_deck,
	by(`cmdr_proper',
		note("Source: EDHREC.com, TappedOut.net, and author's calculations")
		graphregion(color(gs15))
		title("Distribution of Decklist Overlaps with Precons")
		subtitle("for C16 Commanders")
		total
	)
	xtitle("Number of cards that overlap with precon" " ") 
	width(1)
	bgcolor(gs15)
	color(gs11)
	subtitle(, bcolor(gs11))
;
	
graph export "${OUTPUT_DIR}/analysis_precon_overlap.png", replace;

twoway
	(bar totdecks precon_overlap if firstobs_deck,
		yaxis(1) yscale(off alt) color(gs14)
	)
	(line est_has_either precon_overlap if firstobs_deck,
		yaxis(2) color(navy)
	)
	(line est_has_both precon_overlap if firstobs_deck,
		yaxis(2) color(maroon)
	)
	(scatter avg_has_either precon_overlap if firstobs_deck,
		yaxis(2) mcolor(navy) msymbol(o) msize(0.8)
	)
	(scatter avg_has_both precon_overlap if firstobs_deck,
		yaxis(2) mcolor(maroon) msymbol(o) msize(0.8)
	),
	title("Probability of Having City of Brass and/or Mana Confluence")
	subtitle("as a Function of Overlap with Precons")
	xtitle("Number of cards that overlap with precon")
	ytitle("", axis(2))
	ylabel(0 "0%" .2 "20%" .4 "40%" .6 "60%" .8 "80%" 1 "100%", axis(2))
	legend(
		label(1 "Sample density")
		label(2 "Has either")
		label(3 "Has both")
		order(2 3 1)
	)
	graphregion(color(gs15))
	note("Source: EDHREC.com, TappedOut.net, and author's calculations")
;

graph export "${OUTPUT_DIR}/analysis_precon_overlap_5c_pains.png", replace;

#delimit cr

