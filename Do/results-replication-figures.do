// -------------------------------------------------------------------------- //
// Core left/right robustness
// -------------------------------------------------------------------------- //

import excel "$results/Original_GMP2021.xlsx", sheet("r_multi_avg") firstrow clear
keep year year2 zero gr1_educ_dc90 gr1_educ_olf gr1_inc_dc90 gr1_inc_olf unb_educ_dc90 unb_educ_olf unb_inc_dc90 unb_inc_olf
rename * *_original
rename year_original year
rename year2_original year2
rename zero_original zero
save "$results/r_multi_avg_original.dta", replace

import excel "$results/GMP2021.xlsx", sheet("r_multi_avg") firstrow clear
keep year year2 zero gr1_educ_dc90 gr1_educ_olf gr1_inc_dc90 gr1_inc_olf unb_educ_dc90 unb_educ_olf unb_inc_dc90 unb_inc_olf
save "$results/r_multi_avg_replication.dta", replace

merge 1:1 year year2 zero using "$results/r_multi_avg_original.dta"
drop _merge

label variable gr1_educ_dc90_original "Baseline"
label variable gr1_educ_olf_original "Excl. green"
label variable gr1_educ_olf "Core left/right replication"
label variable gr1_inc_dc90_original "Baseline"
label variable gr1_inc_olf_original "Excl. green"
label variable gr1_inc_olf "Core left/right replication"

twoway (line zero year2, lcolor(black)) (connected gr1_educ_dc90_original year2, mcolor(red%50) msymbol(smcircle) lcolor(red%50)) (connected gr1_educ_olf_original year2, mcolor(red%50) msymbol(smcircle_hollow) lcolor(red%50) lpattern(dash)) (connected gr1_educ_olf year2, mcolor(red) msymbol(smcircle) lcolor(red) lpattern(longdash)) (connected gr1_inc_dc90_original year2, mcolor(blue%50) msymbol(smsquare) lcolor(blue%50)) (connected gr1_inc_olf_original year2, mcolor(blue%50) msymbol(smsquare_hollow) lcolor(blue%50) lpattern(dash)) (connected gr1_inc_olf year2, mcolor(blue) msymbol(smsquare) lcolor(blue) lpattern(longdash)), ytitle("") ylabel(-20(5)15, grid glcolor(black%5)) xtitle("") xlabel(1955 " " 1960 "1961-65" 1965 " " 1970 "1971-75" 1975 " " 1980 "1981-85" 1985 " " 1990 "1991-95" 1995 " " 2000 "2001-05" 2005 " " 2010 "2011-15" 2015 " ", grid glcolor(black%5)) legend(order(2 3 4 5 6 7) cols(3)) graphregion(fcolor(white)) plotregion(fcolor(white))
graph export "$results/robustness_core-left-right_balanced.pdf", as(pdf) replace

label variable unb_educ_dc90_original "Baseline"
label variable unb_educ_olf_original "Excl. green"
label variable unb_educ_olf "Core left/right replication"
label variable unb_inc_dc90_original "Baseline"
label variable unb_inc_olf_original "Excl. green"
label variable unb_inc_olf "Core left/right replication"

twoway (line zero year2, lcolor(black)) (connected unb_educ_dc90_original year2, mcolor(red%50) msymbol(smcircle) lcolor(red%50)) (connected unb_educ_olf_original year2, mcolor(red%50) msymbol(smcircle_hollow) lcolor(red%50) lpattern(dash)) (connected unb_educ_olf year2, mcolor(red) msymbol(smcircle) lcolor(red) lpattern(longdash)) (connected unb_inc_dc90_original year2, mcolor(blue%50) msymbol(smsquare) lcolor(blue%50)) (connected unb_inc_olf_original year2, mcolor(blue%50) msymbol(smsquare_hollow) lcolor(blue%50) lpattern(dash)) (connected unb_inc_olf year2, mcolor(blue) msymbol(smsquare) lcolor(blue) lpattern(longdash)), ytitle("") ylabel(-20(5)15, grid glcolor(black%5)) xtitle("") xlabel(1955 " " 1960 "1961-65" 1965 " " 1970 "1971-75" 1975 " " 1980 "1981-85" 1985 " " 1990 "1991-95" 1995 " " 2000 "2001-05" 2005 " " 2010 "2011-15" 2015 " ", grid glcolor(black%5)) legend(order(2 3 4 5 6 7) cols(3)) graphregion(fcolor(white)) plotregion(fcolor(white))
graph export "$results/robustness_core-left-right_unbalanced.pdf", as(pdf) replace

// -------------------------------------------------------------------------- //
// Top 20% vs. bottom 80% robustness
// -------------------------------------------------------------------------- //

import excel "$results/GMP2021.xlsx", sheet("r_multi_avg_bot50") firstrow clear
keep year year2 zero gr1_educ_dp50 gr1_educ_dc50 gr1_inc_dp50 gr1_inc_dc50 unb_educ_dp50 unb_educ_dc50 unb_inc_dp50 unb_inc_dc50
save "$results/r_multi_avg_top20_replication.dta", replace

label variable gr1_educ_dp50 "Top 20% vs. bottom 80%"
label variable gr1_educ_dc50 "After controls"
label variable gr1_inc_dp50 "Top 20% vs. bottom 80%"
label variable gr1_inc_dc50 "After controls"

twoway (line zero year2, lcolor(black)) (connected gr1_educ_dp50 year2, mcolor(red) msymbol(smcircle_hollow) lcolor(red) lpattern(dash)) (connected gr1_educ_dc50 year2, mcolor(red) msymbol(smcircle) lcolor(red)) (connected gr1_inc_dp50 year2, mcolor(blue) msymbol(smsquare_hollow) lcolor(blue) lpattern(dash)) (connected gr1_inc_dc50 year2, mcolor(blue) msymbol(smsquare) lcolor(blue)), ytitle("") ylabel(-25(5)20, grid glcolor(black%5)) xtitle("") xlabel(1955 " " 1960 "1961-65" 1965 " " 1970 "1971-75" 1975 " " 1980 "1981-85" 1985 " " 1990 "1991-95" 1995 " " 2000 "2001-05" 2005 " " 2010 "2011-15" 2015 " ", grid glcolor(black%5)) legend(order(2 3 4 5) cols(2)) graphregion(fcolor(white)) plotregion(fcolor(white))
graph export "$results/robustness_top20-vs-bottom80_balanced.pdf", as(pdf) replace

label variable unb_educ_dp50 "Top 20% vs. bottom 80%"
label variable unb_educ_dc50 "After controls"
label variable unb_inc_dp50 "Top 20% vs. bottom 80%"
label variable unb_inc_dc50 "After controls"

twoway (line zero year2, lcolor(black)) (connected unb_educ_dp50 year2, mcolor(red) msymbol(smcircle_hollow) lcolor(red) lpattern(dash)) (connected unb_educ_dc50 year2, mcolor(red) msymbol(smcircle) lcolor(red)) (connected unb_inc_dp50 year2, mcolor(blue) msymbol(smsquare_hollow) lcolor(blue) lpattern(dash)) (connected unb_inc_dc50 year2, mcolor(blue) msymbol(smsquare) lcolor(blue)), ytitle("") ylabel(-25(5)20, grid glcolor(black%5)) xtitle("") xlabel(1955 " " 1960 "1961-65" 1965 " " 1970 "1971-75" 1975 " " 1980 "1981-85" 1985 " " 1990 "1991-95" 1995 " " 2000 "2001-05" 2005 " " 2010 "2011-15" 2015 " ", grid glcolor(black%5)) legend(order(2 3 4 5) cols(2)) graphregion(fcolor(white)) plotregion(fcolor(white))
graph export "$results/robustness_top20-vs-bottom80_unbalanced.pdf", as(pdf) replace
