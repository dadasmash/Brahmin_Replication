
// -------------------------------------------------------------------------- //
// Educational cleavage, before and after controls
// -------------------------------------------------------------------------- //

use "$work/gmp-educ", clear
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c CA
	use if iso == "`c'" using "$work/gmp-educ", clear
	
	* drop Québec
	*drop if iso == "CA" & region == "Quebec"

	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	foreach var of varlist inc agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	foreach var in vote_educ_dp90 vote_educ_dc90 vote_educ_di90 vote_educ_dp50 vote_educ_dc50 vote_educ_di50 vote_educ_dp20 vote_educ_dc20 vote_educ_rsqu vote_educ_rsqp{
		gen `var' = .
	}	

	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012
	
		// Top 10% - bottom 90%
		reg voteleft geduc_3 if year == `y' [pw=weight]
		replace vote_educ_dp90 = _b[geduc_3] if year == `y'
		
		reg voteleft geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_educ_dc90 = _b[geduc_3] if year == `y'

		reg voteleft geduc_3 i.inc if year == `y' [pw=weight]
		replace vote_educ_di90 = _b[geduc_3] if year == `y'

		replace geduc_1 = qeduc_1 + qeduc_2 + qeduc_3 + qeduc_4 //REPLICATION: Top 20% - bottom 80%

		// Top 50% - bottom 50%
		reg voteleft geduc_1 if year == `y' [pw=weight]
		replace vote_educ_dp50 = _b[geduc_1] if year == `y'
		
		reg voteleft geduc_1 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_educ_dc50 = _b[geduc_1] if year == `y'		

		reg voteleft geduc_1 i.inc if year == `y' [pw=weight]
		replace vote_educ_di50 = _b[geduc_1] if year == `y'		
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

* label
gen label = ""
replace label = "Education cleavage: bottom 20% - top 80%" if var == "vote_educ_dp20"
replace label = "Education cleavage: bottom 50% - top 50%" if var == "vote_educ_dp50"
replace label = "Education cleavage: bottom 90% - top 10%" if var == "vote_educ_dp90"
replace label = "Education cleavage: bottom 20% - top 80% (after controls)" if var == "vote_educ_dc20"
replace label = "Education cleavage: bottom 50% - top 50% (after controls)" if var == "vote_educ_dc50"
replace label = "Education cleavage: bottom 90% - top 10% (after controls)" if var == "vote_educ_dc90"
replace label = "Education cleavage: R-squared" if var == "vote_educ_rsqu"
replace label = "Education cleavage: pseudo R-squared" if var == "vote_educ_rsqp"

drop if mi(value)

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
// Educational cleavage, before and after controls (primary / tertiary / continuous)
// -------------------------------------------------------------------------- //

use if west == 1 using "$work/gmp", clear
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c NO
	use if iso == "`c'" using "$work/gmp", clear

	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	foreach var of varlist inc agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	foreach var in vote_educ_dpc1 vote_educ_dcc1 vote_educ_dpc3 vote_educ_dcc3 vote_educ_dpqu vote_educ_dcqu{
		gen `var' = .
	}
	
	// Define education variables
	drop if mi(educ)
	
	gen educ_1 = (educ == 1) if !mi(educ)
	gen educ_3 = inlist(educ, 3, 4) if !mi(educ)
	
	* quantiles
	tempfile data
	save `data'
	
	gcollapse (sum) weight, by(iso year educ2)
	bys iso year (educ2): gen x = sum(weight)
	bys iso year (educ2): egen sum = sum(weight)
	gen rank = x / sum
	bys iso year (educ2): gen quantile = cond(_n == 1, 0, rank[_n-1])
	keep iso year educ2 quantile
	tempfile temp
	save `temp'
	
	use `data', clear
	merge m:1 iso year educ2 using `temp', nogen
	
	// Loop
	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012
	
		// University graduates - others
		reg voteleft educ_3 if year == `y' [pw=weight]
		replace vote_educ_dpc1 = _b[educ_3] if year == `y'
		
		reg voteleft educ_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_educ_dcc1 = _b[educ_3] if year == `y'

		// Primary - others
		reg voteleft educ_1 if year == `y' [pw=weight]
		replace vote_educ_dpc3 = _b[educ_1] if year == `y'
		
		reg voteleft educ_1 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_educ_dcc3 = _b[educ_1] if year == `y'
		
		// Continuous regression based on quantile variable
		reg voteleft quantile if year == `y' [pw=weight]
		replace vote_educ_dpqu = _b[quantile] if year == `y'
		
		reg voteleft quantile i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_educ_dcqu = _b[quantile] if year == `y'
		
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

* label
gen label = ""

drop if mi(value)

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
// Educational cleavage by party family, after controls
// -------------------------------------------------------------------------- //

// Education cleavage by party
use if west == 1 using "$work/gmp-educ", clear
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c NZ
	use if iso == "`c'" using "$work/gmp-educ", clear
	
	* changed on 2021/03/31: remove Fratelli d'Italia in Italy
	*replace voteext = 0 if vote == "FRATELLI D'ITALIA" & iso == "IT"
	
	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	foreach var of varlist inc agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	foreach var in educ_lef educ_rig educ_ril educ_gre educ_lib educ_ext educ_olf educ_chr educ_nlf educ_olr{
		gen `var' = .
	}
	
	* redefine old left as left - green, and old right as right - anti-immigration
	replace voteolf = voteleft - votegre
	replace voteolf = 0 if votegroup == "Communist" //REPLICATION: redefine Old left as Left - Green - Communist - Liberal - Regional
	replace voteolf = 0 if voteolf == 1 & votegroup == "Liberal"
	replace voteolf = 0 if voteolf == 1 & votegroup == "Regional"
	replace voteolr = voteright - voteext
	replace voteolr = 0 if voteolr == 1 & votegroup == "Liberal" //REPLICATION: redefine old right as Right - Anti-immigration - Liberal - Regional
	replace voteolr = 0 if voteolr == 1 & votegroup == "Regional"

	levelsof year, local(years)
	foreach y in `years'{
	*local y 2018
	
		// Generate coefficients
		reg voteleft geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace educ_lef = _b[geduc_3] if year == `y'

		reg voteright geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace educ_rig = _b[geduc_3] if year == `y'

		reg voteril geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace educ_ril = _b[geduc_3] if year == `y'

		reg votegre geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace educ_gre = _b[geduc_3] if year == `y'

		reg votelib geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace educ_lib = _b[geduc_3] if year == `y'
		
		reg voteext geduc_3 i.inc i.agerec i.sex i.religious i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace educ_ext = _b[geduc_3] if year == `y'

		reg voteolf geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace educ_olf = _b[geduc_3] if year == `y'

		reg votechr geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace educ_chr = _b[geduc_3] if year == `y'

		reg votenlf geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace educ_nlf = _b[geduc_3] if year == `y'

		reg voteolr geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace educ_olr = _b[geduc_3] if year == `y'
}
	
	// Format
	keep iso isoname west year year2 educ_*
	gduplicates drop
	tempfile temp
	save `temp'
restore
append using `temp'
}
}

renvars educ_*, pref(value)
greshape long value, i(iso year) j(var) string

drop if mi(value)

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

