
// Merge Gethin-Martinez-Piketty (GMP) dataset with Comparative Manifesto Project dataset

// -------------------------------------------------------------------------- //
// Merge GMP and CMP
// -------------------------------------------------------------------------- //

// Education
use if west == 1 using "$work/gmp-educ", clear
gcollapse (mean) geduc_1 geduc_2 geduc_3 [pw=weight], by(iso year vote votegroup)
tempfile temp
save `temp'

// Income
use if west == 1 using "$work/gmp-inc", clear
gcollapse (mean) ginc_1 ginc_2 ginc_3 [pw=weight], by(iso year vote)
merge 1:1 iso year vote using `temp', nogen
save `temp', replace

// All other variables
use if west == 1 using "$work/gmp", clear

ta agerec, gen(agerec_)
gen rel_non = (religion == "None") if !mi(religion)
gen rel_chr = inlist(religion, "Catholic", "Other Christian") if !mi(religion)

gcollapse (mean) agerec_* sex rural rel_non rel_chr class lrs [pw=weight], by(iso year vote)
merge 1:1 iso year vote using `temp', nogen

// Multiply by 100
ds year iso year vote votegroup lrs, not
foreach var of varlist `r(varlist)'{
	replace `var' = `var' * 100
}

// Recode parties to match with CMP
drop if mi(vote)
drop if vote == "Other"

// Aggregate parties not reported separately in CMP dataset but separated in GMP, and rename others
replace vote = "Liberal" if vote == "National" & iso == "AU" & year == 1963

replace vote = "PS" if vote == "SP" & iso == "BE" & inlist(year, 1974, 1977)
replace vote = "FDF" if vote == "RW" & iso == "BE" & inlist(year, 1985, 1987)
replace vote = "PRLW" if vote == "PRL" & iso == "BE" & year == 1991

replace vote = "MSI" if vote == "MSI-DN" & iso == "IT" & year == 1968
replace vote = "MSI-DN" if vote == "MSI" & iso == "IT" & inlist(year, 1972, 1983, 1987)
replace vote = "PSIUP" if vote == "PSU" & iso == "IT" & inlist(year, 1968, 1972)
replace vote = "PRC" if vote == "RC" & iso == "IT" & inlist(year, 1992, 1994, 1996)
replace vote = "Lega" if vote == "LEGHE NORD" & iso == "IT"
replace vote = "Lega" if vote == "LEGA" & iso == "IT"
replace vote = "Lega" if vote == "LEGA NORD" & iso == "IT"
replace vote = "PPI" if vote == "PATTO SEGNI" & iso == "IT" & year == 1994 // alliance PPI / Segni Pact
replace vote = "PPI" if vote == "POPOLARI" & iso == "IT" & year == 1996
replace vote = "Italian Renewal" if vote == "LISTA DINI" & iso == "IT" & year == 1996
replace vote = "Party of Italian Communists" if vote == "COMUNISTI ITALIANI" & iso == "IT" & year == 2001
replace vote = "Rose in the Fist" if strpos(vote, "ROSE IN THE FIST") > 0 & iso == "IT" & year == 2006
replace vote = "VERDI" if vote == "VERDI+COMUNISTI ITALIANI" & iso == "IT" & year == 2006
replace vote = "LISTA DI PIETRO" if vote == "LISTA DI PIETRO/ITALIA DEI VALORI" & iso == "IT" & year == 2006
replace vote = "Olive Tree" if vote == "MARGHERITA/DS/ULIVO" & iso == "IT" & year == 2006
replace vote = "LISTA DI PIETRO" if vote == "IDV" & iso == "IT" & year == 2008

replace vote = "Green List Ecological Initiative" if vote == "Green Alternative" & iso == "LU" & year == 1994

replace vote = "Centre Party" if vote == "Centrists-Liberals" & iso == "NO"
replace vote = "Centre Party" if vote == "Centrists-Liberals-Christians" & iso == "NO"

replace vote = "APU" if vote == "PCTP/MRPP" & inlist(year, 1983, 1985)
replace vote = "CDU" if vote == "PCTP/MRPP" & inlist(year, 1987, 1991)
replace vote = "PPD/PSD" if vote == "PSD" & inlist(year, 1995)
replace vote = "CDS/PP" if vote == "CDS" & inlist(year, 2002, 2005, 2009)
replace vote = "CDU" if vote == "PCP-PEV (CDU)" & inlist(year, 2019)

replace vote = "Communist Party of Sweden" if vote == "Farmers League of Sweden" & iso == "SE"

// Merge with CMP
merge m:1 iso year vote using "$work/cmp", keepusing(isoname eco* val* lib_* aut_* rile welfare per101-per706 pervote) nogen

gen tokeep = 0
levelsof iso if !mi(agerec_1), local(countries)
foreach c in `countries'{
	replace tokeep = 1 if iso == "`c'"
}
keep if tokeep == 1
drop tokeep

keep if year >= 1945

* extrapolate party categories and recode a few missing (votegroup)
gsort iso vote -votegroup year
by iso vote: replace votegroup = votegroup[_n-1] if mi(votegroup)

replace votegroup = "Other" if mi(votegroup) & pervote < 5

replace votegroup = "Other" if iso == "FI" & vote == "Agrarian Union"
replace votegroup = "Communist" if iso == "NL" & vote == "Communist Party of the Netherlands"
replace votegroup = "Liberal" if iso == "LU" & vote == "Democratic Group"
replace votegroup = "Left" if iso == "NL" & vote == "Democratic Socialists‘70"
replace votegroup = "Liberal" if iso == "FI" & vote == "Finnish People’s Party"
replace votegroup = "Other" if iso == "IS" & vote == "National Preservation Party"
replace votegroup = "Liberal" if iso == "FI" & vote == "National Progressive Party"
replace votegroup = "Communist" if iso == "PT" & vote == "PCTP/MRPP"
replace votegroup = "Liberal" if iso == "BE" & vote == "PL"
replace votegroup = "Far right" if iso == "AU" & vote == "Palmer United Party"
replace votegroup = "Other" if iso == "IE" & vote == "Party of the Land" // Clann na Talmhan, agrarian
replace votegroup = "Liberal" if iso == "LU" & vote == "Patriotic and Democratic Group"
replace votegroup = "New left" if iso == "IS" & vote == "People's Front of Iceland"
replace votegroup = "Other" if iso == "IS" & vote == "People’s Party"
replace votegroup = "Other" if iso == "FR" & vote == "Progress and Modern Democracy"
replace votegroup = "Right" if iso == "NL" & vote == "PvdV"
replace votegroup = "Right" if iso == "FR" & vote == "Rally for the French People - Gaullists"
replace votegroup = "Other" if iso == "IE" & vote == "Republican Party" // Clann na Poblachta, republican
replace votegroup = "Right" if iso == "FR" & vote == "Republican Party of Liberty - Conservatives"
replace votegroup = "Old left" if iso == "GB" & vote == "Social Democratic Party"
replace votegroup = "Left" if iso == "IT" & vote == "Socialist Party of Italian Workers"
replace votegroup = "Other" if iso == "CH" & vote == "Swiss Motorists’ Party"
replace votegroup = "Left" if iso == "IS" & vote == "United Socialist Party"

assert !mi(votegroup)

sort iso year vote

save "$work/gmp-cmp-party", replace




// -------------------------------------------------------------------------- //
// Merge GMP and CMP - micro dataset
// -------------------------------------------------------------------------- //

foreach file in "gmp" "gmp-educ" "gmp-inc"{
di "`file'"

	use "$work/`file'", clear
	keep if west == 1

	// Aggregate parties not reported separately in CMP dataset but separated in GMP, and rename others
	replace vote = "PS" if vote == "SP" & iso == "BE" & inlist(year, 1974, 1977)
	replace vote = "FDF" if vote == "RW" & iso == "BE" & inlist(year, 1985, 1987)
	replace vote = "PRLW" if vote == "PRL" & iso == "BE" & year == 1991

	replace vote = "MSI" if vote == "MSI-DN" & iso == "IT" & year == 1968
	replace vote = "MSI-DN" if vote == "MSI" & iso == "IT" & inlist(year, 1972, 1983, 1987)
	replace vote = "PSIUP" if vote == "PSU" & iso == "IT" & inlist(year, 1968, 1972)
	replace vote = "PRC" if vote == "RC" & iso == "IT" & inlist(year, 1992, 1994, 1996)
	replace vote = "Lega" if vote == "LEGHE NORD" & iso == "IT"
	replace vote = "Lega" if vote == "LEGA" & iso == "IT"
	replace vote = "Lega" if vote == "LEGA NORD" & iso == "IT"
	replace vote = "PPI" if vote == "PATTO SEGNI" & iso == "IT" & year == 1994 // alliance PPI / Segni Pact
	replace vote = "PPI" if vote == "POPOLARI" & iso == "IT" & year == 1996
	replace vote = "Italian Renewal" if vote == "LISTA DINI" & iso == "IT" & year == 1996
	replace vote = "Party of Italian Communists" if vote == "COMUNISTI ITALIANI" & iso == "IT" & year == 2001
	replace vote = "Rose in the Fist" if strpos(vote, "ROSE IN THE FIST") > 0 & iso == "IT" & year == 2006
	replace vote = "VERDI" if vote == "VERDI+COMUNISTI ITALIANI" & iso == "IT" & year == 2006
	replace vote = "LISTA DI PIETRO" if vote == "LISTA DI PIETRO/ITALIA DEI VALORI" & iso == "IT" & year == 2006
	replace vote = "Olive Tree" if vote == "MARGHERITA/DS/ULIVO" & iso == "IT" & year == 2006
	replace vote = "LISTA DI PIETRO" if vote == "IDV" & iso == "IT" & year == 2008

	replace vote = "Green List Ecological Initiative" if vote == "Green Alternative" & iso == "LU" & year == 1994

	replace vote = "Centre Party" if vote == "Centrists-Liberals" & iso == "NO"
	replace vote = "Centre Party" if vote == "Centrists-Liberals-Christians" & iso == "NO"

	replace vote = "APU" if vote == "PCTP/MRPP" & inlist(year, 1983, 1985)
	replace vote = "CDU" if vote == "PCTP/MRPP" & inlist(year, 1987, 1991)
	replace vote = "PPD/PSD" if vote == "PSD" & inlist(year, 1995)
	replace vote = "CDS/PP" if vote == "CDS" & inlist(year, 2002, 2005, 2009)
	replace vote = "CDU" if vote == "PCP-PEV (CDU)" & inlist(year, 2019)

	replace vote = "Communist Party of Sweden" if vote == "Farmers League of Sweden" & iso == "SE"

	// Merge with CMP
	merge m:1 iso year vote using "$work/cmp", keep(master matched) keepusing(eco* val* lib_* aut_* rile welfare per101-per706) nogen

	save "$work/`file'-cmp", replace

}
