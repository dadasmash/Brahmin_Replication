
// -------------------------------------------------------------------------- //
// Figure 1 and variants
// -------------------------------------------------------------------------- //

// The transformation of party systems and the reversal of the education gradient
use "$work/gmp-macro", clear
keep if west == 1
drop if value == 0
replace value = value * 100
keep iso year year2 var value
greshape wide value, i(iso year year2) j(var) string
renpfix value

* aggregate some low-quality decades
replace year2 = 1970 if iso == "CA" & year2 == 1960
replace year2 = 1980 if iso == "IS" & year2 == 1970

* recode year2
drop year2
gen year2 = 1955 if inrange(year, 1940, 1960)
replace year2 = 1960 if inrange(year, 1961, 1965)
replace year2 = 1965 if inrange(year, 1966, 1970)
replace year2 = 1970 if inrange(year, 1971, 1975)
replace year2 = 1975 if inrange(year, 1976, 1980)
replace year2 = 1980 if inrange(year, 1981, 1985)
replace year2 = 1985 if inrange(year, 1986, 1990)
replace year2 = 1990 if inrange(year, 1991, 1995)
replace year2 = 1995 if inrange(year, 1996, 2000)
replace year2 = 2000 if inrange(year, 2001, 2005)
replace year2 = 2005 if inrange(year, 2006, 2010)
replace year2 = 2010 if inrange(year, 2011, 2015)
replace year2 = 2015 if inrange(year, 2016, 2020)

// Collapse by country
keep iso year year2 educ_* inc_* vote_*
gcollapse (mean) educ_* inc_* vote_*, by(iso year2)

keep iso year2 vote_inc_dp90 vote_educ_dp90 vote_inc_dc90 vote_educ_dc90 educ_olf educ_olr educ_gre educ_ext inc_olf inc_olr inc_gre inc_ext educ_rig inc_rig educ_lib inc_lib educ_ril inc_ril
renvars educ_olf educ_olr educ_gre educ_ext inc_olf inc_olr inc_gre inc_ext educ_rig inc_rig educ_lib inc_lib educ_ril inc_ril, pref(vote_)

foreach var of varlist *ext{
	replace `var' = . if year2 < 1970
}
foreach var of varlist *gre{
	replace `var' = . if year2 < 1980
}

// Reshape
greshape long vote_, i(iso year2) j(var) string
greshape wide vote_, i(year2 var) j(iso) string
renpfix vote_

// Generate averages
egen unb_ = rowmean(AT AU BE CA CH DE DK ES FI FR GB IE IS IT LU NL NO NZ PT SE US) // unbalanced panel
egen gr1_ = rowmean(AU CA CH DE DK FR GB IT NL NO SE US) // short balanced panel
egen gr2_ = rowmean(DE FR GB IT NO SE US) // long balanced panel

keep year2 var unb_ gr1_ gr2_
greshape wide unb_ gr1_ gr2_, i(year2) j(var) string

gen year = "", before(year2)
replace year = "1948-60" if year2 == 1955
replace year = "1961-65" if year2 == 1960
replace year = "1966-70" if year2 == 1965
replace year = "1971-75" if year2 == 1970
replace year = "1976-80" if year2 == 1975
replace year = "1981-85" if year2 == 1980
replace year = "1986-90" if year2 == 1985
replace year = "1991-95" if year2 == 1990
replace year = "1996-00" if year2 == 1995
replace year = "2001-05" if year2 == 2000
replace year = "2006-10" if year2 == 2005
replace year = "2011-15" if year2 == 2010
replace year = "2016-20" if year2 == 2015

gen zero = 0

order year year2 zero unb_educ_dp90 unb_educ_dc90 unb_inc_dp90 unb_inc_dc90 ///
	gr1_educ_dp90 gr1_educ_dc90 gr1_inc_dp90 gr1_inc_dc90 gr2_educ_dp90 gr2_educ_dc90 gr2_inc_dp90 gr2_inc_dc90
order *educ_rig *inc_rig *educ_lib *inc_lib *educ_ril *inc_ril, last

export excel "$results/GMP2021.xlsx", sheet("r_multi_avg") sheetreplace first(var)



// -------------------------------------------------------------------------- //
// Figure 2, Figure 3 and main indicators for all variables and all Western democracies
// -------------------------------------------------------------------------- //

// Open dataset
use "$work/gmp-macro", clear
keep if west == 1
gen tokeep = 0

replace value = value * 100

// Select variables
replace tokeep = tokeep + 1 if var == "vote_educ_dp50"
replace tokeep = tokeep + 1 if var == "vote_educ_dc50"

replace tokeep = tokeep + 1 if var == "vote_educ_dp90"
replace tokeep = tokeep + 1 if var == "vote_educ_dc90"

replace tokeep = tokeep + 1 if var == "vote_educ_dpc1"
replace tokeep = tokeep + 1 if var == "vote_educ_dcc1"

replace tokeep = tokeep + 1 if var == "vote_educ_dpc3"
replace tokeep = tokeep + 1 if var == "vote_educ_dcc3"

replace tokeep = tokeep + 1 if var == "vote_educ_dpqu"
replace tokeep = tokeep + 1 if var == "vote_educ_dcqu"

replace tokeep = tokeep + 1 if var == "vote_inc_dp50"
replace tokeep = tokeep + 1 if var == "vote_inc_dc50"

replace tokeep = tokeep + 1 if var == "vote_inc_dp90"
replace tokeep = tokeep + 1 if var == "vote_inc_dc90"

replace tokeep = tokeep + 1 if var == "vote_inc_dpqu"
replace tokeep = tokeep + 1 if var == "vote_inc_dcqu"

replace tokeep = tokeep + 1 if var == "vote_class_diff"
replace tokeep = tokeep + 1 if var == "vote_class_difc"

replace tokeep = tokeep + 1 if var == "vote_religion_chrd"

replace tokeep = tokeep + 1 if var == "vote_rural_diff"
replace tokeep = tokeep + 1 if var == "vote_rural_difc"

replace tokeep = tokeep + 1 if var == "vote_age_dq25"
replace tokeep = tokeep + 1 if var == "vote_age_dc25"
replace tokeep = tokeep + 1 if var == "vote_age_dp10"

replace tokeep = tokeep + 1 if var == "vote_sex_diff"

replace tokeep = tokeep + 1 if var == "vote_union_diff"
replace tokeep = tokeep + 1 if var == "vote_union_difc"

replace tokeep = tokeep + 1 if var == "vote_sector_diff"
replace tokeep = tokeep + 1 if var == "vote_sector_difc"

replace tokeep = tokeep + 1 if var == "vote_religion_none"

replace tokeep = tokeep + 1 if var == "vote_center_diff"
replace tokeep = tokeep + 1 if var == "vote_center_difc"

replace tokeep = tokeep + 1 if var == "vote_age_dp90"
replace tokeep = tokeep + 1 if var == "vote_age_dc90"

replace tokeep = tokeep + 1 if var == "vote_sex_dif3"
replace tokeep = tokeep + 1 if var == "vote_sex_dif4"
replace tokeep = tokeep + 1 if var == "vote_sex_difc"

replace tokeep = tokeep + 1 if var == "vote_house_diff"
replace tokeep = tokeep + 1 if var == "vote_house_difc"

drop if tokeep == 0
sort tokeep

// Small fixes by variables
* aggregate the 1940s
replace year2 = 1950 if year2 == 1940

//REPLICATION: Do not fix below
/*
* aggregate some low-quality decades
replace year2 = 1970 if iso == "CA" & year2 == 1960
replace year2 = 1980 if iso == "IS" & year2 == 1970

* income outliers
drop if year2 == 2000 & iso == "LU" & strpos(var, "vote_inc") > 0
drop if year2 == 1960 & iso == "GB" & strpos(var, "vote_inc") > 0

* class outliers
drop if iso == "IT" & strpos(var, "vote_class") > 0 // this corresponds to actual occupation
drop if iso == "FR" & year < 1980 & strpos(var, "vote_class") > 0
drop if !(inlist(iso, "US", "GB", "AU", "NZ", "NL", "LU", "SE") | inlist(iso, "NO", "DK", "FR", "ES", "PT", "IT")) & strpos(var, "vote_class") > 0 

* religion outliers
drop if iso == "IS" & strpos(var, "vote_religion") > 0 // only one data points
drop if iso == "DK" & strpos(var, "vote_religion") > 0 // only data in the 1970s
drop if iso == "NO" & strpos(var, "vote_religion") > 0 // data on religiosity but not on religion
drop if iso == "AT" & strpos(var, "vote_religion") > 0 // too inconsistent
drop if iso == "IE" & strpos(var, "vote_religion") > 0 // too inconsistent
drop if iso == "DE" & year2 == 1960 & strpos(var, "vote_religion") > 0 // only partial data, no "no religion"
drop if iso == "PT" & year == 2002 & strpos(var, "vote_religion") > 0 // bad data

* rural-urban outliers
drop if iso == "PT" & year2 == 1990 & strpos(var, "vote_rural") > 0
drop if iso == "FR" & year2 == 1950 & strpos(var, "vote_rural") > 0
drop if iso == "AT" & year2 == 1980 & strpos(var, "vote_rural") > 0
drop if iso == "FR" & year2 == 1950 & strpos(var, "vote_rural") > 0

* age outliers
drop if iso == "GB" & year2 == 1950 & strpos(var, "vote_age") > 0
drop if iso == "IT" & year2 == 1950 & strpos(var, "vote_age") > 0

* gender outliers
drop if iso == "LU" & year2 == 2010 & strpos(var, "vote_sex") > 0 // negative but not significant
drop if iso == "CH" & year2 == 1960 & strpos(var, "vote_sex") > 0 // no data on women

* union outliers
drop if iso == "IT" & year2 == 1950 & strpos(var, "vote_union") > 0
*/
// Rename countries
replace isoname = "Britain" if iso == "GB"

// Collapse by decade for each country and reshape
gcollapse (mean) value, by(isoname year2 var)
greshape wide value, i(var year2) j(isoname) string
renpfix value
foreach var of varlist _all{
	lab var `var' "`var'"
}

lab var New_Zealand "New Zealand"
lab var United_States "United States"
lab var var "Variable"
lab var year2 "Decade"

gen zero = 0, after(year2)

tostring year2, replace
replace year2 = "1948-59" if year2 == "1950"
replace year2 = "1960-69" if year2 == "1960"
replace year2 = "1970-79" if year2 == "1970"
replace year2 = "1980-89" if year2 == "1980"
replace year2 = "1990-99" if year2 == "1990"
replace year2 = "2000-09" if year2 == "2000"
replace year2 = "2010-20" if year2 == "2010"

// Generate averages
ds var year2 zero, not
egen mean = rowmean(`r(varlist)')
egen mean1 = rowmean(United_States Britain Australia New_Zealand Ireland Canada Sweden Norway Denmark Finland Iceland)
egen mean2 = rowmean(Austria Netherlands Switzerland Belgium Luxembourg Germany France Spain Italy Portugal)

lab var mean "Average"
lab var mean1 "Average"
lab var mean2 "Average"

// Export each variables
levelsof var, local(variables)
foreach var in `variables'{
*local var vote_sex_difc
preserve
	keep if var == "`var'"
	export excel "$results/GMP2021.xlsx", sheet("`var'") sheetreplace first(varl)
restore
}



// -------------------------------------------------------------------------- //
// Figure 4: Election results
// -------------------------------------------------------------------------- //

use "$work/western-election-results.dta", clear

* aggregate some groups
replace group = "Right" if group == "Christian"
replace group = "Right" if group == "Old right"
replace group = "Left" if group == "Old left"
replace group = "Left" if group == "New left"
replace group = "Other" if group == "Regional"

* small fix: normalize to 100
bys iso year: egen sum = sum(share)
replace share = share / sum
drop sum

* collapse by group, then by countries, and reshape
gcollapse (sum) share, by(iso year year2 group)

* reshape
greshape wide share, i(iso year year2) j(group) string
foreach var of varlist share*{
	replace `var' = 0 if mi(`var')
}

* collapse by decade
gcollapse (mean) share*, by(iso year2)

* drop some countries
drop if inlist(iso, "ES", "PT")
drop if inlist(iso, "GB", "US")

* average over all countries
gcollapse (mean) share*, by(year2)

renpfix share
renvars, lower

* order, label and export
lab var communist "Communists"
lab var far_right "Far-right / Anti-immigration"
lab var green "Greens / New left"
lab var left "Socialists / Social-democrats"
lab var liberal "Social-liberals / Liberals"
lab var other "Other"
lab var right "Conservatives / Christian-Dem."

order year2 right left communist liberal green far_right other
tostring year2, replace
replace year2 = "1945-49" if year2 == "1940"
replace year2 = "1950-59" if year2 == "1950"
replace year2 = "1960-69" if year2 == "1960"
replace year2 = "1970-79" if year2 == "1970"
replace year2 = "1980-89" if year2 == "1980"
replace year2 = "1990-99" if year2 == "1990"
replace year2 = "2000-09" if year2 == "2000"
replace year2 = "2010-20" if year2 == "2010"

export excel "$results/GMP2021.xlsx", sheet("elec_west") sheetreplace first(varl)



// -------------------------------------------------------------------------- //
// Figure 5 to Figure 6: Income-education indicators by party family
// -------------------------------------------------------------------------- //

use "$work/gmp-macro", clear
keep if west == 1
drop if value == 0
replace value = value * 100
keep iso year year2 var value

greshape wide value, i(iso year year2 ) j(var) string
renpfix value

keep iso year year2  educ_* inc_*

* collapse by small periods
drop if year < 1960

gen period = 1 if inrange(year, 1960, 1965)
bys iso: egen x = max(year)
replace period = 2 if inrange(year, 2016, 2020)
drop if mi(period)

gcollapse (mean) educ_* inc_*, by(iso period)
gcollapse (mean) educ_* inc_*, by(period)

greshape long educ_ inc_, i(period) j(party) string
greshape wide educ_ inc_, i(party) j(period)
order party educ_2 inc_2 educ_1 inc_1

replace party = subinstr(party, "_", "", .)
replace party = "All left-wing" if party == "lef"
replace party = "Socialists / Soc.-dem. / Other left" if party == "olf"
replace party = "Greens" if party == "gre"
replace party = "New left" if party == "nlf"
replace party = "Christian" if party == "chr"
replace party = "Anti-immigration" if party == "ext"
replace party = "Social-liberals" if party == "lib"
replace party = "Conservatives / Christians / Social-lib." if party == "olr"
replace party = "All right-wing" if party == "rig"
replace party = "Conserv. / Christ. / Social-lib. (old version)" if party == "ril"

sort party

export excel "$results/GMP2021.xlsx", sheet("quad_avg") sheetreplace first(varl)


// -------------------------------------------------------------------------- //
// Figure 7: Income-education indicators by party family with all countries
// -------------------------------------------------------------------------- //

// Plot the result
use "$work/gmp-macro", clear
keep if west == 1

drop if value == 0
replace value = value * 100
keep iso isoname year var value
greshape wide value, i(iso isoname year) j(var) string
renpfix value

keep iso isoname year educ_* inc_*

bys iso: egen x = max(year)
keep if year == x
drop x

replace inc_ext = . if iso == "GB"

export excel "$results/GMP2021.xlsx", sheet("r_quad_fam") sheetreplace first(var)


// -------------------------------------------------------------------------- //
// Figure 8: The evolution of ideological polarization
// -------------------------------------------------------------------------- //

use "$work/gmp-cmp-party", clear

gen year2 = floor(year / 10) * 10
replace year2 = 2010 if year == 2020
replace year2 = 1950 if year2 == 1940

replace votegroup = "Socdem" if inlist(vote, "APU", "CDU") & iso == "PT"

replace votegroup = "Conservative" if inlist(votegroup, "Christian", "Old right", "Right")
replace votegroup = "Other" if inlist(votegroup, "Regional")
replace votegroup = "Socdem" if inlist(votegroup, "Communist", "New left", "Old left", "Left")
replace votegroup = "Conservative" if votegroup == "Liberal"

* normalize by decennial average
foreach var in eco val{
	bys year2: egen mean = wtmean(`var'), weight(pervote)
	replace `var' = (`var' - mean)
	drop mean
}

gcollapse (mean) eco val [pw=pervote], by(year2 votegroup)
drop if mi(votegroup) | votegroup == "Other"
drop if votegroup == "Far right" & year2 < 1970

greshape wide eco val, i(year2) j(votegroup) string

* table
order year ecoSocdem ecoConservative ecoFar_right ecoGreen valSocdem valConservative valFar_right valGreen
tostring year2, replace
replace year2 = "1945-59" if year2 == "1950"
replace year2 = "1960-69" if year2 == "1960"
replace year2 = "1970-79" if year2 == "1970"
replace year2 = "1980-89" if year2 == "1980"
replace year2 = "1990-99" if year2 == "1990"
replace year2 = "2000-09" if year2 == "2000"
replace year2 = "2010-20" if year2 == "2010"
export excel "$results/GMP2021.xlsx", sheet("cmp_avg_scores") first(var) sheetreplace


// -------------------------------------------------------------------------- //
// Figure 9: Correlation between party ideology and income/education gradients
// -------------------------------------------------------------------------- //

use "$work/gmp-cmp-party", clear

gen year2 = floor(year / 10) * 10
replace year2 = 2010 if year == 2020
replace year2 = 1950 if year2 == 1940

replace votegroup = "Conservative" if inlist(votegroup, "Christian", "Old right", "Right")
replace votegroup = "Other" if inlist(votegroup, "Regional")
replace votegroup = "Socdem" if inlist(votegroup, "Communist", "New left", "Old left", "Left")

// Evolution of correlations by decade
gen cor_edu_eco = .
gen cor_edu_val = .
gen cor_inc_eco = .
gen cor_inc_val = .
foreach var in cor_edu_eco cor_edu_val cor_inc_eco cor_inc_val{
	gen `var'_lb = .
	gen `var'_ub = .
}
forval y = 1950(10)2010{
	ci2 geduc_3 eco if year2 == `y', corr
	replace cor_edu_eco = - `r(rho)' if year2 == `y'
	replace cor_edu_eco_lb = - `r(lb)' if year2 == `y'
	replace cor_edu_eco_ub = - `r(ub)' if year2 == `y'
	
	ci2 geduc_3 val if year2 == `y', corr
	replace cor_edu_val = - `r(rho)' if year2 == `y'
	replace cor_edu_val_lb = - `r(lb)' if year2 == `y'
	replace cor_edu_val_ub = - `r(ub)' if year2 == `y'
	
	ci2 ginc_3 eco if year2 == `y', corr
	replace cor_inc_eco = - `r(rho)' if year2 == `y'
	replace cor_inc_eco_lb = - `r(lb)' if year2 == `y'
	replace cor_inc_eco_ub = - `r(ub)' if year2 == `y'
	
	ci2 ginc_3 val if year2 == `y', corr
	replace cor_inc_val = - `r(rho)' if year2 == `y'
	replace cor_inc_val_lb = - `r(lb)' if year2 == `y'
	replace cor_inc_val_ub = - `r(ub)' if year2 == `y'
}

keep year2 cor_*
gduplicates drop

order year cor_edu_val* cor_inc_eco* cor_edu_eco* cor_inc_val*

foreach var in cor_edu_val cor_inc_eco cor_edu_eco cor_inc_val{
	replace `var'_lb = `var' - `var'_lb
	replace `var'_ub = `var'_ub - `var'
}

tostring year2, replace
replace year2 = "1948-1959" if year2 == "1950"
replace year2 = "1960-69" if year2 == "1960"
replace year2 = "1970-79" if year2 == "1970"
replace year2 = "1980-89" if year2 == "1980"
replace year2 = "1990-99" if year2 == "1900"
replace year2 = "2000-09" if year2 == "2000"
replace year2 = "2010-20" if year2 == "2010"

export excel "$results/GMP2021.xlsx", sheet("cor_cmp_gmp_party") sheetreplace first(var)


// -------------------------------------------------------------------------- //
// Figure 10: Correlation between polarization and education gradient across countries
// -------------------------------------------------------------------------- //

// CMP - standard deviation, all parties
use "$work/gmp-cmp-party", clear

gen year2 = floor(year / 10) * 10
replace year2 = 2010 if year2 == 2020
replace year2 = 1950 if year2 == 1940

drop if mi(eco)

gcollapse (mean) eco val (sd) sd_eco = eco sd_val = val [aw=pervote], by(iso isoname year year2)

replace eco = sd_eco
replace val = sd_val

merge 1:m iso year using "$work/gmp-macro", nogen keep(master matched)
replace value = value * 100

gcollapse (mean) value eco val sd_*, by(iso isoname year2 var)

drop if iso == "LU" & year2 == 2010

keep if inlist(var, "vote_educ_dp90", "vote_inc_dp90")
sort var year2 iso isoname
order var year2 iso isoname
drop eco val

export excel "$results/GMP2021.xlsx", sheet("cor_cmp_gmp_country") sheetreplace first(var)


// -------------------------------------------------------------------------- //
// Figure 11: Generational dynamics and educational divides
// -------------------------------------------------------------------------- //

use "$work/gmp-educ", clear
keep if west == 1

replace year2 = 1950 if year2 == 1940

drop if mi(age)
gen generation = floor((year - age)/10)*10
replace generation = 1900 if inrange(generation, 1800, 1899)
replace generation = 1980 if inrange(generation, 1990, 2020)

replace geduc = (geduc == 3) if !mi(geduc)

gcollapse (mean) voteleft [pw=weight], by(iso year2 geduc generation)

greshape wide voteleft, i(iso year2 generation) j(geduc)

gen diff = (voteleft1 - voteleft0) * 100

* drop too old or too young people
drop if year2 - generation <= 20 & generation != 1990
drop if year2 - generation >= 90

keep if (inlist(iso, "AU", "CA", "CH", "DE", "DK", "FR") | inlist(iso, "GB", "IT", "NL", "NO", "SE", "US")) & year >= 1960
drop if mi(generation)
gcollapse (mean) diff, by(year2 generation)
greshape wide diff, i(year2) j(generation)
replace diff1900 = . if year == 1980
replace diff1910 = . if year == 1990
replace diff1920 = . if year == 2000

foreach var of varlist diff*{
	local lab = substr("`var'", -4, 4)
	lab var `var' "`lab's"
}
lab var diff1900 "Pre-1900 generation"
lab var diff1980 "Post-1980 generation"

tostring year2, replace force
replace year2 = "1945-49" if year2 == "1940"
replace year2 = "1950-59" if year2 == "1950"
replace year2 = "1960-69" if year2 == "1960"
replace year2 = "1970-79" if year2 == "1970"
replace year2 = "1980-89" if year2 == "1980"
replace year2 = "1990-99" if year2 == "1990"
replace year2 = "2000-09" if year2 == "2000"
replace year2 = "2010-20" if year2 == "2010"

export excel "$results/GMP2021.xlsx", sheet("age_educ_cohort") sheetreplace first(varl)







