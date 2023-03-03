* rawdata source: https://api.worldbank.org/v2/en/indicator/SP.POP.TOTL?downloadformat=csv
*download population data from world bank. copy and paste into Stata 

encode var2,gen(country)
sort country 
expand 62
sort country

gen pop=.
forvalue i=1/62{
local j=`i'+4
bys country: replace pop=var`j' if _n ==`i'
}

gen year=.
forvalue i=1/62{
bys country: replace year=1959+`i' if _n ==`i'
} 

drop var3-var66
*keep the balance panel countries according to main dataset
keep if var1=="Australia"|var1=="Canada"|var1=="Switzerland"|var1=="Germany"|var1=="Denmark"|var1=="France"|var1=="United Kingdom"|var1=="Italy"|var1=="Netherlands"|var1=="Norway"|var1=="Sweden"|var1=="United States"

rename var1 isoname
rename var2 iso

replace iso="AU" if isoname=="Australia"
replace iso="CA" if isoname=="Canada"
replace iso="CH" if isoname=="Switzerland"
replace iso="DE" if isoname=="Germany"
replace iso="DK" if isoname=="Denmark"
replace iso="FR" if isoname=="France"
replace iso="GB" if isoname=="United Kingdom"
replace iso="IT" if isoname=="Italy"
replace iso="NL" if isoname=="Netherlands"
replace iso="NO" if isoname=="Norway"
replace iso="SE" if isoname=="Sweden"
replace iso="US" if isoname=="United States"

save data_pop,replace