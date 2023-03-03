
// -------------------------------------------------------------------------- //
// Class inequalities and cleavages: all indicators
// -------------------------------------------------------------------------- //

use "$work/gmp-inc", clear
drop if mi(class)
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c PT
	use if iso == "`c'" using "$work/gmp-inc", clear
	drop if mi(class)
	
	* encode some variables
	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	
	* fill control variables
	foreach var of varlist inc educ agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	* invert class variable
	replace class = 1 - class

	* generate variables
	foreach var in ineq_class_qdif vote_class_diff vote_class_difi vote_class_difc{
		gen `var' = .
	}
	
	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012
	di "`y'"
	
		// Inequalities: average quantile difference
		cap reg pinc class if year == `y' [pw=weight]
		cap replace ineq_class_qdif = _b[class] if year == `y'

		// Cleavage
		cap reg voteleft class if year == `y' [pw=weight]
		cap replace vote_class_diff = _b[class] if year == `y'
		
		cap reg voteleft class i.inc i.educ if year == `y' [pw=weight]
		cap replace vote_class_difi = _b[class] if year == `y'

		// Cleavage after controls
		cap reg voteleft class i.inc i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		cap replace vote_class_difc = _b[class] if year == `y'
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
replace label = "Class income quantile difference (pp)" if var == "ineq_class_qdif"
replace label = "Class cleavage" if var == "vote_class_diff"
replace label = "Class cleavage (after controls)" if var == "vote_class_difc"
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







