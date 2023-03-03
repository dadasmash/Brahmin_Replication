**** This Do File is to replicate Figure 5, 6, 7, 8 in 
**** Replication Report A comment on Gethin, Martínez-Toledano & Piketty (2022)

********************************
set more off 
clear all


******************************************
*Figure 8: Country Fixed Effect
*******************************************
global work "C:\Users\Da\Dropbox\Brahmin_Replication\Original_Data\Data"
****Part 1: Education
use "$work/gmp-educ", clear

	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	foreach var of varlist inc agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	foreach var in vote_educ_dp90 vote_educ_dc90 vote_educ_di90 vote_educ_dp50 vote_educ_dc50 vote_educ_di50 vote_educ_dp20 vote_educ_dc20 vote_educ_rsqu vote_educ_rsqp{
		gen `var' = .
	}	


**short balanced panel
gen gr1_ =1 if iso== "AU"|iso== "CA"|iso== "CH" |iso=="DE"|iso== "DK"|iso== "FR"|iso== "GB"|iso== "IT" |iso=="NL" |iso=="NO"|iso== "SE" |iso=="US"

keep if west==1 
keep if gr1_ ==1
encode iso,gen(country)

levelsof year, local(years)
	foreach y in `years'{
	dis "`y'"
	cap reghdfe voteleft geduc_3  i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight], ab(country) // different from edu dataset, the inc here is not branket range from 1 to 20, is some continous numbers
	cap replace vote_educ_dc90 = _b[geduc_3] if year == `y'
	}
bys year: keep if _n==1 


* recode year2
drop year2
gen year2 = 1955 if inrange(year, 1940, 1960)
replace year2 = 1960 if inrange(year, 1961, 1965)
replace year2 = 1965 if inrange(year, 1966, 1970)
replace year2 = 1970 if inrange(year, 1971, 1975)
replace year2 = 1975 if inrange(year, 1976, 1980)
replace year2 = 1980 if inrange(year, 1981, 1985)
replace year2 = 1985 if inrange(year, 1986, 1990)
replace year2 = 1990 if inrange(year, 1991, 1995)
replace year2 = 1995 if inrange(year, 1996, 2000)
replace year2 = 2000 if inrange(year, 2001, 2005)
replace year2 = 2005 if inrange(year, 2006, 2010)
replace year2 = 2010 if inrange(year, 2011, 2015)
replace year2 = 2015 if inrange(year, 2016, 2020)

gcollapse (mean)  vote_educ_dc90 , by(year2)

replace vote_educ_dc90= vote_educ_dc90* 100
renpfix vote_
rename educ_dc90 gr1_educ_dc90_fe

tempfile temp
save `temp'


***Part 2: Income
use "$work/gmp-inc", clear

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

**short balanced panel
gen gr1_ =1 if iso== "AU"|iso== "CA"|iso== "CH" |iso=="DE"|iso== "DK"|iso== "FR"|iso== "GB"|iso== "IT" |iso=="NL" |iso=="NO"|iso== "SE" |iso=="US"

keep if west==1 
keep if gr1_ ==1
encode iso,gen(country)

levelsof year, local(years)
foreach y in `years'{
dis "`y'"

		cap reghdfe voteleft ginc_3  i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight], ab(country) 
		cap replace vote_inc_dc90 = _b[ginc_3] if year == `y'
}
bys year: keep if _n==1 


* recode year2
drop year2
gen year2 = 1955 if inrange(year, 1940, 1960)
replace year2 = 1960 if inrange(year, 1961, 1965)
replace year2 = 1965 if inrange(year, 1966, 1970)
replace year2 = 1970 if inrange(year, 1971, 1975)
replace year2 = 1975 if inrange(year, 1976, 1980)
replace year2 = 1980 if inrange(year, 1981, 1985)
replace year2 = 1985 if inrange(year, 1986, 1990)
replace year2 = 1990 if inrange(year, 1991, 1995)
replace year2 = 1995 if inrange(year, 1996, 2000)
replace year2 = 2000 if inrange(year, 2001, 2005)
replace year2 = 2005 if inrange(year, 2006, 2010)
replace year2 = 2010 if inrange(year, 2011, 2015)
replace year2 = 2015 if inrange(year, 2016, 2020)

gcollapse (mean)  vote_inc_dc90 , by(year2)

replace vote_inc_dc90= vote_inc_dc90* 100
renpfix vote_
rename inc_dc90 gr1_inc_dc90_fe

// export excel year2 gr1_inc_dc90_fe gr1_educ_dc90_fe using "C:\Users\Da\Desktop\dataverse_files\Results\figure_fe_halfway.xls", firstrow(variables)

merge 1:1 year2 using `temp'
cap drop _merge

tempfile temp2
save `temp2'
*export figure_fe

***Part 3: merge with original results in GMT paper (results-paper-main.do)
************************************************************************************************
* The origin data of Brahmin_Replication in drop was changed at this time, so I downloaded the original data agian and run it on my PC, not dropbox
*****************************************************************
global work "C:\Users\Da\Desktop\dataverse_files\Data"
use "$work/gmp-macro", clear
keep if west == 1
drop if value == 0
replace value = value * 100
keep iso year year2 var value
greshape wide value, i(iso year year2) j(var) string
renpfix value

* aggregate some low-quality decades
replace year2 = 1970 if iso == "CA" & year2 == 1960
replace year2 = 1980 if iso == "IS" & year2 == 1970

* recode year2
drop year2
gen year2 = 1955 if inrange(year, 1940, 1960)
replace year2 = 1960 if inrange(year, 1961, 1965)
replace year2 = 1965 if inrange(year, 1966, 1970)
replace year2 = 1970 if inrange(year, 1971, 1975)
replace year2 = 1975 if inrange(year, 1976, 1980)
replace year2 = 1980 if inrange(year, 1981, 1985)
replace year2 = 1985 if inrange(year, 1986, 1990)
replace year2 = 1990 if inrange(year, 1991, 1995)
replace year2 = 1995 if inrange(year, 1996, 2000)
replace year2 = 2000 if inrange(year, 2001, 2005)
replace year2 = 2005 if inrange(year, 2006, 2010)
replace year2 = 2010 if inrange(year, 2011, 2015)
replace year2 = 2015 if inrange(year, 2016, 2020)


// Collapse by country
keep iso year year2 educ_* inc_* vote_*
gcollapse (mean) educ_* inc_* vote_*, by(iso year2)

keep iso year2 vote_inc_dp90 vote_educ_dp90 vote_inc_dc90 vote_educ_dc90 educ_olf educ_olr educ_gre educ_ext inc_olf inc_olr inc_gre inc_ext educ_rig inc_rig educ_lib inc_lib educ_ril inc_ril 
renvars educ_olf educ_olr educ_gre educ_ext inc_olf inc_olr inc_gre inc_ext educ_rig inc_rig educ_lib inc_lib educ_ril inc_ril, pref(vote_)

foreach var of varlist *ext{
	replace `var' = . if year2 < 1970
}
foreach var of varlist *gre{
	replace `var' = . if year2 < 1980
}

// Reshape
greshape long vote_, i(iso year2) j(var) string
greshape wide vote_, i(year2 var) j(iso) string
renpfix vote_

// Generate averages
egen unb_ = rowmean(AT AU BE CA CH DE DK ES FI FR GB IE IS IT LU NL NO NZ PT SE US) // unbalanced panel
egen gr1_ = rowmean(AU CA CH DE DK FR GB IT NL NO SE US) // short balanced panel
egen gr2_ = rowmean(DE FR GB IT NO SE US) // long balanced panel

keep year2 var unb_ gr1_ gr2_
greshape wide unb_ gr1_ gr2_, i(year2) j(var) string

gen year = "", before(year2)
replace year = "1948-60" if year2 == 1955
replace year = "1961-65" if year2 == 1960
replace year = "1966-70" if year2 == 1965
replace year = "1971-75" if year2 == 1970
replace year = "1976-80" if year2 == 1975
replace year = "1981-85" if year2 == 1980
replace year = "1986-90" if year2 == 1985
replace year = "1991-95" if year2 == 1990
replace year = "1996-00" if year2 == 1995
replace year = "2001-05" if year2 == 2000
replace year = "2006-10" if year2 == 2005
replace year = "2011-15" if year2 == 2010
replace year = "2016-20" if year2 == 2015

gen zero = 0
keep gr1_educ_dc90 gr1_inc_dc90 year2

// save "C:\Users\Da\Desktop\dataverse_files\Repli_Data\data_fig1.dta",replace 

merge 1:1 year2 using `temp2'
cap drop _merge

//  export excel year2 gr1_educ_dc90 gr1_inc_dc90 gr1_inc_dc90_fe gr1_educ_dc90_fe using "C:\Users\Da\Desktop\dataverse_files\Results\figure_fe.xls", firstrow(variables)

* import excel "C:\Users\Da\Desktop\dataverse_files\Repli_Data\figure_fe.xls", sheet("Sheet1") firstrow clear 

label var gr1_educ_dc90 "Edu: top 10% -bottom 90%" 
label var gr1_educ_dc90_fe  "Edu: top 10% -bottom 90% FE"
label var gr1_inc_dc90 "Inc: top 10% - bottom 90% " 
label var gr1_inc_dc90_fe "Inc: top 10% - bottom 90% FE"

***Part 4: draw Figure 8 (Country Fixed Effect)

label define year2_label 1955 "1948-60"  1960 "1961-65" 1965 "1966-70" 1970 "1971-75" 1975 "1976-80" 1980 "1981-85" 1985 "1986-90" 1990 "1991-95" 1995 "1996-00" 2000 "2001-2005" 2005 "2006-06" 2010 "2011-15" 2015 "2016-20"

label values year2 year2_label

twoway (connected gr1_educ_dc90 year2, mc(red) lc(red)) ///
(connected gr1_inc_dc90  year2,mc(blue) lc(blue) ms(S)) ///
(connected gr1_educ_dc90_fe  year2, lc(red%50) mc(red%50) lp(dash)) ///
(connected gr1_inc_dc90_fe  year2,lc(blue%50) mc(blue%50) lp(dash) ms(S)) ///
if year2>=1960, ///
yline(0,lc(black)) graphregion(color(white)) bgcolor(white) ///
xlabel(1960 1965 1970 1975 1980 1985 1990 1995 2000 2005 2010 2015, valuelabel angle(45)) ///
ylabel(-18(2)18, angle(0)) xtitle("Time period") ytitle("Percentage points", angle(0)) ///
legend(size(*.8))




/************************************************************************************************/

**************************************************************************************************
*Figure 5 coefficient (beta) weighted average by population
**************************************************************************************************

global work "C:\Users\Da\Desktop\dataverse_files\Data"

** load coefficients data from original paper 
use "$work/gmp-macro", clear
keep if west == 1

** merge with population data cleaned from the world bank
merge m:1 iso year using C:\Users\Da\Desktop\dataverse_files\Repli_Data\data_pop
keep if _merge==3

drop if value == 0
replace value = value * 100
keep iso year year2 var value pop

keep if iso=="AU"|iso=="CA"|iso=="CH"|iso=="DE"|iso=="DK"|iso=="FR"|iso=="GB"|iso=="IT"|iso=="NL"|iso=="NO"|iso=="SE"|iso=="US"


greshape wide value, i(iso year year2) j(var) string
renpfix value

* aggregate some low-quality decades
replace year2 = 1970 if iso == "CA" & year2 == 1960
replace year2 = 1980 if iso == "IS" & year2 == 1970

* recode year2
drop year2
gen year2 = 1955 if inrange(year, 1940, 1960)
replace year2 = 1960 if inrange(year, 1961, 1965)
replace year2 = 1965 if inrange(year, 1966, 1970)
replace year2 = 1970 if inrange(year, 1971, 1975)
replace year2 = 1975 if inrange(year, 1976, 1980)
replace year2 = 1980 if inrange(year, 1981, 1985)
replace year2 = 1985 if inrange(year, 1986, 1990)
replace year2 = 1990 if inrange(year, 1991, 1995)
replace year2 = 1995 if inrange(year, 1996, 2000)
replace year2 = 2000 if inrange(year, 2001, 2005)
replace year2 = 2005 if inrange(year, 2006, 2010)
replace year2 = 2010 if inrange(year, 2011, 2015)
replace year2 = 2015 if inrange(year, 2016, 2020)


// Collapse by country
keep iso year year2 educ_* inc_* vote_*  pop
gcollapse (mean) educ_* inc_* vote_* pop, by(iso year2)

keep iso year2 vote_inc_dp90 vote_educ_dp90 vote_inc_dc90 vote_educ_dc90 educ_olf educ_olr educ_gre educ_ext inc_olf inc_olr inc_gre inc_ext educ_rig inc_rig educ_lib inc_lib educ_ril inc_ril pop
renvars educ_olf educ_olr educ_gre educ_ext inc_olf inc_olr inc_gre inc_ext educ_rig inc_rig educ_lib inc_lib educ_ril inc_ril, pref(vote_)

foreach var of varlist *ext{
	replace `var' = . if year2 < 1970
}
foreach var of varlist *gre{
	replace `var' = . if year2 < 1980
}

// Reshape
greshape long vote_, i(iso year2) j(var) string
greshape wide vote_ pop, i(year2 var) j(iso) string
renpfix vote_

egen total_pop= rowmean(pop*) 


foreach var in AU CA CH DE DK FR GB IT NL NO SE US{
gen `var'_weighted=`var'*pop`var'/total_pop 
}


egen gr1_ = rowmean(AU_weighted CA_weighted CH_weighted DE_weighted DK_weighted FR_weighted GB_weighted IT_weighted NL_weighted NO_weighted SE_weighted US_weighted) // short balanced panel

keep year2 var gr1_ 
greshape wide gr1_ , i(year2) j(var) string

gen year = "", before(year2)
replace year = "1948-60" if year2 == 1955
replace year = "1961-65" if year2 == 1960
replace year = "1966-70" if year2 == 1965
replace year = "1971-75" if year2 == 1970
replace year = "1976-80" if year2 == 1975
replace year = "1981-85" if year2 == 1980
replace year = "1986-90" if year2 == 1985
replace year = "1991-95" if year2 == 1990
replace year = "1996-00" if year2 == 1995
replace year = "2001-05" if year2 == 2000
replace year = "2006-10" if year2 == 2005
replace year = "2011-15" if year2 == 2010
replace year = "2016-20" if year2 == 2015

gen zero = 0
keep gr1_educ_dc90 gr1_inc_dc90 year2
rename gr1_educ_dc90  gr1_educ_dc90_w 
rename gr1_inc_dc90 gr1_inc_dc90_w

merge 1:1 year2 using C:\Users\Da\Desktop\dataverse_files\Repli_Data\data_fig1
cap drop _merge

//  export excel year2 gr1_educ_dc90_w gr1_inc_dc90_w gr1_educ_dc90 gr1_inc_dc90 using "C:\Users\Da\Desktop\dataverse_files\Repli_Data\figure_weighted.xls", firstrow(variables)

// import excel "C:\Users\Da\Desktop\dataverse_files\Repli_Data\figure_weighted.xls", sheet("Sheet1") firstrow clear 

label var gr1_educ_dc90 "Edu: top 10% -bottom 90%" 
label var gr1_educ_dc90_w  "Edu: top 10% -bottom 90% Weighted"
label var gr1_inc_dc90 "Inc: top 10% - bottom 90% " 
label var gr1_inc_dc90_w "Inc: top 10% - bottom 90% Weighted"


***Weighted_FE
label define year2_label 1955 "1948-60"  1960 "1961-65" 1965 "1966-70" 1970 "1971-75" 1975 "1976-80" 1980 "1981-85" 1985 "1986-90" 1990 "1991-95" 1995 "1996-00" 2000 "2001-2005" 2005 "2006-06" 2010 "2011-15" 2015 "2016-20"

label values year2 year2_label

twoway (connected gr1_educ_dc90 year2, lc(red) mc(red)) ///
(connected gr1_inc_dc90  year2,lc(blue) mc(blue) ms(S)) ///
(connected gr1_educ_dc90_w  year2, lc(red%50) mc(red%50) lp(dash)) ///
(connected gr1_inc_dc90_w  year2,lc(blue%50) mc(blue%50) lp(dash) ms(S)) if year2>=1960, ///
yline(0,lc(black)) graphregion(color(white)) bgcolor(white) ///
xlabel(1960 1965 1970 1975 1980 1985 1990 1995 2000 2005 2010 2015, valuelabel angle(45)) ///
ylabel(-18(2)18, angle(0)) xtitle("Time period") ytitle("Percentage points", angle(0)) ///
legend(size(*.7))




/************************************************************************************************/



******************************************************************
*Figure 6 and Figure 7: omitting each control variable one by one
*********************************************************************

*** Part 1: Figure 6 (Educational cleavage, omitting each control variable one by one)

global work "C:\Users\Da\Dropbox\Brahmin_Replication\Original_Data\Data"

use "$work/gmp-educ", clear
**********
keep if west==1 


levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	use if iso == "`c'" using "$work/gmp-educ", clear
	

	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	foreach var of varlist inc agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	* 9 controls to drop, with 9 corresponding coefficients. and combine with the 1 original coefficient 
	forvalues i =0/9{
	gen vote_educ_dc90_`i'=.
	}

	levelsof year, local(years)
	foreach y in `years'{
	
	
		// Top 10% - bottom 90%
      ** Drop one of the 9 controls
		//www.statalist.org/forums/forum/general-stata-discussion/general/1378248-how-to-delete-an-explicit-string-from-a-local-containing-several-string-elements
		forvalues i =1/9{

		local control_list i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital
		local jj: word `i' of `control_list'
		local control_list_2: list control_list - jj
		dis  "`control_list_2'"
		reg voteleft geduc_3 i.inc `control_list_2' if year == `y' [pw=weight]
		replace vote_educ_dc90_`i' = _b[geduc_3] if year == `y'
		}
		
		* original regression
		reg voteleft geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_educ_dc90_0 = _b[geduc_3] if year == `y'
		
	}
	
	
	// Format
	keep iso isoname west year year2 vote_educ_dc90_*
	gduplicates drop
	tempfile temp
	save `temp'
restore
append using `temp'
}
}

renvars vote_*, pref(value)
greshape long value, i(iso year) j(var) string

drop if value == 0
replace value = value * 100

	
drop if mi(value)

gen group = ""

keep iso isoname west year year2 var group value
order iso isoname west year year2 var  group value


keep iso year year2 var value
greshape wide value, i(iso year year2) j(var) string
renpfix value

* aggregate some low-quality decades
replace year2 = 1970 if iso == "CA" & year2 == 1960
replace year2 = 1980 if iso == "IS" & year2 == 1970

* recode year2
drop year2
gen year2 = 1955 if inrange(year, 1940, 1960)
replace year2 = 1960 if inrange(year, 1961, 1965)
replace year2 = 1965 if inrange(year, 1966, 1970)
replace year2 = 1970 if inrange(year, 1971, 1975)
replace year2 = 1975 if inrange(year, 1976, 1980)
replace year2 = 1980 if inrange(year, 1981, 1985)
replace year2 = 1985 if inrange(year, 1986, 1990)
replace year2 = 1990 if inrange(year, 1991, 1995)
replace year2 = 1995 if inrange(year, 1996, 2000)
replace year2 = 2000 if inrange(year, 2001, 2005)
replace year2 = 2005 if inrange(year, 2006, 2010)
replace year2 = 2010 if inrange(year, 2011, 2015)
replace year2 = 2015 if inrange(year, 2016, 2020)


// Collapse by country
keep iso year year2 vote_*
gcollapse (mean) vote_*, by(iso year2)

keep iso year2 vote_educ_dc90_*



// Reshape
greshape long vote_, i(iso year2) j(var) string
greshape wide vote_, i(year2 var) j(iso) string
renpfix vote_

// Generate averages
egen unb_ = rowmean(AT AU BE CA CH DE DK ES FI FR GB IE IS IT LU NL NO NZ PT SE US) // unbalanced panel
egen gr1_ = rowmean(AU CA CH DE DK FR GB IT NL NO SE US) // short balanced panel
egen gr2_ = rowmean(DE FR GB IT NO SE US) // long balanced panel

// keep year2 var unb_ gr1_ gr2_
// greshape wide unb_ gr1_ gr2_, i(year2) j(var) string

keep year2 var gr1_ 
greshape wide  gr1_, i(year2) j(var) string

gen year = "", before(year2)
replace year = "1948-60" if year2 == 1955
replace year = "1961-65" if year2 == 1960
replace year = "1966-70" if year2 == 1965
replace year = "1971-75" if year2 == 1970
replace year = "1976-80" if year2 == 1975
replace year = "1981-85" if year2 == 1980
replace year = "1986-90" if year2 == 1985
replace year = "1991-95" if year2 == 1990
replace year = "1996-00" if year2 == 1995
replace year = "2001-05" if year2 == 2000
replace year = "2006-10" if year2 == 2005
replace year = "2011-15" if year2 == 2010
replace year = "2016-20" if year2 == 2015

gen zero = 0
// keep unb_educ_dc90 year2
// keep gr1_educ_dc90 year2
// keep gr1_educ_dc90 gr1_inc_dc90 year2

label var gr1_educ_dc90_1 "drop age group" 
label var gr1_educ_dc90_2 "drop sex" 
label var gr1_educ_dc90_3 "drop religion" 
label var gr1_educ_dc90_4 "drop religious" 
label var gr1_educ_dc90_5 "drop rural" 
label var gr1_educ_dc90_6 "drop region" 
label var gr1_educ_dc90_7 "drop race" 
label var gr1_educ_dc90_8 "drop employment" 
label var gr1_educ_dc90_9 "drop marital" 
label var gr1_educ_dc90_0 "Edu: top 10% -bottom 90% with controls" 

//
// save C:\Users\Da\Desktop\dataverse_files\Repli_Data\repli3_edu_drop_controls,replace

//use C:\Users\Da\Desktop\dataverse_files\Repli_Data\repli3_edu_drop_controls,clear 

***Plot Figure 6
label define year2_label 1955 "1948-60"  1960 "1961-65" 1965 "1966-70" 1970 "1971-75" 1975 "1976-80" 1980 "1981-85" 1985 "1986-90" 1990 "1991-95" 1995 "1996-00" 2000 "2001-2005" 2005 "2006-06" 2010 "2011-15" 2015 "2016-20"

label values year2 year2_label

twoway  ///
(connected  gr1_educ_dc90_1 year2, lc(green%30) mc(green%30) lp(dash)) ///
(connected  gr1_educ_dc90_2 year2, lc(green%30) mc(green%30) lp(dash)) ///
(connected  gr1_educ_dc90_3 year2, lc(green%30) mc(green%30) lp(dash)) ///
(connected  gr1_educ_dc90_4 year2, lc(green%30) mc(green%30) lp(dash)) ///
(connected  gr1_educ_dc90_5 year2, lc(green%30) mc(green%30) lp(dash)) ///
(connected  gr1_educ_dc90_6 year2, lc(green%30) mc(green%30) lp(dash)) ///
(connected  gr1_educ_dc90_7 year2, lc(green%30) mc(green%30) lp(dash)) ///
(connected  gr1_educ_dc90_8 year2, lc(green%30) mc(green%30) lp(dash)) ///
(connected  gr1_educ_dc90_9 year2, lc(green%30) mc(green%30) lp(dash)) ///
(connected gr1_educ_dc90_0 year2, lc(red) mc(red)) ///
if year2>=1960, ///
yline(0,lc(black)) graphregion(color(white)) bgcolor(white) ///
xlabel(1960 1965 1970 1975 1980 1985 1990 1995 2000 2005 2010 2015, valuelabel angle(45)) ///
ylabel(-16(2)12, angle(0)) xtitle("Time period") ytitle("Percentage points", angle(0)) ///
legend(size(*.8))
************



*** Part 2: Figure 7 (Income cleavage, omitting each control variable one by one)
global work "C:\Users\Da\Dropbox\Brahmin_Replication\Original_Data\Data"
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
	
	* 9 controls to drop, with 9 corresponding coefficients. and 1 original coefficient 
	forvalues i =0/9{
	gen vote_inc_dc90_`i'=.
	}
	
	drop if mi(inc)

	levelsof year, local(years)
	foreach y in `years'{
	
		// Top 10% - bottom 90%
		forvalues i =1/9{

		local control_list i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital
		local jj: word `i' of `control_list'
		local control_list_2: list control_list - jj
		dis  "`control_list_2'"
		reg voteleft ginc_3 i.educ `control_list_2' if year == `y' [pw=weight]
		replace vote_inc_dc90_`i' = _b[ginc_3] if year == `y'
		}
		
		reg voteleft ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight]
		replace vote_inc_dc90_0 = _b[ginc_3] if year == `y'		
				
	}
	
	// Format
	keep iso isoname west year year2 vote_inc_dc90_*
	gduplicates drop
	tempfile temp
	save `temp'
restore
append using `temp'
}
}

renvars vote_*, pref(value)
greshape long value, i(iso year) j(var) string

drop if value == 0
replace value = value * 100

drop if mi(value)

gen group = ""

keep iso isoname west year year2 var  group value
order iso isoname west year year2 var  group value

keep iso year year2 var value
greshape wide value, i(iso year year2) j(var) string
renpfix value

* aggregate some low-quality decades
replace year2 = 1970 if iso == "CA" & year2 == 1960
replace year2 = 1980 if iso == "IS" & year2 == 1970

* recode year2
drop year2
gen year2 = 1955 if inrange(year, 1940, 1960)
replace year2 = 1960 if inrange(year, 1961, 1965)
replace year2 = 1965 if inrange(year, 1966, 1970)
replace year2 = 1970 if inrange(year, 1971, 1975)
replace year2 = 1975 if inrange(year, 1976, 1980)
replace year2 = 1980 if inrange(year, 1981, 1985)
replace year2 = 1985 if inrange(year, 1986, 1990)
replace year2 = 1990 if inrange(year, 1991, 1995)
replace year2 = 1995 if inrange(year, 1996, 2000)
replace year2 = 2000 if inrange(year, 2001, 2005)
replace year2 = 2005 if inrange(year, 2006, 2010)
replace year2 = 2010 if inrange(year, 2011, 2015)
replace year2 = 2015 if inrange(year, 2016, 2020)


// Collapse by country
keep iso year year2 vote_*
gcollapse (mean) vote_*, by(iso year2)

keep iso year2 vote_inc_dc90_*



// Reshape
greshape long vote_, i(iso year2) j(var) string
greshape wide vote_, i(year2 var) j(iso) string
renpfix vote_

// Generate averages
egen unb_ = rowmean(AT AU BE CA CH DE DK ES FI FR GB IE IS IT LU NL NO NZ PT SE US) // unbalanced panel
egen gr1_ = rowmean(AU CA CH DE DK FR GB IT NL NO SE US) // short balanced panel
egen gr2_ = rowmean(DE FR GB IT NO SE US) // long balanced panel


keep year2 var gr1_ 
greshape wide  gr1_, i(year2) j(var) string

gen year = "", before(year2)
replace year = "1948-60" if year2 == 1955
replace year = "1961-65" if year2 == 1960
replace year = "1966-70" if year2 == 1965
replace year = "1971-75" if year2 == 1970
replace year = "1976-80" if year2 == 1975
replace year = "1981-85" if year2 == 1980
replace year = "1986-90" if year2 == 1985
replace year = "1991-95" if year2 == 1990
replace year = "1996-00" if year2 == 1995
replace year = "2001-05" if year2 == 2000
replace year = "2006-10" if year2 == 2005
replace year = "2011-15" if year2 == 2010
replace year = "2016-20" if year2 == 2015

gen zero = 0
// keep unb_educ_dc90 year2
// keep gr1_educ_dc90 year2
// keep gr1_educ_dc90 gr1_inc_dc90 year2

label var gr1_inc_dc90_1 "drop age group" 
label var gr1_inc_dc90_2 "drop sex" 
label var gr1_inc_dc90_3 "drop religion" 
label var gr1_inc_dc90_4 "drop religious" 
label var gr1_inc_dc90_5 "drop rural" 
label var gr1_inc_dc90_6 "drop region" 
label var gr1_inc_dc90_7 "drop race" 
label var gr1_inc_dc90_8 "drop employment" 
label var gr1_inc_dc90_9 "drop marital" 
label var gr1_inc_dc90_0 "Inc: top 10% -bottom 90% with controls" 

// save C:\Users\Da\Desktop\dataverse_files\Repli_Data\repli3_inc_drop_controls,replace
// use C:\Users\Da\Desktop\dataverse_files\Repli_Data\repli3_inc_drop_controls,clear 

***Plot Figure 7 
label define year2_label 1955 "1948-60"  1960 "1961-65" 1965 "1966-70" 1970 "1971-75" 1975 "1976-80" 1980 "1981-85" 1985 "1986-90" 1990 "1991-95" 1995 "1996-00" 2000 "2001-2005" 2005 "2006-06" 2010 "2011-15" 2015 "2016-20"

label values year2 year2_label

twoway  ///
(connected  gr1_inc_dc90_1 year2, lc(green%30) mc(green%30) lp(dash) ms(S)) ///
(connected  gr1_inc_dc90_2 year2, lc(green%30) mc(green%30) lp(dash) ms(S)) ///
(connected  gr1_inc_dc90_3 year2, lc(green%30) mc(green%30) lp(dash) ms(S)) ///
(connected  gr1_inc_dc90_4 year2, lc(green%30) mc(green%30) lp(dash) ms(S)) ///
(connected  gr1_inc_dc90_5 year2, lc(green%30) mc(green%30) lp(dash) ms(S)) ///
(connected  gr1_inc_dc90_6 year2, lc(green%30) mc(green%30) lp(dash) ms(S)) ///
(connected  gr1_inc_dc90_7 year2, lc(green%30) mc(green%30) lp(dash) ms(S)) ///
(connected  gr1_inc_dc90_8 year2, lc(green%30) mc(green%30) lp(dash) ms(S)) ///
(connected  gr1_inc_dc90_9 year2, lc(green%30) mc(green%30) lp(dash) ms(S)) ///
(connected gr1_inc_dc90_0 year2, lc(blue) mc(blue) ms(S)) ///
if year2>=1960, ///
yline(0,lc(black)) graphregion(color(white)) bgcolor(white) ///
xlabel(1960 1965 1970 1975 1980 1985 1990 1995 2000 2005 2010 2015, valuelabel angle(45)) ///
ylabel(-18(2)10, angle(0)) xtitle("Time period") ytitle("Percentage points", angle(0)) ///
legend(size(*.8))
************

/***************************************   Done!  **********************************************/




