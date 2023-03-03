
// -------------------------------------------------------------------------- //
// Union membership cleavage: all indicators
// -------------------------------------------------------------------------- //

use "$work/gmp-inc", clear
keep if west == 1
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c IT
	use if iso == "`c'" using "$work/gmp-inc", clear
	drop if mi(union)
		
	* encode some variables
	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}

	* fill in missing values
	foreach var of varlist agerec sex inc educ religion religious race rural region emp marital class{
		replace `var' = 99 if mi(`var')
	}

	* generate variables
	foreach var in vote_union_diff vote_union_difc{
		gen `var' = .
	}
	
	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012
				
		// Cleavages: union vs. non-union
		reg voteleft union if year == `y' [pw=weight]
		replace vote_union_diff = _b[union] if year == `y'

		reg voteleft union i.inc i.educ i.agerec i.sex i.emp i.marital i.region i.rural if year == `y' [pw=weight]
		replace vote_union_difc = _b[union] if year == `y'
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

