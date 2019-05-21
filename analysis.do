#delimit cr
version 13.0
capture log close _all
clear all
set more off

/*******************************************************************************
*
* Commander 2016 Analysis
*
* AUTH: Daniel Reeves
* DATE: 2017-03-30
*
* Steps:
*   01 - Import data
*   02 - Precon overlap analysis
*   03 - Price analysis
*   04 - Degeneracy analysis
*
*******************************************************************************/

/* Static Directories */
global PROJECT_DIR "C:/Users/Daniel/Documents/Stata/C16 Analysis"
global CODE_DIR "${PROJECT_DIR}/code"
global RAW_DIR "${PROJECT_DIR}/raw"
global OUTPUT_DIR "${PROJECT_DIR}/output"
global DATA_DIR "${PROJECT_DIR}/data"
cd "${PROJECT_DIR}"

/* Files */
global INFECT_CARDS_DTA "${DATA_DIR}/other/infect.dta"
	//manually gathered list of cards with Infect
global CARD_PRICES_RAW "${RAW_DIR}/mtgallprices.xlsx"
global CARD_PRICES_DTA "${DATA_DIR}/mtgprice/cardprices.dta"
	//list of card prices gathered on MTGPrice.com on Feb 11, 2017
global DECKS_DTA "${DATA_DIR}/edhrec/all_decks.dta"

/* Lists */
global COMMANDERS = "atraxa breya kynaios saskia yidris"
	//the five commanders that head the 2016 preconstructed decks

/******************************************************************************/

capture log using "${OUTPUT_DIR}/log.txt", text name(master_log) replace

do "${CODE_DIR}/01 - Import data.do"
do "${CODE_DIR}/02 - Precon overlap analysis.do"
do "${CODE_DIR}/03 - Price analysis.do"
do "${CODE_DIR}/04 - Degeneracy analysis.do"

capture log close master_log

/******************************************************************************/

exit
