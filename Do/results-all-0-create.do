
// -------------------------------------------------------------------------- //
// Create empty dataset to incorporate indicators
// -------------------------------------------------------------------------- //

use "$work/gmp", clear
keep iso isoname year2 west
drop if _n>=1
gen var = ""
gen label = ""
gen group = ""
gen value = .
order iso isoname west year year2 var label group value*
save "$work/gmp-macro", replace
