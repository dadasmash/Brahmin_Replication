
// -------------------------------------------------------------------------- //
// Generational inequalities and cleavages: all indicators
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
	drop if mi(age)
	
	* encode some variables
	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	
	* fill in missing values
	foreach var of varlist educ inc agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	* generate dummies and age quantiles

	gen young = (age <= 25) if !mi(age)
	gen old = (age >= 60) if !mi(age)

	bys iso year: egen sum = sum(weight)
	bys iso year (age): gen x = sum(weight)
	gen q = x / sum
	egen agep = cut(q), at(0(0.1)1)
	replace agep = 0.9 if mi(agep)
	replace agep = (agep * 10) + 1
	gen agep_10 = (agep == 10) if !mi(agep) // top 10%
	gen agep_1 = inlist(agep, 1, 2, 3, 4, 5) if !mi(agep) // bottom 50%
	
	* generate variables
	foreach var in ineq_age_dq65 ineq_age_dq25 ineq_age_dp90 ineq_age_dp10 ineq_age_rsqu vote_age_dq65 vote_age_dq25 vote_age_dp90 vote_age_dc90 vote_age_dp10 vote_age_rsqu ///
		vote_age_rsqp vote_age_dc25 vote_age_farr vote_age_farc{
		gen `var' = .
	}
	
	* simplify age variable
	replace age = floor(age/10) * 10
	replace age = 80 if age >= 80
	replace age = 20 if age <= 20
	
	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012
	
		// Inequalities: old vs. other
		cap reg pinc old if year == `y' [pw=weight]
		cap replace ineq_age_dq65 = _b[old] if year == `y'
		
		// Inequalities: young vs. other
		cap reg pinc young if year == `y' [pw=weight]
		cap replace ineq_age_dq25 = _b[young] if year == `y'

		// Inequalities: top 10%
		cap reg pinc agep_10 if year == `y' [pw=weight]
		cap replace ineq_age_dp90 = _b[agep_10] if year == `y'
		
		// Inequalities: bottom 50%
		cap reg pinc agep_1 if year == `y' [pw=weight]
		cap replace ineq_age_dp10 = _b[agep_1] if year == `y'

		// Inequalities: R2 of linear regression of rank on age
		cap reg pinc i.age if year == `y' [pw=weight]
		cap replace ineq_age_rsqu = e(r2_a) if year == `y'
		
		// Cleavages: old vs. other
		reg voteleft old if year == `y' [pw=weight]
		replace vote_age_dq65 = _b[old] if year == `y'
		
		// Cleavages: young vs. other
		reg voteleft young if year == `y' [pw=weight]
		replace vote_age_dq25 = _b[young] if year == `y'
		
		// Cleavages: young vs. other, after controls
		reg voteleft young i.sex i.educ i.inc i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_age_dc25 = _b[young] if year == `y'
		
		// Cleavages: young vs. other, far right
		cap reg voteext young if year == `y' [pw=weight]
		cap replace vote_age_farr = _b[young] if year == `y'
		
		cap reg voteext young i.sex i.educ i.inc i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		cap replace vote_age_farc = _b[young] if year == `y'

		// Cleavages: top 10%
		reg voteleft agep_10 if year == `y' [pw=weight]
		replace vote_age_dp90 = _b[agep_10] if year == `y'
		
		// Cleavages: top 10%, after controls
		reg voteleft agep_10 i.sex i.educ i.inc i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_age_dc90 = _b[agep_10] if year == `y'

		// Cleavages: bottom 50%
		reg voteleft agep_1 if year == `y' [pw=weight]
		replace vote_age_dp10 = _b[agep_1] if year == `y'

		// Cleavages: R2 of linear regression of rank on age
		reg voteleft i.age if year == `y' [pw=weight]
		replace vote_age_rsqu = e(r2_a) if year == `y'

		// Cleavages: pseudo R-squared
		mlogit vote2 i.age if year == `y' [pw=weight]
		replace vote_age_rsqp = e(r2_p) if year == `y'
		
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
replace label = "Generational income quantile difference, 65+ (pp)" if var == "ineq_age_dq65"
replace label = "Generational income quantile difference, 65+ (pp)" if var == "ineq_age_dq25"
replace label = "Generational income quantile difference, top 10% - bottom 90%" if var == "ineq_age_dp90"
replace label = "Generational income quantile difference, bottom 50% - top 50%" if var == "ineq_age_dp10"
replace label = "Generational inequalities, R-squared" if var == "ineq_age_rsqu"
replace label = "Generational cleavage: 65+ - 64-" if var == "vote_age_dq65"
replace label = "Generational cleavage: 25- - 26+" if var == "vote_age_dq25"
replace label = "Generational cleavage: 25- - 26+, after controls" if var == "vote_age_dc25"
replace label = "Generational cleavage: top 10% - bottom 90%" if var == "vote_age_dp90"
replace label = "Generational cleavage: bottom 50% - top 50%" if var == "vote_age_dp10"
replace label = "Generational cleavage: OLS R-squared" if var == "vote_age_rsqu"
replace label = "Generational cleavage: pseudo R-squared" if var == "vote_age_rsqp"
*assert !mi(label)

gen group = ""

keep iso isoname west year year2 var label group value
order iso isoname west year year2 var label group value

drop if mi(value)
drop if value == 0

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







