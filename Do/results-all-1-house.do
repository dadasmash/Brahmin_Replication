
// -------------------------------------------------------------------------- //
// Home ownership: all indicators
// -------------------------------------------------------------------------- //

use if west == 1 using "$work/gmp", clear
drop if mi(house)
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c IT
	use if iso == "`c'" using "$work/gmp", clear
	drop if mi(house)
	
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
	foreach var in vote_house_diff vote_house_difc{
		gen `var' = .
	}
	
	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012

		reg voteleft house if year == `y' [pw=weight]
		replace vote_house_diff = _b[house] if year == `y'

		reg voteleft house i.sex i.agerec i.educ i.inc i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_house_difc = _b[house] if year == `y'

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

