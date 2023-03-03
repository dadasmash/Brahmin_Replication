
// -------------------------------------------------------------------------- //
// Run results
// -------------------------------------------------------------------------- //

// Import data
run "$do/import-cmp.do"
run "$do/merge-gmp-cmp.do"

// Create WID macro database
run "$do/results-all-0-create.do"
run "$do/results-all-1-age.do"
run "$do/results-all-1-center.do"
run "$do/results-all-1-class.do"
run "$do/results-all-1-educ.do" //REPLICATION
run "$do/results-all-1-house.do"
run "$do/results-all-1-inc.do" //REPLICATION
run "$do/results-all-1-race.do" //REPLICATION
run "$do/results-all-1-region.do" //REPLICATION
run "$do/results-all-1-religion.do" //REPLICATION
run "$do/results-all-1-rural.do"
run "$do/results-all-1-sector.do"
run "$do/results-all-1-sex.do"
run "$do/results-all-1-union.do"

// Run results
run "$do/results-paper-main.do" //REPLICATION
run "$do/results-paper-appendix.do"

// Replication results
run "$do/results-replication-figures.do" //REPLICATION
