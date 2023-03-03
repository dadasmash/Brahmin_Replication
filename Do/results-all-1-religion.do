

// -------------------------------------------------------------------------- //
// Results: religious cleavage, Western countries
// -------------------------------------------------------------------------- //

use "$work/gmp", clear
drop if mi(religion)
keep if west == 1
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c IT
	
	use if iso == "`c'" using "$work/gmp", clear
	drop if mi(religion)
	
	// Prepare religion variables
	gen rel_none = (religion == "None") if !mi(religion) // no religion at all
	gen rel_nonr = (religion == "None" | religious == 1) if !mi(religion) // no religion + non-religious
	gen rel_nonm = (religion == "None" | religion == "Muslim" | religious == 1) if !mi(religion) // no religion + non-religious + Muslims
	gen rel_chri = (inlist(religion, "Catholic", "Other Christian", "Other", "Protestant")) if !mi(religion) // Christians
	gen rel_reli = (inlist(religious, 2, 3, 4) & !inlist(religion, "Muslim")) if !mi(religion) // religious non-Muslims
	
	* voters of the dominant religion (Catholic / Protestant) and who are religious
	* difficult cases: Germany, Switzerland, Netherlands (both religions)
	gen rel_chrd = 0 if !mi(religion)
	replace rel_chrd = 1 if religion == "Catholic" & iso == "AT"
	replace rel_chrd = 1 if religion == "Catholic" & iso == "BE"
	replace rel_chrd = 1 if religion == "Catholic" & iso == "CH"
	replace rel_chrd = 1 if religion == "Catholic" & iso == "DE"
	replace rel_chrd = 1 if religion == "Catholic" & iso == "ES"
	replace rel_chrd = 1 if religion == "Catholic" & iso == "FR"
	replace rel_chrd = 1 if religion == "Catholic" & iso == "IE"
	replace rel_chrd = 1 if religion == "Catholic" & iso == "IT"
	replace rel_chrd = 1 if religion == "Catholic" & iso == "LU"
	replace rel_chrd = 1 if religion == "Catholic" & iso == "NL"
	replace rel_chrd = 1 if religion == "Catholic" & iso == "PT"

	replace rel_chrd = 1 if inlist(religion, "Protestant", "Other Christian") & iso == "AU"
	replace rel_chrd = 1 if inlist(religion, "Protestant", "Other Christian") & iso == "CA"
	replace rel_chrd = 1 if inlist(religion, "Protestant", "Other Christian") & iso == "DE"
	replace rel_chrd = 1 if inlist(religion, "Protestant", "Other Christian") & iso == "DK"
	replace rel_chrd = 1 if inlist(religion, "Protestant", "Other Christian") & iso == "GB"
	replace rel_chrd = 1 if inlist(religion, "Protestant", "Other Christian") & iso == "IS"
	replace rel_chrd = 1 if inlist(religion, "Protestant", "Other Christian") & iso == "NL"
	replace rel_chrd = 1 if inlist(religion, "Protestant", "Other Christian") & iso == "NO"
	replace rel_chrd = 1 if inlist(religion, "Protestant", "Other Christian") & iso == "NZ"
	replace rel_chrd = 1 if inlist(religion, "Protestant", "Other Christian") & iso == "SE"
	replace rel_chrd = 1 if inlist(religion, "Protestant", "Other Christian") & iso == "US"
	
	* add restriction on religiosity, except for countries with no data
	gen nodata = 0
	*replace nodata = 1 if iso == "ES"
	*replace nodata = 1 if iso == "DE"
	*replace nodata = 1 if iso == "DE"
	
	replace rel_chrd = 0 if !inlist(religious, 2, 3, 4) & !mi(religion) & !mi(religious)
	
	// In Canada, exclude Québec which biases the secular-religious cleavage
	*drop if iso == "CA" & region == "Quebec" //REPLICATION: Include Québec
	
	// Small correction for converging multinomial models
	replace vote2 = "Other" if vote2 == "FDF" & iso == "BE" & year == 1977
	
	// Encode
	foreach var of varlist vote2 religion{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	
	// Prepare variables
	foreach var in vote_religion_none vote_religion_nonr vote_religion_nonm vote_religion_chri vote_religion_chrd vote_religion_reli vote_religion_rsqu vote_religion_rsqp{
		gen `var' = .
	}
		
	// Generate indicators
	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012
	di in red "`y'"
	
		// No religion
		reg voteleft rel_none if year == `y' [pw=weight]
		replace vote_religion_none = _b[rel_none] if year == `y'

		// No religion, non-religious
		reg voteleft rel_nonr if year == `y' [pw=weight]
		replace vote_religion_nonr = _b[rel_nonr] if year == `y'

		// No religion, non-religious, Muslims
		reg voteleft rel_nonm if year == `y' [pw=weight]
		replace vote_religion_nonm = _b[rel_nonm] if year == `y'
		
		// Christians
		reg voteleft rel_chri if year == `y' [pw=weight]
		replace vote_religion_chri = _b[rel_chri] if year == `y'

		// Dominant Christians
		reg voteleft rel_chrd if year == `y' [pw=weight]
		replace vote_religion_chrd = _b[rel_chrd] if year == `y'

		// Practising christians
		reg voteleft rel_reli if year == `y' [pw=weight]
		replace vote_religion_reli = _b[rel_reli] if year == `y'

		// R2 and multinomial pseudo R2
		reg voteleft i.religion if year == `y' [pw=weight]
		replace vote_religion_rsqu = e(r2_a) if year == `y'
		
		mlogit vote2 i.religion if year == `y' [pw=weight]
		replace vote_religion_rsqp = e(r2_p) if year == `y'
		
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
replace label = "Religious cleavage (no religion)" if var == "vote_religion_none"
replace label = "Religious cleavage (no religion, non-religious)" if var == "vote_religion_nonr"
replace label = "Religious cleavage (no religion, non-religious, Muslims)" if var == "vote_religion_nonm"
replace label = "Religious cleavage (religious)" if var == "vote_religion_reli"
replace label = "Religious cleavage (Christians)" if var == "vote_religion_chri"
replace label = "Religious cleavage (dominant Christians)" if var == "vote_religion_chrd"
replace label = "Religious cleavage (R-squared)" if var == "vote_religion_rsqu"
replace label = "Religious cleavage (Multinomial pseudo R-squared)" if var == "vote_religion_rsqp"
assert !mi(label)

drop if value == 0

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

