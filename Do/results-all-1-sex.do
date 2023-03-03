
// -------------------------------------------------------------------------- //
// Gender inequalities and cleavages: all indicators
// -------------------------------------------------------------------------- //

use "$work/gmp-inc", clear
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c IT
	use if iso == "`c'" using "$work/gmp-inc", clear
	drop if mi(sex)
	
	* invert gender variable
	replace sex = 1 - sex
	
	* add sector of employment to employment status
	replace emp = 4 if sector == 1
	
	* encode some variables
	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}

	* fill in missing values
	foreach var of varlist agerec inc educ religion religious race rural region emp marital class{
		replace `var' = 99 if mi(`var')
	}

	* generate variables
	foreach var in ineq_sex_qdif vote_sex_diff vote_sex_difc{
		gen `var' = .
	}
	
	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012
	
		// Inequalities: average quantile difference
		cap reg pinc sex if year == `y' [pw=weight]
		cap replace ineq_sex_qdif = _b[sex] if year == `y'
				
		// Cleavages: women versus men
		reg voteleft sex if year == `y' [pw=weight]
		replace vote_sex_diff = _b[sex] if year == `y'

		reg voteleft sex i.agerec i.inc i.educ i.marital i.region i.rural i.religion i.religious i.emp if year == `y' [pw=weight]
		replace vote_sex_difc = _b[sex] if year == `y'

	}
	
	// Format
	keep iso isoname west year year2 ineq_* vote_*
	gduplicates drop
	tempfile temp
	save `temp'
restore
append using `temp'
}
}

renvars vote_* ineq_*, pref(value)
greshape long value, i(iso year) j(var) string

* label
gen label = ""
replace label = "Gender income quantile difference (pp)" if var == "ineq_sex_qdif"
replace label = "Gender cleavage: women - men" if var == "vote_sex_diff"
*assert !mi(label)

gen group = ""

keep iso isoname west year year2 var label group value
order iso isoname west year year2 var label group value

drop if mi(value)

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
// Gender inequalities and cleavages: control after control
// -------------------------------------------------------------------------- //

use "$work/gmp", clear
keep if west == 1
drop if inlist(iso, "DE", "FI")
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c FR
	use if iso == "`c'" using "$work/gmp", clear
	drop if mi(sex)
	
	* invert gender variable
	replace sex = 1 - sex
	
	* add sector of employment to employment status
	replace emp = 4 if sector == 1
	
	* encode some variables
	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	
	* fill in missing values
	foreach var of varlist agerec inc educ religion religious race rural region emp marital class{
		replace `var' = 99 if mi(`var')
	}
	
	* recreate missing values when variable is completely missing in survey
	foreach var of varlist inc educ religious{
	*local var inc
		bys iso year source: egen x = nvals(`var')
		bys iso year source: egen mean = mean(x)
		replace `var' = . if mi(mean) | mean == 1
		drop x mean
	}
	
	* occupation missing when no data on sector
	bys iso year source: egen x = nvals(sector)
	bys iso year source: egen mean = mean(x)
	replace emp = . if mi(mean)
	drop x mean
	
	* generate variables
	foreach var in ineq_sex_qdif vote_sex_diff vote_sex_dif1 vote_sex_dif2 vote_sex_dif3 vote_sex_dif4 vote_sex_dif5 vote_sex_dif6 vote_sex_dif7 {
		gen `var' = .
	}
	
	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012
	
		reg voteleft sex if year == `y' [pw=weight]
		replace vote_sex_dif1 = _b[sex] if year == `y'

		cap reg voteleft sex i.agerec i.inc i.educ if year == `y' [pw=weight]
		cap replace vote_sex_dif2 = _b[sex] if year == `y'

		cap reg voteleft sex i.religion i.religious if year == `y' [pw=weight]
		cap replace vote_sex_dif3 = _b[sex] if year == `y'
		
		cap reg voteleft sex i.agerec i.inc i.educ i.emp if year == `y' [pw=weight]
		cap replace vote_sex_dif4 = _b[sex] if year == `y'

		cap reg voteleft sex i.agerec i.inc i.educ i.religion i.religious i.emp if year == `y' [pw=weight]
		cap replace vote_sex_dif5 = _b[sex] if year == `y'
		
		cap reg voteleft sex i.agerec i.inc i.educ i.marital i.region i.rural i.class i.religion i.religious i.emp if year == `y' [pw=weight]
		cap replace vote_sex_dif6 = _b[sex] if year == `y'
	}
	
	// Format
	keep iso isoname west year year2 ineq_* vote_*
	gduplicates drop
	tempfile temp
	save `temp'
	
restore
append using `temp'
}
}

gduplicates drop
renvars vote_* ineq_*, pref(value)
greshape long value, i(iso year) j(var) string

* label
gen label = ""
replace label = "Gender income quantile difference (pp)" if var == "ineq_sex_qdif"
replace label = "Gender cleavage: women - men" if var == "vote_sex_diff"
*assert !mi(label)

gen group = ""

keep iso isoname west year year2 var label group value
order iso isoname west year year2 var label group value

drop if mi(value)

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


