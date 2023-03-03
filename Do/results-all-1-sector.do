

// -------------------------------------------------------------------------- //
// Sectoral cleavages: all indicators
// -------------------------------------------------------------------------- //

use "$work/gmp", clear

drop if mi(sector)

levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c AU
	use if iso == "`c'" using "$work/gmp-inc", clear
	
	drop if mi(sector)
	
	gen var = sector
	
	* encode variables
	foreach var of varlist vote2 religion race region{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	
	* fill in missing values
	foreach var of varlist inc educ agerec sex religion religious race rural region emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	* generate indicators
	foreach var in vote_sector_diff vote_sector_difc ineq_sector_diff{
		gen `var' = .
	}
	
	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012
	
		// Cleavage
		reg voteleft var if year == `y' [pw=weight]
		replace vote_sector_diff = _b[var] if year == `y'
		
		reg voteleft var i.inc i.educ i.agerec i.sex i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_sector_difc = _b[var] if year == `y'
		
		// Inequality: average quantile difference
		replace qinc = 10 if qinc == 1
		replace qinc = 30 if qinc == 2
		replace qinc = 50 if qinc == 3
		replace qinc = 70 if qinc == 4
		replace qinc = 90 if qinc == 5
		cap reg qinc var if year == `y' [pw=weight]
		cap replace ineq_sector_qdif = _b[var] if year == `y'

	}

	// Format
	keep iso isoname west year year2 vote_* ineq_*
	gduplicates drop
	tempfile temp
	save `temp'
restore
append using `temp'
}
}

renvars vote_* ineq_*, pref(value)
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















