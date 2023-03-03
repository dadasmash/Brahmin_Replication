
// -------------------------------------------------------------------------- //
// Ethnic cleavage: all indicators
// -------------------------------------------------------------------------- //

use "$work/gmp", clear

//REPLICATION: Remove manual race reclassifications
/*
replace race = region if iso == "IQ" // we take region as religion and ethnicity are bad variables
replace race = religion if iso == "PH" // we take religion to better capture the disprivileged Mindanao people
replace race = religion if iso == "FR"
replace race = ctrbirth if iso == "HK"
*/
drop if mi(race)


levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c IN
	use if iso == "`c'" using "$work/gmp-inc", clear
	
	* recode the voting variable
	replace voteleft = 1 if iso == "CA" & vote == "Bloc Quebecois"
	replace voteleft = (vote == "PDIP") if iso == "ID" & !mi(vote)

	* recode the ethnicity variable
	//REPLICATION: Remove manual race reclassifications
	/*
	replace race = region if iso == "IQ" // we take region as religion and ethnicity are bad variables
	replace race = religion if iso == "PH" // we take religion to better capture the disprivileged Mindanao people
	replace race = religion if iso == "FR"
	replace race = ctrbirth if iso == "HK"
	*/
	drop if mi(race)
	
	* in India, we drop Muslims
	//REPLICATION: Remove manual race reclassifications
	/*
	replace race = "Upper" if iso == "IN" & inlist(race, "Brahmins", "Other FC")
	drop if iso == "IN" & !inlist(race, "Upper", "SC/ST")
	*/
	
	* generate dummy for ethnic minority
	gen var = 0 if !mi(race)
	replace var = 1 if iso == "AR" & inlist(race, "Black", "Indigenous")
	replace var = 1 if iso == "BE" & inlist(race, "French")
	replace var = 1 if iso == "BR" & inlist(race, "Black", "Brown")
	replace var = 1 if iso == "BW" & !inlist(race, "Sotho-tswana")
	replace var = 1 if iso == "CA" & inlist(race, "French")
	replace var = 1 if iso == "CL" & inlist(race, "Indigenous")
	replace var = 1 if iso == "CO" & inlist(race, "Afro-Colombian")
	replace var = 1 if iso == "CR" & inlist(race, "Black / Mulatto")
	replace var = 1 if iso == "DZ" & inlist(race, "Arabic")
	replace var = 1 if iso == "FR" & inlist(race, "Muslim")
	replace var = 1 if iso == "GB" & inlist(race, "African / Caribbean", "Indian / Pakistani / Bangladeshi")
	replace var = 1 if iso == "GH" & inlist(race, "Gur", "Other")
	replace var = 1 if iso == "HK" & inlist(race, "Other")
	replace var = 1 if iso == "ID" & inlist(race, "Java")
	replace var = 1 if iso == "IL" & inlist(race, "Ashkenazi")
	replace var = 1 if iso == "IN" & inlist(race, "SC/ST")
	replace var = 1 if iso == "IQ" & inlist(race, "Southern Iraq")
	replace var = 1 if iso == "MX" & inlist(race, "Indigenous")
	replace var = 1 if iso == "MY" & !inlist(race, "Chinese") & !mi(race)
	replace var = 1 if iso == "NG" & inlist(race, "Hausa-Fulani")
	replace var = 1 if iso == "NZ" & inlist(race, "Maori", "Pacific")
	replace var = 1 if iso == "PE" & inlist(race, "Indigenous")
	replace var = 1 if iso == "PH" & inlist(race, "Muslim")
	replace var = 1 if iso == "PK" & inlist(race, "Sindhi")
	replace var = 1 if iso == "SN" & inlist(race, "Peul", "Serer", "Mandé")
	replace var = 1 if iso == "TR" & inlist(race, "Kurdish")
	replace var = 1 if iso == "TW" & inlist(race, "Hakka", "Minnan")
	replace var = 1 if iso == "US" & inlist(race, "Black")
	replace var = 1 if iso == "ZA" & inlist(race, "Black")
	
	* log income
	gen log = log(income)

	* encode variables
	foreach var of varlist vote2 religion race region{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	
	* fill in missing values
	foreach var of varlist inc educ agerec sex religion religious rural region emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	* generate indicators
	foreach var in vote_race_diff vote_race_difc vote_race_rsqu vote_race_rsqp ineq_race_qdif ineq_race_diff{
		gen `var' = .
	}
	
	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012
	
		// Cleavage difference
		reg voteleft var if year == `y' [pw=weight]
		replace vote_race_diff = _b[var] if year == `y'
		
		reg voteleft var i.inc i.educ i.agerec i.sex i.emp i.marital i.region i.rural if year == `y' [pw=weight]
		replace vote_race_difc = _b[var] if year == `y'

		// R2 and multinomial pseudo R2		
		reg voteleft i.race if year == `y' [pw=weight]
		replace vote_race_rsqu = e(r2_a) if year == `y'
		
		mlogit vote2 i.race if year == `y' [pw=weight]
		replace vote_race_rsqp = e(r2_p) if year == `y'

		// Ethnic inequality: average quantile difference
		replace qinc = 10 if qinc == 1
		replace qinc = 30 if qinc == 2
		replace qinc = 50 if qinc == 3
		replace qinc = 70 if qinc == 4
		replace qinc = 90 if qinc == 5
		cap reg qinc var if year == `y' [pw=weight]
		cap replace ineq_race_qdif = _b[var] if year == `y'
		
		// Ethnic inequality: % income difference based on WID data
		cap reg log var if year == `y' [pw=weight]
		cap replace ineq_race_diff = _b[var] if year == `y'

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
