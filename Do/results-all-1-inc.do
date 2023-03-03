
// -------------------------------------------------------------------------- //
// Income cleavage: all indicators
// -------------------------------------------------------------------------- //

use "$work/gmp-inc", clear
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c FR
	use if iso == "`c'" using "$work/gmp-inc", clear
	drop if mi(inc)
	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	foreach var of varlist educ agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	foreach var in vote_inc_dp90 vote_inc_dc90 vote_inc_di90 vote_inc_dp50 vote_inc_dc50 vote_inc_di50 vote_inc_dc50_region vote_inc_dc50_race ///
		vote_inc_dp20 vote_inc_dc20 vote_inc_dpqu vote_inc_dcqu vote_inc_rsqu vote_inc_rsqp{
		gen `var' = .
	}
	
	drop if mi(inc)

	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012
	
		// Top 10% - bottom 90%
		reg voteleft ginc_3 if year == `y' [pw=weight]
		replace vote_inc_dp90 = _b[ginc_3] if year == `y'
		
		reg voteleft ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_inc_dc90 = _b[ginc_3] if year == `y'

		reg voteleft ginc_3 i.educ if year == `y' [pw=weight]
		replace vote_inc_di90 = _b[ginc_3] if year == `y'

		replace ginc_1 = qinc_1 + qinc_2 + qinc_3 + qinc_4 //REPLICATION: Top 20% - bottom 80%

		// Top 50% - bottom 50%
		reg voteleft ginc_1 if year == `y' [pw=weight]
		replace vote_inc_dp50 = _b[ginc_1] if year == `y'
		
		reg voteleft ginc_1 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_inc_dc50 = _b[ginc_1] if year == `y'
		
		reg voteleft ginc_1 i.educ if year == `y' [pw=weight]
		replace vote_inc_di50 = _b[ginc_1] if year == `y'

		// Top 50% - bottom 50%, after specific controls
		reg voteleft ginc_1 i.rural i.region if year == `y' [pw=weight]
		replace vote_inc_dc50_region = _b[ginc_1] if year == `y'
		
		reg voteleft ginc_1 i.race if year == `y' [pw=weight]
		replace vote_inc_dc50_race = _b[ginc_1] if year == `y'

		// Top 80% - bottom 20%
		reg voteleft qinc_1 if year == `y' [pw=weight]
		replace vote_inc_dp20 = _b[qinc_1] if year == `y'
		
		reg voteleft qinc_1 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_inc_dc20 = _b[qinc_1] if year == `y'

		// R2 and multinomial pseudo R2
		reg voteleft i.pinc if year == `y' [pw=weight]
		replace vote_inc_rsqu = e(r2_a) if year == `y'
		
		mlogit vote2 i.pinc if year == `y' [pw=weight]
		replace vote_inc_rsqp = e(r2_p) if year == `y'
				
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
replace label = "Income cleavage: bottom 20% - top 80%" if var == "vote_inc_dc20"
replace label = "Income cleavage: bottom 50% - top 50%" if var == "vote_inc_dc50"
replace label = "Income cleavage: bottom 90% - top 10%" if var == "vote_inc_dc90"
replace label = "Income cleavage: bottom 20% - top 80% (after controls)" if var == "vote_inc_dp20"
replace label = "Income cleavage: bottom 50% - top 50% (after controls)" if var == "vote_inc_dp50"
replace label = "Income cleavage: bottom 90% - top 10% (after controls)" if var == "vote_inc_dp90"
replace label = "Income cleavage: R-squared" if var == "vote_inc_rsqu"
replace label = "Income cleavage: pseudo R-squared" if var == "vote_inc_rsqp"

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
// Income cleavage: continuous regression on quantiles
// -------------------------------------------------------------------------- //

use if west == 1 using "$work/gmp", clear
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c AU
	use if iso == "`c'" using "$work/gmp", clear
	drop if mi(inc)
	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	foreach var of varlist educ agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	foreach var in vote_inc_dpqu vote_inc_dcqu{
		gen `var' = .
	}
	
	drop if mi(inc)
	
	* quantiles
	tempfile data
	save `data'
	
	gcollapse (sum) weight, by(iso year inc)
	bys iso year (inc): gen x = sum(weight)
	bys iso year (inc): egen sum = sum(weight)
	gen rank = x / sum
	bys iso year (inc): gen quantile = cond(_n == 1, 0, rank[_n-1])
	keep iso year inc quantile
	tempfile temp
	save `temp'
	
	use `data', clear
	merge m:1 iso year inc using `temp', nogen

	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012

		// Continuous regression on quantile
		reg voteleft quantile if year == `y' [pw=weight]
		replace vote_inc_dpqu = _b[quantile] if year == `y'
		
		reg voteleft quantile i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_inc_dcqu = _b[quantile] if year == `y'

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
// Income cleavage by party family, after controls
// -------------------------------------------------------------------------- //

// Income cleavage by party
use if west == 1 using "$work/gmp-inc", clear
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c BE
	use if iso == "`c'" using "$work/gmp-inc", clear
	drop if mi(inc)
	
	* changed on 2021/03/31: try to remove Fratelli d'Italia in Italy
	*replace voteext = 0 if vote == "FRATELLI D'ITALIA" & iso == "IT"

	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	foreach var of varlist educ agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	foreach var in inc_lef inc_rig inc_ril inc_gre inc_lib inc_ext inc_olf inc_chr inc_nlf inc_olr{
		gen `var' = .
	}
	
	* redefined old left as left - green, and old right as right - anti-immigration
	replace voteolf = voteleft - votegre
	replace voteolf = 0 if votegroup == "Communist" //REPLICATION: redefine Old left as Left - Green - Communist - Liberal - Regional
	replace voteolf = 0 if voteolf == 1 & votegroup == "Liberal"
	replace voteolf = 0 if voteolf == 1 & votegroup == "Regional"
	replace voteolr = voteright - voteext
	replace voteolr = 0 if voteolr == 1 & votegroup == "Liberal" //REPLICATION: redefine old right as Right - Anti-immigration - Liberal - Regional
	replace voteolr = 0 if voteolr == 1 & votegroup == "Regional"

	levelsof year, local(years)
	foreach y in `years'{
	di "`y'"
	*local y 1972
	
		// Generate coefficients
		reg voteleft ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace inc_lef = _b[ginc_3] if year == `y'

		reg voteright ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace inc_rig = _b[ginc_3] if year == `y'

		reg voteril ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace inc_ril = _b[ginc_3] if year == `y'

		reg votegre ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace inc_gre = _b[ginc_3] if year == `y'

		reg votelib ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace inc_lib = _b[ginc_3] if year == `y'
		
		reg voteext ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace inc_ext = _b[ginc_3] if year == `y'

		reg voteolf ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace inc_olf = _b[ginc_3] if year == `y'

		reg votechr ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace inc_chr = _b[ginc_3] if year == `y'

		reg votenlf ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace inc_nlf = _b[ginc_3] if year == `y'

		reg voteolr ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace inc_olr = _b[ginc_3] if year == `y'
	}
	
	// Format
	keep iso isoname west year year2 inc_*
	gduplicates drop
	tempfile temp
	save `temp'
restore
append using `temp'
}
}

renvars inc_*, pref(value)
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

