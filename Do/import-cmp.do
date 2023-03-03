
// -------------------------------------------------------------------------- //
// Import Comparative Manifesto Project (CMP)
// -------------------------------------------------------------------------- //

use "$cmp/MPDataset_MPDS2020b_stata14.dta", clear

// Match country names to country codes
drop country
rename countryname isoname
merge m:1 isoname using "$work/country-codes.dta", keep(master matched)

replace iso="BA" if isoname=="Bosnia-Herzegovina"
replace iso="MK" if isoname=="North Macedonia"
replace iso="RU" if isoname=="Russia"
replace iso="KR" if isoname=="South Korea"
replace iso="US" if isoname=="United States"
assert iso!=""
drop _merge isoname
merge m:1 iso using "$work/country-codes.dta", nogen assert(matched using) keep(matched)

order iso isoname
sort iso isoname

// Keep only year of election
replace date=round(date/100,1)
rename date year

// Add variables: CMP left and right
egen cmp_left = rowtotal(per103 per105 per106 per107 per202 per403 per404 per406 per412 per413 per504 per506 per701)
egen cmp_right = rowtotal(per104 per201 per203 per305 per401 per402 per407 per414 per505 per601 per603 per605 per606)

// Add variables: Bakker-Hobolt measures
gen eco_right = per401 + per402 + per407 + per505 + per507 + per410 + per414 + per702
gen eco_left = per403 + per404 + per406 + per504 + per413 + per412 + per701 + per405 + per409 + per506 + per503 // no 506 or 503

gen val_right = per305 + per601 + per603 + per605 + per608 + per606
gen val_left = per501 + per602 + per604 + per502 + per607 + per416 + per705 + per706 + per201 + per202

gen eco = eco_right - eco_left
gen val = val_right - val_left

// Add variables: own indicators
* libertarian-authoritarian intensity based on Bakker-Hobolt
gen lib_int_left = val_left / (eco_left + val_left)
gen aut_int_right = val_right / (eco_right + val_right)

* libertarian-authoritarian intensity based on total emphases
gen lib_int_totl = val_left / (eco_right + eco_left + val_right + val_left)
gen aut_int_totl = val_right / (eco_right + eco_left + val_right + val_left)

foreach var of varlist lib_* aut_*{
	replace `var' = `var' * 100
}

// Label
labvars eco val eco_right eco_left val_right val_left ///
	"Economic left-right index = eco_right - eco_left" "Value left-right index = val_right - val_left" ///
	"Economic index (right)" "Economic index (left)" "Value index (right)" "Value index (left)"

// Order and save
order iso isoname year partyname eco val eco_right eco_left val_right val_left lib_* aut_*

save "$work/cmp.dta", replace


// -------------------------------------------------------------------------- //
// Add election-level variables
// -------------------------------------------------------------------------- //

use "$work/cmp.dta", clear

** number of parties
bysort iso edate: gen cnt_parties = _N

* total sum of voteshares
bysort iso edate: egen sum_pervote = total(pervote)

* total sum of seats
bysort iso edate: egen sum_seats = total(absseat)
gen total_seats = totseats

** number of parliamentary parties
gen in_parl = 1 if absseat > 0 & absseat !=.
bysort iso edate: egen cnt_parl_parties = total(in_parl)

*** effective number of parliamentary parties
gen seatshare = absseat / sum_seats
gen seatshare2 = seatshare^2
bys iso edate: egen total_seatshare2 = total(seatshare2)
bys iso edate: gen eff_nr_parl_parties = 1/(total_seatshare2)

*** effective number of electoral parties
gen pervotesq = (pervote/sum_pervote)^2
bys iso edate: egen total_pervotesq = total(pervotesq)
bys iso edate: gen eff_nr_parties = 1/(total_pervotesq)

*** rile_mean
bys iso edate: egen rile_mean = mean(rile)

*** ideological center of gravity (Sigelmann & ...)
gen weighted_rile = rile * pervote/sum_pervote
bys iso edate: egen rile_wmean = total(weighted_rile)

*** polarization index (Dalton 2008)
gen distances = (((rile - rile_wmean)/100)^2)*pervote
bys iso edate: egen total_distances = total(distances)
gen rile_polarization = sqrt(total_distances)

* disproportionality
gen seat_vote_diff = (pervote - seatshare*100)^2
bys iso edate: egen total_seat_vote_diff = total(seat_vote_diff)
gen disprop = sqrt(0.5*total_seat_vote_diff)

*** heterogeneity
foreach x in peruncod per101 per102 per103 per104 per105 per106 per107 per108 per109 per110 per201 per202 per203 per204 per301 per302 per303 per304 per305 per401 per402 per403 per404 per405 per406 per407 per408 per409 per410 per411 per412 per413 per414 per415 per416 per501 per502 per503 per504 per505 per506 per507 per601 per602 per603 per604 per605 per606 per607 per608 per701 per702 per703 per704 per705 per706 {
bys iso edate: egen `x'_sd = sd(`x') 
replace `x'_sd = `x'_sd^2
}
egen heterogeneity = rowmean(per101_sd-per706_sd) 
replace heterogeneity = heterogeneity/sqrt(cnt_parties)

*** mean salience of left-right dimensions - importance
gen import_rile = (per104 + per201 + per203 + per305 + per401 + per402 + per407 + per414 + per505 + per601 + per603 + per605 + per606) + ///
	(per103 + per105 + per106 + per107 + per403 + per404 + per406 + per412 + per413 + per504 + per506 + per701 + per202)
bys iso edate: egen rile_import_mean = mean(import_rile)

* importance weighted by pervote
gen weigthed_import_rile = import_rile * pervote/sum_pervote if pervote != .
bys iso edate: egen rile_import_wmean = total(weigthed_import_rile)

* min max rile
bysort iso edate: egen rile_min = min(rile)
bysort iso edate: egen rile_max = max(rile)

* ideological range
gen rile_range = abs(rile_max - rile_min)


********************************************
*** MEDIAN VOTER CALCULATION (KIM & FORDING)
********************************************

* drops parties with vote share == 0 as they do not matter for median voter calculcation
drop if pervote == 0

* create rilerank variable
bys iso edate: egen rilerank = rank(rile)

* generate pervote 2: merges parties from one coalition (same rile-score) to the same datapoint and adds up the pervote of the different rows
gen pervote2 = pervote 
sort iso edate rilerank pervote
by iso edate: replace pervote2 = pervote2[_n-1] + pervote2[_n] if rile[_n]==rile[_n-1]
by iso edate: replace pervote2 = 0 if rile[_n]== rile[_n+1]
drop if pervote2==0 

*** calculate midpoints
* kim & fording assumption
by iso edate (rilerank), sort: gen midleft = (rile + rile[_n-1])/2
mvencode midleft, mv(-100)
by iso edate (rilerank), sort: gen midright = (rile + rile[_n+1])/2
mvencode midright, mv(100)

* adjusted assumption
by iso edate (rilerank), sort: gen midleftA = (rile + rile[_n-1])/2
by iso edate (rilerank), sort: gen midrightA = (rile + rile[_n+1])/2
by iso edate (rilerank), sort: replace midrightA = rile + (rile - midleftA) if rilerank == rilerank[_N]
by iso edate (rilerank), sort: replace midleftA = rile - (midrightA - rile) if rilerank == 1


*** Interval (W) (with Kim-Fording assumption) 
gen voter_interval_width = midright-midleft

*** and ADJUSTED Kim-Fording assunption)
gen voter_interval_widthA = midrightA-midleftA

*** Real Total percent:
by iso edate, sort: gen pertotal = sum(pervote2)
by iso edate, sort: replace pertotal = pertotal[_N]


*** Detect Median Party
sort iso edate rilerank 
by iso edate: generate medpart = _n if sum(pervote2[_n-1]) < pertotal/2
mvencode medpart, mv(0)
generate medparty = .
label variable medparty "Median Party"
label define medianparty 0 "not median party" 1 "median party"
label values medparty medianparty

sort iso edate medpart
by iso edate: replace medparty = 1 if medpart==medpart[_N]
by iso edate: replace medparty = 0 if medpart<medpart[_N]
by iso edate: replace medpart = medpart[_N] 

* Median with Kim-Fording assumption
bys iso edate (rilerank): gen median_voter = midleft + ((pertotal/2 - sum(pervote2[_n-1]))/ pervote2 ) * voter_interval_width if (sum(pervote2[_n-1]) < pertotal/2) 

* Median with ADJUSTED Kim-Fording assumption
bys iso edate (rilerank): gen median_voter_adj = midleftA + ((pertotal/2 - sum(pervote2[_n-1]))/ pervote2 ) * voter_interval_widthA if (sum(pervote2[_n-1]) < pertotal/2) 

by iso edate: replace median_voter = median_voter[medpart]
by iso edate: replace median_voter_adj = median_voter_adj[medpart]

*****************************************************
*** CLEAN DATASET AND DELETE / MARK PROBLEMATIC CASES
*****************************************************

bysort iso edate (party): keep if _n == 1


**********************
*** LABELS AND FORMATS 
**********************

* round values
foreach var of varlist *_rile sum_pervote rile_* median_voter* heterogeneity disprop eff*{
*	replace `var' = round(`var', .01)
	format %9.2f `var'
}

local vars "iso isoname year edate cnt_parties cnt_parl_parties sum_pervote sum_seats total_seats eff_nr_parties eff_nr_parl_parties disprop rile_min rile_max rile_range rile_mean rile_wmean  rile_polarization rile_import_mean rile_import_wmean heterogeneity median_voter median_voter_adj"
keep `vars'
order `vars'

// Collapse by year
ds iso isoname year, not
collapse (mean) `r(varlist)', by(iso isoname year)

*** label variables
label variable iso "Country"
label variable isoname "English name of the country"
label variable rile_min "Position of most leftist party"
label variable rile_max "Position of most righist party"
label variable rile_range "Range on the left-right dimension"
label variable rile_mean "Mean position on the left-right dimension"
label variable rile_wmean "Ideological center of gravity (weighted average)"
label variable rile_polarization "Ideological polarization (Dalton 2008)"
label variable heterogeneity "Index of heterogeneity (Franzmann 2008)"
label variable rile_import_mean "Mean salience of rile categories"
label variable rile_import_wmean "Mean salience of rile categories weighted by vote share"
label variable cnt_parties "Number of parties covered for the election"
label variable cnt_parl_parties "Number of parliamentary parties coded in the Manifesto Dataset"
label variable sum_pervote "Sum of vote share of parties covered for the election"
label variable sum_seats "Number of seats occupied by parties that are covered by the Manifesto dataset"
label variable total_seats "Total number of seats in the parliament"
label variable median_voter "Median voter (Kim-Fording 1998)"
label variable median_voter_adj "Median voter (Kim Fording 1998, adjusted Michael McDonald 2002)"
label variable eff_nr_parties "Effective number of electoral parties (Laakso & Taagepera 1979)"
label variable eff_nr_parl_parties "Effective number of parliamentary parties (Laakso & Tageepera)"
label variable disprop "Disproportionality of vote-seat distribution (Gallagher 1991)"
label variable edate "Election date"

tempfile temp
save `temp'

// Merge CMP with macro-level variables
use "$work/cmp.dta", clear
merge m:1 iso year using `temp', nogen assert(matched)

// Add Western dummy
preserve
	use if west == 1 using "$work/gmp", clear
	levelsof iso, local(countries)
restore

gen west = 0
foreach c in `countries'{
	replace west = 1 if iso == "`c'"
}

order iso isoname west year partyname pervote eco val eco_* val_* lib_* aut_*

sort iso year pervote partyname


save "$work/cmp.dta", replace


// -------------------------------------------------------------------------- //
// Recode parties to match GMP dataset, clean up and export
// -------------------------------------------------------------------------- //

/*
// Export list of parties for manual recoding
use "$work/cmp", clear
keep if west == 1
keep if pervote >= 5
keep iso partyname partyabbrev
gduplicates drop iso partyname, force
export excel "$cmp/cmp-party-names.xlsx", sheet("parties") sheetreplace first(var)
*/

use "$work/cmp", clear

// Generate string date and recode when two elections in one year
generate date = string(edate, "%td")

replace year = 1953.5 if iso == "DK" & date == "22sep1953"
replace year = 2019.5 if iso == "ES" & date == "10nov2019"
replace year = 1974.5 if iso == "GB" & date == "10oct1974"
replace year = 1989.5 if iso == "GR" & date == "05nov1989"
replace year = 2015.5 if iso == "GR" & date == "20sep2015"
replace year = 2012.5 if iso == "GR" & date == "17jun2012"
replace year = 1982.5 if iso == "IE" & date == "24nov1982"
replace year = 1959.5 if iso == "IS" & date == "25oct1959"
replace year = 2015.5 if iso == "TR" & date == "01nov2015"

gduplicates list iso year partyn partyab

// Merge with GMP party codes
cap drop vote
preserve
	import excel "$cmp/cmp-party-names.xlsx", sheet("correspondence") first clear
	keep iso partyname vote
	tempfile temp
	save `temp'
restore
merge m:1 iso partyname using `temp', nogen

assert !mi(vote) if west == 1 & pervote > 5

// Replace missing values as CMP name, and drop parties with no vote share
replace vote = partyname if mi(vote)
replace vote = partyname if vote == "Other"
drop if mi(pervote)

// Correct a handful of duplicates
* Make a few corrections
replace vote = "PRLW" if iso == "BE" & inlist(year, 1971, 1974) & partyabbrev == "PLP" // rename Belgian liberal party
replace vote = "APU" if iso == "PT" & inlist(partyabbrev, "PEV", "PCP", "MDP") & inlist(year, 1983, 1985) // APU alliance
replace vote = "CDU" if iso == "PT" & inlist(partyabbrev, "PEV", "PCP") & inlist(year, 1987, 2002, 2005, 2009, 2015, 2019) // CDU alliance

* in a few cases, names are duplicated mostly due to party groupings in GMP dataset
gduplicates tag iso year vote, gen(dup)
sort iso year vote

* handcode a few additional parties that are reported together in GMP but separately in CMP
replace dup = 1 if inlist(partyname, "Country Party", "Liberal Party of Australia") & iso == "AU" & year == 1963

* take the vote-share-weighed average of relevant variables in these cases
foreach var of varlist eco* val* per101-intpeace{
	egen m = wtmean(`var'), by(iso year vote) weight(pervote)
	replace `var' = m if dup == 1
	drop m
}

* take total vote share and seat share in these cases
foreach var of varlist pervote presvote absseat{
	egen m = sum(`var'), by(iso year vote)
	replace `var' = m if dup == 1
	drop m
}

* drop duplicates, keeping selected name
drop if dup == 1 & partyname == "Australian Labor Party (Anti-Communist)" & iso == "AU"
drop if dup == 1 & partyname == "Country Party" & iso == "AU" & year == 1963
drop if dup == 1 & partyname == "Democratic Labor Party" & iso == "AU"
drop if dup == 1 & partyname == "Liberal National Party of Queensland" & iso == "AU"
drop if dup == 1 & partyabbrev == "PVV" & iso == "BE"
drop if dup == 1 & partyname == "Popular Democratic Party" & iso == "ES"
drop if dup == 1 & partyname == "Union for a New Majority - Gaullists/Conservatives" & iso == "FR"
drop if dup >= 1 & partyname != "Portuguese Communist Party" & iso == "PT"

drop dup
gduplicates tag iso year vote, gen(dup)
assert dup == 0
drop dup

order iso isoname west year date vote partyname partyab eco val eco_* val_* rile planeco markeco welfare intpeace
drop oecdmember eumember edate party parfam coderid manual coderyear testresult testeditsim progtype datasetorigin corpusversion total peruncod datasetversion id_perm

lab var west "Western democracy"
lab var date "Election date"
lab var vote "Party name (GMP)"
lab var partyname "Party name (CMP)"
lab var partyabbrev "Party abbreviation (CMP)"

compress

// Correct some remaining uncoded parties
replace vote = "KPO" if vote == "Austrian Communist Party" & iso == "AT"
replace vote = "NEOS" if vote == "The New Austria" & iso == "AT"

replace vote = "FDF" if vote == "Francophone Democratic Front of Francophones of Brussels" & iso == "BE"
replace vote = "FDF" if vote == "Francophone Democratic Front of Francophones" & iso == "BE"
replace vote = "CVP" if vote == "CD&V" & iso == "BE" & year == 1999

replace vote = "CSP/PCS" if vote == "Christian Social Party" & iso == "CH"
replace vote = "CVP/PDC" if vote == "Conservative People’s Party" & iso == "CH"
replace vote = "EDU/UDF" if vote == "Federal Democratic Union" & iso == "CH"
replace vote = "FPS/PSL" if vote == "Freedom Party of Switzerland" & iso == "CH"
replace vote = "MCG" if vote == "Geneva Citizens' Movement" & iso == "CH"
replace vote = "LPS/PLS" if vote == "Liberal Party of Switzerland" & iso == "CH"
replace vote = "EVP/PEV" if strpos(vote, "Protestant People")>0 & iso == "CH"
replace vote = "SD/DS" if vote == "Swiss Democrats" & iso == "CH"
replace vote = "PDA/PDT" if vote == "Swiss Labour Party" & iso == "CH"
replace vote = "Lega" if vote == "Ticino League" & iso == "CH"

replace vote = "Bayernpartei" if vote == "Bavarian Party" & iso == "DE"
replace vote = "Zentrum" if vote == "Centre Party" & iso == "DE"
replace vote = "WAV" if vote == "Economic Reconstruction League" & iso == "DE"
replace vote = "Deutsche_Partei" if vote == "German Party" & iso == "DE"
replace vote = "DRP" if vote == "German Reich Party" & iso == "DE"
replace vote = "SSW" if vote == "South Schleswig Voters’ Union" & iso == "DE"
replace vote = "Gruene" if strpos(vote, "Greens/Alliance") > 0 & iso == "DE"
replace vote = "Gruene" if vote == "Gruene_Buendnis90" & iso == "DE" & !inlist(year, 2002, 2005) 

replace vote = "LS" if vote == "Left Socialist Party" & iso == "DK"
replace vote = "CC" if vote == "Common Course" & iso == "DK"
replace vote = "TA" if vote == "Alternativ" & iso == "DK"
replace vote = "KD" if vote == "Christian Democrats" & iso == "DK"
replace vote = "DU" if vote == "Danish Union" & iso == "DK"
replace vote = "IP" if strpos(vote, "Independents")>0 & iso == "DK"
replace vote = "L" if vote == "Liberal Centre" & iso == "DK"
replace vote = "NA" if vote == "New Alliance" & iso == "DK"
replace vote = "D" if vote == "The New Right" & iso == "DK"

replace vote = "Finnish Christian League" if vote == "Finnish Christian Union" & iso == "FI"

replace vote = "RPR" if vote == "Union for a New Majority - Conservatives/Gaullists" & iso == "FR" & year == 1988
replace vote = "RPR" if vote == "UMP" & iso == "FR" & year == 2002
replace vote = "UDF" if vote == "Democratic Movement" & iso == "FR" & year == 2007
replace vote = "FDG" if vote == "Left Front" & iso == "FR" & year == 2012
replace vote = "FI" if vote == "Indomitable France" & iso == "FR" & year == 2017

replace vote = "SNP" if vote == "Scottish National Party" & iso == "GB"

replace vote = "Workers' Party" if strpos(vote, "Workers") & iso == "IE"
replace vote = "Green" if vote == "Green Party" & iso == "IE"
replace vote = "Democratic Left" if vote == "Democratic Left Party" & iso == "IE"

replace vote = "VERDI" if vote == "Green Federation" & iso == "IT"
replace vote = "LISTA PANNELLA" if vote == "Panella List" & iso == "IT"
replace vote = "LISTA PANNELLA" if vote == "Pannella-Riformatori List" & iso == "IT"
replace vote = "PANNELLA/SGARBI" if vote == "Pannella-Sgarbi List" & iso == "IT"
replace vote = "GIRASOLE" if strpos(vote, "Girasole")>0 & iso == "IT"
replace vote = "LISTA DI PIETRO" if vote == "List Di Pietro - Italy of Values" & iso == "IT"
replace vote = "DEMOCRAZIA EUROPEA" if vote == "European Democracy" & iso == "IT"
replace vote = "CD" if vote == "Democratic Centre" & iso == "IT" & year == 2013
replace vote = "RC" if vote == "Civil Revolution" & iso == "IT"
replace vote = "SEL" if vote == "Left Ecology Freedom" & iso == "IT"
replace vote = "FRATELLI D'ITALIA" if vote == "Brothers of Italy" & iso == "IT" & year == 2018
replace vote = "LIBERI E UGUALI" if vote == "Free and Equal" & iso == "IT" & year == 2018
replace vote = "PIU EUROPA" if vote == "Italy Europe Together" & iso == "IT" & year == 2018
replace vote = "Lega" if vote == "LEGA" & iso == "IT" & year == 2018

replace vote = "Green List Ecological Initiative" if vote == "Green Left Ecological Initiative" & iso == "LU" & year == 1989

replace vote = "RPF" if vote == "Reformatory Political Federation" & iso == "NL"
replace vote = "SGP" if vote == "Reformed Political Party" & iso == "NL"
replace vote = "GPV" if vote == "Reformed Political League" & iso == "NL"
replace vote = "RPF" if vote == "Reformatory Political Federation" & iso == "NL"
replace vote = "CD" if vote == "Centre Democrats" & iso == "NL"
replace vote = "PvdD" if vote == "Party for the Animals" & iso == "NL"
replace vote = "CU" if vote == "Christian Union" & iso == "NL"
replace vote = "50+" if vote == "50Plus" & iso == "NL"
replace vote = "FvD" if vote == "Forum for Democracy" & iso == "NL"

replace vote = "Socialist People's Party" if strpos(vote, "Socialist People") > 0 & iso == "NO"
replace vote = "New People's Party" if strpos(vote, "New People") > 0 & iso == "NO"
replace vote = "Socialist Electoral League" if vote == "Socialist People's Party" & iso == "NO" & year == 1973

replace vote = "Progressive Coalition" if strpos(vote, "Jim Anderton") > 0 & iso == "NZ"
replace vote = "Maori" if strpos(vote, "ori Party")>0 & iso == "NZ"
replace vote = "Mana" if vote == "Mana Party" & iso == "NZ"

replace vote = "PAN" if vote == "People-Animals-Nature" & iso == "PT"

order iso isoname west year partyname pervote eco val eco_* val_* lib_* aut_*

save "$work/cmp", replace








