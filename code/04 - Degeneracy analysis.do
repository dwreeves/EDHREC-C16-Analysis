/*~ 04 - Degeneracy analysis.do ~*/

/*******************************************************************************
** 04a. Prepare data
*******************************************************************************/

use "${DECKS_DTA}", clear

merge m:1 card using "${INFECT_CARDS_DTA}", gen(_merge_infect)
	//Manually created file

sort deck

/*~~~~~~~~~~~~~~~~~~~~*/
/* Generic degeneracy */
/*~~~~~~~~~~~~~~~~~~~~*/

tempvar d1 d2 d3 dinfect

by deck: egen `d1' = max(card=="Blightsteel Colossus")
by deck: egen `d2' = max(card=="Doomsday" | card=="Laboratory Maniac")
by deck: egen `d3' = ///
	total( ///
		card=="Mana Crypt" | ///
		card=="Sol Ring" | ///
		card=="Mana Vault" | ///
		card=="Chrome Mox" | ///
		card=="Mox Diamond" | ///
		card=="Mox Opal" | ///
		card=="Lotus Petal")
replace `d3' = 0 if `d3'<4
replace `d3' = 1 if `d3'>=4

by deck: egen byte `dinfect' = total(_merge_infect==3)
replace `dinfect' = `dinfect'>=5 & inlist(commander, "atraxa", "saskia")

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* Breya degenerate strategies */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

tempvar d1_breya_a d1_breya_b d1_breya
tempvar d2_breya_a d2_breya_b d2_breya
tempvar d3_breya d4_breya

by deck: egen byte `d1_breya_a' = ///
	max(card=="Worldgorger Dragon")
by deck: egen byte `d1_breya_b' = ///
	total(card=="Animate Dead" | card=="Dance of the Dead" | card=="Necromancy")
gen byte `d1_breya' = ///
	`d1_breya_a' * ceil(`d1_breya_b'/2) * commander=="breya"

by deck: egen byte `d2_breya_a' = ///
	total(card=="Nim Deathmantle" | card=="Eldrazi Displacer")
by deck: egen byte `d2_breya_b' = ///
	total(card=="Ashnod's Altar" | card=="Krark-Clan Ironworks")
gen byte `d2_breya' = ///
	ceil((`d2_breya_a'+`d2_breya_b')/3) * (commander=="breya")

by deck: egen byte `d3_breya' = ///
	total(card=="Isochron Scepter" | card=="Dramatic Reversal")
replace `d3_breya' = 0 if commander!="breya"
replace `d3_breya' = `d3_breya'==2

by deck: egen byte `d4_breya' = ///
	total(card=="Auriok Salvagers" | card=="Lion's Eye Diamond")
replace `d4_breya' = 0 if commander!="breya"
replace `d4_breya' = `d4_breya'==2

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* Yidris degenerate strategies */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

tempvar d1_yidris d2_yidris_a d2_yidris_b d2_yidris

by deck: egen `d1_yidris' = ///
	max(card=="Aetherflux Reservoir" | card=="Tendrils of Agony")
replace `d1_yidris' = 0 if commander!="yidris"

by deck: egen int `d2_yidris_a' = ///
	total( ///
	card=="Waste Not"| ///
	card=="Time Spiral"| ///
	card=="Wheel of Fortune"| ///
	card=="Windfall"| ///
	card=="Wheel of Fate"| ///
	card=="Timetwister")
by deck: egen byte `d2_yidris_b' = max(card=="Notion Thief")
gen byte `d2_yidris' = ///
	((`d2_yidris_a'>=3) + ///
	(`d2_yidris_a'>=4 & `d2_yidris_b')) * (commander=="yidris")

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* Atraxa degenerate strategies */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

tempvar d1_atraxa d2_atraxa_a d2_atraxa_b d2_atraxa


by deck: egen `d1_atraxa' = total(card=="Tezzeret the Seeker"|card=="The Chain Veil")
replace `d1_atraxa' = 0 if commander!="atraxa"
replace `d1_atraxa' = `d1_atraxa'==2

by deck: egen `d2_atraxa_a' = max(card=="Doubling Season")
by deck: egen `d2_atraxa_b' = total( ///
	card=="Tamiyo, the Moon Sage" | ///
	card=="Tamiyo, Field Researcher" | ///
	card=="Narset Transcendent" | ///
	card=="Vraska the Unseen" | ///
	card=="Jace, Unraveler of Secrets")
gen `d2_atraxa' = commander=="atraxa" & `d2_atraxa_a' & (`d2_atraxa_b'>=2)

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/* Calculate total degeneracy */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

gen byte degenerate = 0

replace degenerate = `d1' + `d2' + `d3' ///
	+ `d1_breya' + `d2_breya' + `d3_breya' + `d4_breya' ///
	+ `d1_yidris' + `d2_yidris' ///
	+ `d1_atraxa' + `d2_atraxa' ///
	+ `dinfect'

replace degenerate = 5 if degenerate>=5 //Top-coded at 5

/*******************************************************************************
** 04b. Table
*******************************************************************************/

log using "${OUTPUT_DIR}/degeneracy.txt", name(degeneracy) text replace

table degenerate commander if firstobs_deck, ///
	c(mean has_either count firstobs_deck) f(%12.3fc) row col

log close degeneracy
