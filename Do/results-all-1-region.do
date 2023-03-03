
// Compute results on regional inequalities and regional voting.

// -------------------------------------------------------------------------- //
// Regional cleavages: all indicators
// -------------------------------------------------------------------------- //

use "$work/gmp", clear

drop if mi(region)

levelsof iso if iso != "BE", local(countries) //REPLICATION: Belgium excluded because convergence not achieved

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c ZA
	use if iso == "`c'" using "$work/gmp", clear
	drop if mi(region)
	
	*keep if year == 1971
	
	// Recode voteleft in some countries
	replace voteleft = 1 if iso == "CA" & vote == "Bloc Quebecois"
	replace voteleft = 1 if iso == "GB" & vote == "SNP"
	
	// Select specific poor regions
	gen var = 0 if !mi(region)
	replace var = 1 if iso == "BE" & region == "Wallonia"
	replace var = 1 if iso == "CH" & region == "French"
	replace var = 1 if iso == "CA" & region == "Quebec"
	replace var = 1 if iso == "GB" & inlist(region, "Scotland", "Wales")
	replace var = 1 if iso == "IT" & inlist(region, "South", "Islands")

	replace var = 1 if iso == "BR" & region == "Northeast"
	replace var = 1 if iso == "BW" & region != "Gaborone"
	replace var = 1 if iso == "GH" & region == "Northern"
	replace var = 1 if iso == "ID" & region == "Sulawesi / East"
	*replace var = 1 if iso == "IN" & region == ""
	replace var = 1 if iso == "IQ" & region == "Southern Iraq"
	replace var = 1 if iso == "KR" & region != "Seoul-Gyeonggi"
	replace var = 1 if iso == "NG" & strpos(region, "North") > 0
	replace var = 1 if iso == "PE" & region == "South"
	replace var = 1 if iso == "PH" & region == "Mindanao"
	replace var = 1 if iso == "PK" & region == "Sindh"
	replace var = 1 if iso == "SN" & region != "West"
	replace var = 1 if iso == "TH" & inlist(region, "North", "Northeast")
	replace var = 1 if iso == "TR" & region == "South Eastern Anatolia"
	replace var = 1 if iso == "TW" & inlist(region, "South", "East")
	
	// Aggregate some votes to allow convergence in the multinomial model
	replace vote = "Other" if iso == "IN" & inlist(vote, "Other center", "Other right", "BJP") & year < 1990
	replace vote = "Other" if iso == "IN" & inlist(vote, "Other center", "Other right", "BJP") & year == 1999
	
	/*
	levelsof year, local(years)
	foreach y in `years'{
	levelsof vote if year == `y', local(parties)
	foreach party in `parties'{
		di "`party'"
		gen x = (vote == "`party'") if !mi(vote)
		sum x if year == `y' [aw=weight]
		if `r(mean)' < 0.05{
			replace vote = "Other" if vote == "`party'" & year == `y'
		}
		drop x
	}
	}
	*/
	
	// Group small regions together to avoid overfitting
	replace region = "Other" if iso == "IN" & inlist(region, "Goa", "Himachal Pradesh", "Puducherry", "Tripura", "Meghalaya") & year == 1999

	* encode variables
	foreach var of varlist vote2 religion race region{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	
	* fill in missing values
	foreach var of varlist inc educ agerec sex religion religious race rural emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	* generate indicators
	foreach var in vote_region_diff vote_region_difc vote_region_rsqu vote_region_rsqp{
		gen `var' = .
	}
	
	levelsof year, local(years)
	foreach y in `years'{
	*local y 1999
	di "`y'"
		// Top 10% - bottom 90%
		reg voteleft var if year == `y' [pw=weight]
		replace vote_region_diff = _b[var] if year == `y'
		
		reg voteleft var i.inc i.educ i.agerec i.sex i.religion i.religious i.rural i.emp i.marital  if year == `y' [pw=weight]
		replace vote_region_difc = _b[var] if year == `y'

		// R2 and multinomial pseudo R2		
		reg voteleft i.region if year == `y' [pw=weight]
		replace vote_region_rsqu = e(r2_a) if year == `y'
		
		mlogit vote2 i.region if year == `y' [pw=weight]
		replace vote_region_rsqp = e(r2_p) if year == `y'
	}
	
	// Format
	keep iso isoname west year year2 vote_*
	gduplicates drop
	tempfile temp
	save `temp'
restore
append using `temp'
}
}

renvars vote_*, pref(value)
greshape long value, i(iso year) j(var) string

drop if value == 0

* label
gen label = ""

gen group = ""

keep iso isoname west year year2 var label group value
order iso isoname west year year2 var label group value

// Add to database
levelsof var, local(dropvars)
tempfile temp
save `temp'

use "$work/gmp-macro", clear
foreach var in `dropvars'{
drop if var == "`var'"
}
append using `temp'
order iso isoname west year year2 var label group value
labdtch year2
save "$work/gmp-macro", replace



// -------------------------------------------------------------------------- //
// Regional inequalities: R-squared from OLS of region on quantile groups
// -------------------------------------------------------------------------- //

use "$work/gmp-inc", clear
drop if mi(region)
keep iso year
gduplicates drop
levelsof iso, local(countries)

// Generate variable of interest
clear
foreach c in `countries'{
	preserve
	di in red "`c'"
	*local c AU
	*local y 2016
	
	use iso isoname west year year2 region weight qinc if iso == "`c'" using "$work/gmp-inc", clear
	
	encode region, gen(var)
	levelsof year if !mi(region) & !mi(qinc), local(years)
	
	gen value = .
	
	foreach y in `years'{
		reg qinc i.var if year == `y' [pw=weight]
		replace value = e(r2_a) if year == `y'
	}

	keep iso isoname west year year2 value
	gduplicates drop

	tempfile temp
	save `temp'
	restore
append using `temp'
}

// Prepare for database
gen var = "ineq_region_rsqu"
gen label = "Regional OLS R-squared"
gen group = ""

// Graph for last year
/*
graph hbar value if year2 == 2010 & var == "ineq_region_rsqu", over(isoname, sort(value) label(labsize(vsmall))) ///
	bar(1, col(navy*0.8)) xsize(4) legend(off) yt("Regional inequality")
*/

// Add to database
levelsof var, local(dropvars)
tempfile temp
save `temp'

use "$work/gmp-macro", clear
foreach var in `dropvars'{
drop if var == "`var'"
}
append using `temp'
order iso isoname west year year2 var label group value
sort iso year var
labdtch year2
save "$work/gmp-macro", replace



// -------------------------------------------------------------------------- //
// Regional cleavages: R-squared from OLS
// -------------------------------------------------------------------------- //

use "$work/gmp", clear
drop if mi(region)
keep iso year
gduplicates drop
levelsof iso, local(countries)

// Generate variable of interest
clear
foreach c in `countries'{
	preserve
	di in red "`c'"
	*local c AR
	*local y 2016
	
	use iso isoname west year year2 region weight voteleft if iso == "`c'" using "$work/gmp", clear
	
	drop if mi(region)

	encode region, gen(var)
	levelsof year, local(years)
	
	gen value = .
	
	foreach y in `years'{
		reg voteleft i.var if year == `y' [pw=weight]
		replace value = e(r2_a) if year == `y'
	}

	keep iso isoname west year year2 value
	gduplicates drop

	tempfile temp
	save `temp'
	restore
append using `temp'
}

// Prepare for database
gen var = "vote_region_rsqu"
gen label = "Regional cleavage (OLS R-squared)"
gen group = ""

// Graph for last year
/*
graph hbar value if year2 == 2010 & var == "vote_region_rsqu", over(isoname, sort(value) label(labsize(vsmall))) ///
	bar(1, col(navy*0.8)) xsize(5) legend(off) yt("Regional cleavages (R-squared)")
*/

// Add to database
levelsof var, local(dropvars)
tempfile temp
save `temp'

use "$work/gmp-macro", clear
foreach var in `dropvars'{
drop if var == "`var'"
}
append using `temp'
order iso isoname west year year2 var label group value
sort iso year var
labdtch year2
save "$work/gmp-macro", replace


// -------------------------------------------------------------------------- //
// Regional cleavage: R-squared of multinomial model
// -------------------------------------------------------------------------- //

use "$work/gmp", clear
drop if mi(region)
keep iso year
gduplicates drop
levelsof iso, local(countries)

// Generate variable of interest
clear
foreach c in `countries'{
	preserve
	di in red "`c'"
qui{	
	*local c IN
	*local y 2016
	use iso isoname west year year2 region weight vote if iso == "`c'" using "$work/gmp", clear

	drop if mi(region)

	encode region, gen(var)
	
	// Define vote as other if vote share is lower than 10%
	levelsof year, local(years)
	foreach y in `years'{
	levelsof vote if year == `y', local(parties)
	foreach party in `parties'{
		di "`party'"
		gen x = (vote == "`party'") if !mi(vote)
		sum x if year == `y' [aw=weight]
		if `r(mean)' < 0.1{
			replace vote = "Other" if vote == "`party'" & year == `y'
		}
		drop x
	}
	}
	
	* small fix for India
	replace vote = "Other" if iso == "IN" & vote == "Other center"
	
	encode vote, gen(votevar)
	
	// Model
	levelsof year, local(years)
	gen value = .
	
	foreach y in `years'{
		mlogit votevar i.var if year == `y' [pw=weight]
		replace value = e(r2_p) if year == `y'
	}

	keep iso isoname west year year2 value
	gduplicates drop

	tempfile temp
	save `temp'
	restore
append using `temp'
}
}

// Prepare for database
gen var = "vote_region_rsqp"
gen label = "Regional cleavage (Multinomial logit R-squared)"
gen group = ""

// Graph for last year
/*
graph hbar value if year2 == 2010 & var == "vote_region_rsqp", over(isoname, sort(value) label(labsize(vsmall))) ///
	bar(1, col(navy*0.8)) xsize(5) legend(off) yt("Regional cleavages (Multinomial R-squared)")
*/

// Add to database
levelsof var, local(dropvars)
tempfile temp
save `temp'

use "$work/gmp-macro", clear
foreach var in `dropvars'{
drop if var == "`var'"
}
append using `temp'
order iso isoname west year year2 var label group value
sort iso year var
labdtch year2
save "$work/gmp-macro", replace
