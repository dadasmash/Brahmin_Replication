
// -------------------------------------------------------------------------- //
// Table A1: Data sources
// -------------------------------------------------------------------------- //

use "$work/gmp", clear

keep if west == 1

keep isoname year source
gduplicates drop

forval y = 1950/2020{
	replace source = subinstr(source, ", `y'", "", .)
	replace source = subinstr(source, "`y'", "", .)
}

* fix a few duplicates
replace source = "Eurobarometers" if strpos(source, "Eurobarometer") > 0
replace source = "European Social Survey" if isoname == "Austria" & year == 2002
replace source = "Eurobarometers" if isoname == "Belgium" & year == 1977
replace source = "CIS" if isoname == "Spain" & year == 2019
replace source = "CIS" if isoname == "Spain" & year == 2020
replace source = "Finnish Voter Barometers" if isoname == "Finland" & year == 2003
replace source = strtrim(strltrim(source))

replace source = "International Social Mobility and Politics File (Franklin et al. 1992)" if source == "ISMP"
replace source = "International Social Mobility and Politics File (Franklin et al. 1992)" if isoname == "Australia" & inrange(year, 1963, 1984)
replace source = "Swiss National Election Studies" if source == "Swiss NES"
replace source = "German Federal Election Studies" if source == "GESIS Data Archive" & isoname == "Germany"
replace source = "Centro de Investigaciones Sociológicas" if source == "CIS" & isoname == "Spain"
replace source = "Icelandic National Election Studies" if source == "ICENES"
replace source = "Italian National Election Studies" if source == "ITANES"
replace source = "Inter-university Consortium for Political and Social Research (ICPSR)" if source == "ICPSR"
replace source = "European Election Studies (EES)" if source == "EES"
replace source = "Dutch Parliamentary Election Studies" if source == "Dutch parliamentary election studies, cumulated file -"
replace source = "Dutch Parliamentary Election Studies" if source == "Dutch parliamentary election study"
replace source = "Norwegian National Election Studies" if source == "NES" & isoname == "Norway"
replace source = "New Zealand Election Studies" if source == "NZES"
replace source = "Comparative Study of Electoral Systems (CSES)" if source == "CSES"
replace source = "Swedish National Election Studies" if source == "SNES" & isoname == "Sweden"
replace source = "Portuguese Election Study" if isoname == "Portugal" & year == 2019

gduplicates drop
gduplicates list isoname year

sort isoname year

replace isoname = "UK" if isoname == "United Kingdom"
replace isoname = "US" if isoname == "United States"

export excel "$results/GMP2021.xlsx", sheet("r_sources") sheetreplace first(var)


// -------------------------------------------------------------------------- //
// Table A2: Main classification of political parties
// -------------------------------------------------------------------------- //

// This table was hand-coded in Excel.


// -------------------------------------------------------------------------- //
// Table A3: Detailed classification of political parties
// -------------------------------------------------------------------------- //

use "$work/gmp-cmp-party", clear

// Recode some parties before matching to new names
* Australia
replace vote = "Liberal" if vote == "National" & iso == "AU" & year == 1963

* Austria
replace vote = "Other" if inlist(vote, "Alliance for the Future of Austria", "Team Stronach", "Peter Pilz List", "G!LT", "KPO") & iso == "AT"

* Belgium
replace vote = "CD&V" if vote == "N-VA" & iso == "BE" & year == 2007 // CDV-NVA alliance
replace vote = "PRL" if vote == "RW" & iso == "BE" & year == 1991 // Liberals
replace vote = "PRL" if vote == "PRLW" & iso == "BE" & year == 1987 // Liberals
replace vote = "PCB" if vote == "PTB" & iso == "BE" & year <= 1987 // PCB before PTB
replace vote = "PRL" if vote == "RW" & iso == "BE" & year == 1987 // Liberals
replace vote = "PRLW" if vote == "RW" & iso == "BE" & year == 1985 // Liberals
replace vote = "PRLW" if vote == "RW" & iso == "BE" & year == 1981 // Liberals
replace vote = "RW" if vote == "PRLW" & iso == "BE" & year == 1974 // Liberals
replace vote = "PSB" if vote == "PS" & iso == "BE" & year == 1974 // Socialists
replace vote = "PSB" if vote == "SP" & iso == "BE" & year == 1974 // Socialists
replace vote = "PSB" if vote == "PS" & iso == "BE" & year == 1971 // Socialists
replace vote = "Other" if vote == "LDD" & iso == "BE" // too small
replace vote = "Other" if vote == "Rossem" & iso == "BE" // too small

* Denmark
foreach v in CC CWP G IND L MIN PEN SW{
replace vote = "Other" if vote == "`v'" & iso == "DK"
}

* Finland
replace vote = "Other" if vote == "Constitutional People's Party" & iso == "FI"
replace vote = "Other" if vote == "Democratic Alternative" & iso == "FI"
replace vote = "Other" if vote == "Liberal Party" & iso == "FI"
replace vote = "Other" if vote == "Pirate Party" & iso == "FI"
replace vote = "Other" if strpos(vote, "Social Democratic Union of Workers") > 0 & iso == "FI"
replace vote = "Other" if vote == "Socialist Workers' Party" & iso == "FI"

* France
replace vote = "Other" if vote == "CPNT" & iso == "FR" // Chasse pêche 2002
replace vote = "Other" if vote == "DL" & iso == "FR" // Démocratie libérale 2002
replace vote = "Other" if vote == "DLF" & iso == "FR" // debout la france
replace vote = "Other" if vote == "LCR" & iso == "FR" // communistes 2002
replace vote = "Other" if vote == "LO" & iso == "FR" // LO 2002
replace vote = "Other" if vote == "MDC" & iso == "FR" // chevènement 2002
replace vote = "Other" if vote == "MPF" & iso == "FR" // 1995, 2007
replace vote = "Other" if vote == "PRG" & iso == "FR" // 1978, 2002 uniquement
replace vote = "Other" if vote == "PSU" & iso == "FR" // a few years, low sample sizes

* Iceland
replace vote = "Other" if vote == "Citizens' Movement" & iso == "IS"
replace vote = "Other" if vote == "Citizens' Party" & iso == "IS"
replace vote = "Other" if vote == "Dawn" & iso == "IS"
replace vote = "Other" if vote == "Households Party" & iso == "IS"
replace vote = "Other" if vote == "Humanist Party" & iso == "IS"
replace vote = "Other" if vote == "Iceland Democratic Party" & iso == "IS"
replace vote = "Other" if vote == "Icelandic Movement" & iso == "IS"
replace vote = "Other" if vote == "National Party" & iso == "IS"
replace vote = "Other" if vote == "New Force" & iso == "IS"
replace vote = "Other" if vote == "People's Movement" & iso == "IS"
replace vote = "Other" if vote == "Right-Green People's Party" & iso == "IS"
replace vote = "Other" if vote == "Sudurlandslistann" & iso == "IS"
replace vote = "Other" if vote == "The Alliance of Social Democrats" & iso == "IS"
replace vote = "Other" if vote == "Union of Liberals and Leftists" & iso == "IS"
replace vote = "Other" if vote == "Vestfjardalistann" & iso == "IS"

* Ireland
replace vote = "Other" if vote == "Aontu" & iso == "IE"
replace vote = "Other" if vote == "Democratic Left" & iso == "IE"
replace vote = "Other" if vote == "People Before Profit" & iso == "IE"
replace vote = "Other" if vote == "Social Democrats" & iso == "IE"

* Italy
replace vote = "MARGHERITA" if vote == "DS" & iso == "IT" & year == 2001
replace vote = "Other" if vote == "ALL. DEM." & iso == "IT"
replace vote = "Other" if vote == "CD" & iso == "IT"
replace vote = "Other" if vote == "DEMOCRAZIA EUROPEA" & iso == "IT"
replace vote = "Other" if vote == "DESTRA" & iso == "IT"
replace vote = "Other" if vote == "DP" & iso == "IT"
replace vote = "Other" if vote == "FARE PER FERMARE" & iso == "IT"
replace vote = "Other" if vote == "FIAMMA TRICOLORE" & iso == "IT"
replace vote = "Other" if vote == "FLI" & iso == "IT"
replace vote = "Other" if vote == "GIRASOLE" & iso == "IT"
replace vote = "Other" if vote == "LA DESTRA" & iso == "IT"
replace vote = "Other" if strpos(vote, "PENSIONERS' PARTY") > 0 & iso == "IT"
replace vote = "Other" if vote == "PR" & iso == "IT"
replace vote = "Other" if vote == "PS" & iso == "IT"
replace vote = "Other" if vote == "RETE" & iso == "IT"
replace vote = "Other" if strpos(vote, "ROSE IN THE FIST") > 0 & iso == "IT"
replace vote = "Other" if vote == "SVP" & iso == "IT"
replace vote = "Other" if vote == "VERDI+COMUNISTI ITALIANI" & iso == "IT"

* Germany
replace vote = "" if vote == "Nichtwaehler" & iso == "DE"
replace vote = "Other" if vote == "Sonstige" & iso == "DE"
replace vote = "Other" if vote == "Unabhaengige" & iso == "DE"
replace vote = "GB" if vote == "BHE_Gesamtdeutscher_Block" & iso == "DE"
replace vote = "BP" if vote == "Bayernpartei" & iso == "DE"
replace vote = "DP" if vote == "Deutsche_Partei" & iso == "DE"
replace vote = "DZP" if vote == "Zentrum" & iso == "DE"
replace vote = "PDS" if vote == "PDS_Linke_Liste" & iso == "DE" & inlist(year, 1994, 1998, 2002)
replace vote = "Linke" if vote == "PDS_Linke_Liste" & iso == "DE" & inlist(year, 2005)
replace vote = "Gruene" if vote == "Gruene_Buendnis90" & iso == "DE"
replace vote = "Other" if vote == "KPD" & iso == "DE"
replace vote = "Other" if vote == "BP" & iso == "DE"

* France: replace as other all very small parties
replace vote = "FGDS" if vote == "SFIO" & iso == "FR" & year == 1967
replace vote = "PS" if vote == "PSU" & iso == "FR" & inlist(year, 1978, 1986)

replace vote = "Other" if vote == "ARLP" & iso == "FR"
replace vote = "Other" if vote == "Asselineau" & iso == "FR"
replace vote = "Other" if vote == "Cap21" & iso == "FR"
replace vote = "Other" if vote == "Cheminade" & iso == "FR"
replace vote = "Other" if vote == "Extreme left" & iso == "FR"
replace vote = "Other" if vote == "Extreme right" & iso == "FR"
replace vote = "Other" if vote == "FGDS" & iso == "FR"
replace vote = "Other" if vote == "FRS" & iso == "FR"
replace vote = "Other" if vote == "Lassalle" & iso == "FR"
replace vote = "Other" if vote == "MNR" & iso == "FR"
replace vote = "Other" if vote == "NPA" & iso == "FR"
replace vote = "Other" if vote == "Other greens" & iso == "FR"
replace vote = "Other" if vote == "Other left" & iso == "FR"
replace vote = "Other" if vote == "Other right" & iso == "FR"
replace vote = "Other" if vote == "PLE" & iso == "FR"
replace vote = "Other" if vote == "PT" & iso == "FR"
replace vote = "Other" if vote == "Poujad" & iso == "FR"
replace vote = "Other" if vote == "RS" & iso == "FR"

* Luxembourg
replace vote = "The Greens" if strpos(vote, "Green List Ecolog") & iso == "LU" & year == 1999
replace vote = "Green List Ecological Initiative" if vote == "Green Alternative" & iso == "LU" & year == 1994
replace vote = "Other" if vote == "National Movement" & iso == "LU"
replace vote = "Other" if vote == "The Left" & iso == "LU"			
replace vote = "Other" if vote == "" & iso == "LU"			
replace vote = "Other" if vote == "" & iso == "LU"			
replace vote = "Other" if vote == "" & iso == "LU"			
replace vote = "Other" if vote == "" & iso == "LU"

* Netherlands
replace vote = "Other" if vote == "CD" & iso == "NL"
replace vote = "Other" if vote == "DENK" & iso == "NL"
replace vote = "Other" if vote == "FvD" & iso == "NL"

* New Zealand
replace vote = "Other" if vote == "Progressive Coalition" & iso == "NZ"
replace vote = "Other" if vote == "NewLabour" & iso == "NZ"
replace vote = "Other" if vote == "New Zealand Party" & iso == "NZ"

* Norway
replace vote = "Red Party" if vote == "Red Electoral Alliance" & iso == "NO" & inlist(year, 2009, 2013)
replace vote = "Other" if vote == "Anders Lange's Party" & iso == "NO"
replace vote = "Other" if vote == "Centrists-Liberals" & iso == "NO"
replace vote = "Other" if vote == "Centrists-Liberals-Christians" & iso == "NO"
replace vote = "Other" if vote == "Coastal Party" & iso == "NO"
replace vote = "Other" if vote == "Communist Party" & iso == "NO"
replace vote = "Other" if vote == "Liberal People's Party" & iso == "NO"
replace vote = "Other" if vote == "New People's Party" & iso == "NO"
replace vote = "Other" if vote == "Red Electoral Alliance" & iso == "NO"
replace vote = "Other" if vote == "Red Party" & iso == "NO"

* Portugal
replace vote = "PCP-PEV (CDU)" if vote == "CDU" & iso == "PT" & year == 2015
replace vote = "Portugal Ahead" if vote == "PPD/PSD" & iso == "PT" & year == 2015 
replace vote = "CDS/PP" if vote == "CDS" & iso == "PT" & inlist(year, 2009, 2005, 2002)
replace vote = "PCP-PEV" if vote == "CDU" & iso == "PT" & inlist(year, 2009, 2005, 2002)
replace vote = "PPD/PSD" if vote == "PSD" & iso == "PT" & year == 1995
replace vote = "Other" if vote == "CHEGA" & iso == "PT"
replace vote = "Other" if vote == "MDP/CDE" & iso == "PT"
replace vote = "Other" if vote == "PAN" & iso == "PT"
replace vote = "Other" if vote == "PCTP" & iso == "PT"
replace vote = "Other" if vote == "PRD" & iso == "PT"

* Spain
replace vote = "Other" if vote == "Na-Bai" & iso == "ES"
foreach v in AIC CG CHA CUP EA EE EQUO EU FAC HB PA PACMA PAR PRC PRD PSA{
replace vote = "Other" if vote == "`v'" & iso == "ES"
}

* Sweden
replace vote = "Other" if vote == "Civic Unity" & iso == "SE"
replace vote = "Other" if vote == "Farmers League of Sweden" & iso == "SE"
replace vote = "Other" if vote == "Feminist Initiative" & iso == "SE"
replace vote = "Other" if vote == "Pirate Party" & iso == "SE"

* Switzerland
replace vote = "Other" if vote == "CSP/PCS" & iso == "CH"
replace vote = "Other" if vote == "EDU/UDF" & iso == "CH"
replace vote = "Other" if vote == "FPS/PSL" & iso == "CH"
replace vote = "Other" if vote == "Lega" & iso == "CH"
replace vote = "Other" if vote == "MCG" & iso == "CH"
replace vote = "Other" if vote == "PDA/PDT" & iso == "CH"
replace vote = "Other" if vote == "POCH" & iso == "CH"
replace vote = "Other" if vote == "SD/DS" & iso == "CH"
replace vote = "Other" if vote == "Sol" & iso == "CH"

// Rename using WPID names
preserve
	import excel "$work/wpid-parties.xlsx", sheet("parties_labels") first clear
	renvars Country Partycode PartynameEnglish / iso vote vote2
	keep iso vote vote2
	tempfile temp
	save `temp'
restore
merge m:1 iso vote using `temp', keep(master matched) nogen

replace vote2 = vote if mi(vote2)
drop vote
ren vote2 vote

// Filter duplicated categories
drop if vote == "Other" | mi(vote)
drop if vote == "Other (Other)"

replace votegroup = "Christian" if vote == "Christian Democratic and Flemish (CD&V)"
replace votegroup = "Liberal" if vote == "Liberal Reformist Party (PRL)"
replace votegroup = "Liberal" if vote == "Walloon Rally (RW)"
replace votegroup = "Liberal" if vote == "Front démocratique des francophones (FDF)"
replace votegroup = "New left" if vote == "Die Linke"
replace votegroup = "Green" if vote == "Unity List - Red-Green Alliance "
replace votegroup = "Old left" if vote == "Socialist Party (PS) / French Section of the Workers' International (SFIO)"
replace votegroup = "Christian" if vote == "Union for French Democracy (UDF) / Democratic Movement (MoDem)"
replace votegroup = "Old left" if vote == "Radical Party"
replace votegroup = "Old left" if vote == "Democrats of the Left (DS) / Margherita / Ulivo"
replace votegroup = "Old left" if vote == "Populars for Italy (PPI)"
replace votegroup = "Old left" if vote == "Italian Socialist Party of Proletarian Unity (PSIUP)"
replace votegroup = "Liberal" if vote == "Centre Party" & iso == "SE"
replace votegroup = "Right" if vote == "Centre Party" & iso == "NO"
replace votegroup = "Green" if vote == "United People Alliance (APU)"
replace votegroup = "Green" if vote == "Unitary Democratic Coalition (CDU, PCP-PEV)"
replace votegroup = "Christian" if vote == "Christian Democrats"
replace votegroup = "Communist" if vote == "Communist Party of Sweden"

// Normalize RILE to vote-share-weighted average by country
egen mean = wtmean(rile), weight(pervote) by(iso year)
replace rile = rile - mean
drop mean

// Normalize LRS to vote-share-weighted average by country
preserve
	use if west == 1 using "$work/gmp", clear
	drop if mi(votegroup) | mi(vote) | mi(lrs)
	gcollapse (mean) mean = lrs [pw=weight], by(iso year)
	tempfile temp
	save `temp'
restore
merge m:1 iso year using `temp', nogen
replace lrs = lrs - mean
drop mean

// Collapse
keep iso year vote votegroup pervote lrs rile
gcollapse (mean) pervote lrs rile, by(iso vote votegroup)

preserve
use "$work/gmp-cmp-party", clear
keep iso isoname
gduplicates drop
drop if mi(isoname)
tempfile temp
save `temp'
restore
merge m:1 iso using `temp', nogen

gsort isoname -pervote vote

gduplicates list iso vote

// Clean up and export
replace votegroup = "Conservatives / Christian Democrats" if inlist(votegroup, "Christian", "Old right", "Right")
replace votegroup = "Social Democrats / Socialists / Other left" if inlist(votegroup, "Left", "New left", "Old left")
replace votegroup = "Communists" if inlist(votegroup, "Communist")
replace votegroup = "Liberals / Social-liberals" if inlist(votegroup, "Liberal")
replace votegroup = "Greens" if inlist(votegroup, "Green")
replace votegroup = "Anti-immigration" if inlist(votegroup, "Far right")
replace votegroup = "Other" if inlist(votegroup, "Regional")

* drop small parties, except for a few small parties that we keep in the table
gen tokeep = 0
replace tokeep = 1 if vote == "One Nation Party"
replace tokeep = 1 if vote == "Communist Party (PCB)"
replace tokeep = 1 if strpos(vote, "Green Liberal Party") > 0 & iso == "CH"
drop if (pervote < 5 | mi(pervote)) & tokeep == 0
drop pervote tokeep

order iso isoname vote votegroup

* reduce size of some names
replace vote = "PCTP/MRPP" if vote == "Portuguese Workers' Communist Party (PCTP) / Re-Organized Movement of the Party of the Proletariat (MRPP)"
replace vote = "LR/UMP/RPR" if vote == "The Republicans (LR) / Union for a Popular Movement (UMP) / Rally for the Republic (RPR)"
replace vote = "UDR/UNR" if vote == "Union of Democrats for the Republic (UDR) / Union for the New Republic (UNR)"
replace vote = "UDF/MoDem" if vote == "Union for French Democracy (UDF) / Democratic Movement (MoDem)"
replace vote = "PS/SFIO" if vote == "Socialist Party (PS) / French Section of the Workers' International (SFIO)"
replace vote = "MRP/CD" if vote == "Popular Republican Movement (MRP) / Democratic Centre (CD)"
replace vote = "PPD/PSD" if vote == "Democratic Peoples' Party (PPD) / Social Democratic Party (PSD)"
replace vote = "CVP/PDC" if vote == "Christian Democratic People's Party of Switzerland (CVP/PDC)"
replace vote = "AP-PDP" if vote == "Popular Alliance - People's Democratic Party (AP-PDP)"

replace isoname = "UK" if isoname == "United Kingdom"

compress

export excel "$results/GMP2021.xlsx", sheet("classification") sheetreplace first(var)


// -------------------------------------------------------------------------- //
// Figure A1: see Figure 2
// Figure A2: see Figure 2
// -------------------------------------------------------------------------- //


// -------------------------------------------------------------------------- //
// Figure A3: Bottom 50%
// Figure A4: Bottom 50%, unbalanced panel
// -------------------------------------------------------------------------- //

// The transformation of party systems and the reversal of the education gradient
use "$work/gmp-macro", clear
keep if west == 1
drop if value == 0
replace value = value * 100
replace value = - value
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
keep iso year2 vote_inc_dp50 vote_educ_dp50 vote_inc_dc50 vote_educ_dc50

// Reshape
greshape long vote_, i(iso year2) j(var) string
greshape wide vote_, i(year2 var) j(iso) string
renpfix vote_

// Generate averages
egen unb_ = rowmean(AT AU BE CA CH DE DK ES FI FR GB IE IS IT LU NL NO NZ PT SE US)
egen gr1_ = rowmean(AU CA CH DE DK FR GB IT NL NO SE US)
egen gr2_ = rowmean(DE FR GB IT NO SE US)

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

order year year2 zero unb_educ_dp50 unb_educ_dc50 unb_inc_dp50 unb_inc_dc50 ///
	gr1_educ_dp50 gr1_educ_dc50 gr1_inc_dp50 gr1_inc_dc50 gr2_educ_dp50 gr2_educ_dc50 gr2_inc_dp50 gr2_inc_dc50

export excel "$results/GMP2021.xlsx", sheet("r_multi_avg_bot50") sheetreplace first(var)


// -------------------------------------------------------------------------- //
// Figure A5 to Figure A20: see Figure 2
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure A21 to Figure A22: see Figure 1
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure A23 to Figure A24
// -------------------------------------------------------------------------- //

use "$work/gmp-macro", clear
keep if west == 1

replace isoname = "Britain" if iso == "GB"

drop if value == 0
replace value = value * 100

* aggregate some low-quality decades
replace year2 = 1970 if iso == "CA" & year2 == 1960
replace year2 = 1980 if iso == "IS" & year2 == 1970

gcollapse (mean) value, by(isoname year2 var)
greshape wide value, i(var year2) j(isoname) string
renpfix value
foreach var of varlist _all{
	lab var `var' "`var'"
}

lab var New_Zealand "New Zealand"
lab var United_States "United States"
lab var var "Variable"
lab var year2 "Decade"

gen zero = 0, after(year2)

tostring year2, replace
replace year2 = "1950-59" if year2 == "1950"
replace year2 = "1960-69" if year2 == "1960"
replace year2 = "1970-79" if year2 == "1970"
replace year2 = "1980-89" if year2 == "1980"
replace year2 = "1990-99" if year2 == "1990"
replace year2 = "2000-09" if year2 == "2000"
replace year2 = "2010-20" if year2 == "2010"

// Generate averages
ds var year2 zero, not
egen mean = rowmean(`r(varlist)')
egen mean1 = rowmean(United_States Britain Australia New_Zealand Ireland Canada Sweden Norway Denmark Finland Iceland)
egen mean2 = rowmean(Austria Netherlands Switzerland Belgium Luxembourg Germany France Spain Italy Portugal)

lab var mean "Average"
lab var mean1 "Average"
lab var mean2 "Average"

keep if inlist(var, "educ_olf", "educ_olf", "educ_gre", "educ_ext", ///
	"inc_olf", "inc_olf", "inc_gre", "inc_ext")

export excel "$results/GMP2021.xlsx", sheet("r_fam_bycountry") sheetreplace first(varl)


// -------------------------------------------------------------------------- //
// Figure A25 to Figure A28: see Figure 1
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure A29 to Figure A32
// -------------------------------------------------------------------------- //

// Education
use if west == 1 using "$work/gmp-educ", clear

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

replace votegroup = "Right" if votegroup == "Christian"
replace votegroup = "Right" if votegroup == "Old right"
replace votegroup = "Left" if votegroup == "Old left"
replace votegroup = "Left" if votegroup == "New left"
replace votegroup = "Other" if votegroup == "Regional"

ta votegroup, gen(votegroup_)

gcollapse (mean) votegroup_7 votegroup_4 votegroup_1 votegroup_3 votegroup_2 votegroup_5 votegroup_6 [pw=weight], by(year2 geduc)
*graph bar votegroup_7 votegroup_4 votegroup_1 votegroup_3 votegroup_2 votegroup_5 votegroup_6 if geduc == 3, over(year2) stack

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

lab var votegroup_7 "Right"
lab var votegroup_4 "Left"
lab var votegroup_1 "Communist"
lab var votegroup_3 "Green"
lab var votegroup_2 "Far right"
lab var votegroup_5 "Liberal"
lab var votegroup_6 "Other"

order year geduc votegroup_4 votegroup_1 votegroup_3 votegroup_5 votegroup_7 votegroup_2 votegroup_6
sort year geduc votegroup_4 votegroup_1 votegroup_3 votegroup_5 votegroup_7 votegroup_2 votegroup_6

export excel "$results/GMP2021.xlsx", sheet("vote_geduc_comp2") sheetreplace first(varl)


// Income
use if west == 1 using "$work/gmp-inc", clear

drop if mi(inc)

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

replace votegroup = "Right" if votegroup == "Christian"
replace votegroup = "Right" if votegroup == "Old right"
replace votegroup = "Left" if votegroup == "Old left"
replace votegroup = "Left" if votegroup == "New left"
replace votegroup = "Other" if votegroup == "Regional"

ta votegroup, gen(votegroup_)

gcollapse (mean) votegroup_7 votegroup_4 votegroup_1 votegroup_3 votegroup_2 votegroup_5 votegroup_6 [pw=weight], by(year2 ginc)
*graph bar votegroup_7 votegroup_4 votegroup_1 votegroup_3 votegroup_2 votegroup_5 votegroup_6 if geduc == 3, over(year2) stack

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

lab var votegroup_7 "Right"
lab var votegroup_4 "Left"
lab var votegroup_1 "Communist"
lab var votegroup_3 "Green"
lab var votegroup_2 "Far right"
lab var votegroup_5 "Liberal"
lab var votegroup_6 "Other"

order year ginc votegroup_4 votegroup_1 votegroup_3 votegroup_5 votegroup_7 votegroup_2 votegroup_6
sort year ginc votegroup_4 votegroup_1 votegroup_3 votegroup_5 votegroup_7 votegroup_2 votegroup_6

export excel "$results/GMP2021.xlsx", sheet("vote_ginc_comp2") sheetreplace first(varl)


// -------------------------------------------------------------------------- //
// Figure A33 to Figure A36: Vote for Greens, anti-immigration, and left-wing parties by variable
// -------------------------------------------------------------------------- //

clear

foreach var in ginc geduc class rural center agerec sex religion{

preserve
	*local var religion
	use if west == 1 using "$work/gmp", clear
	if "`var'" == "ginc" use if west == 1 using "$work/gmp-inc", clear
	if "`var'" == "geduc" use if west == 1 using "$work/gmp-educ", clear

	drop if mi(`var')
	
	replace religion = "Other" if !inlist(religion, "Catholic", "Other Christian", "Protestant", "None", "")
	replace religion = "Protestant" if religion == "Other Christian"

	bys iso: egen x = max(year)
	keep if year == x
	drop x

	gcollapse votegre voteext voteleft [pw=weight], by(iso isoname `var')
	renvars votegre voteext voteleft, postfix("_")
	greshape wide votegre voteext voteleft, i(iso isoname) j(`var')
	renvars, presub("votegre" "votegre_`var'")
	renvars, presub("voteext" "voteext_`var'")
	renvars, presub("voteleft" "voteleft_`var'")

	tempfile temp
	save `temp'
restore
if "`var'" == "ginc" append using `temp'
else merge 1:1 isoname using `temp', nogen
}

order voteleft* *religion*, last

export excel "$results/GMP2021.xlsx", sheet("r_gre_ext_vote") sheetreplace first(var)


// -------------------------------------------------------------------------- //
// Figure A37 to Figure A38
// -------------------------------------------------------------------------- //

// Education
use if west == 1 using "$work/gmp-educ", clear

replace year2 = 1950 if year2 == 1940
replace year2 = 2010 if year2 == 2020

replace votegroup = "Right" if votegroup == "Christian"
replace votegroup = "Right" if votegroup == "Old right"
replace votegroup = "Left" if votegroup == "Old left"
replace votegroup = "Left" if votegroup == "New left"
replace votegroup = "Other" if votegroup == "Regional"

ta votegroup, gen(votegroup_)

gcollapse (mean) votegroup_7 votegroup_4 votegroup_1 votegroup_3 votegroup_2 votegroup_5 votegroup_6 [pw=weight], by(year2 geduc)
*graph bar votegroup_7 votegroup_4 votegroup_1 votegroup_3 votegroup_2 votegroup_5 votegroup_6 if geduc == 3, over(year2) stack

order geduc year2
sort geduc year2

tostring year2, replace force
replace year2 = "1948-59" if year2 == "1950"
replace year2 = "1960-69" if year2 == "1960"
replace year2 = "1970-79" if year2 == "1970"
replace year2 = "1980-89" if year2 == "1980"
replace year2 = "1990-99" if year2 == "1990"
replace year2 = "2000-09" if year2 == "2000"
replace year2 = "2010-20" if year2 == "2010"

export excel "$results/GMP2021.xlsx", sheet("vote_geduc_comp") sheetreplace first(var)

// Income
use if west == 1 using "$work/gmp-inc", clear

replace year2 = 1950 if year2 == 1940
replace year2 = 2010 if year2 == 2020

replace votegroup = "Right" if votegroup == "Christian"
replace votegroup = "Right" if votegroup == "Old right"
replace votegroup = "Left" if votegroup == "Old left"
replace votegroup = "Left" if votegroup == "New left"
replace votegroup = "Other" if votegroup == "Regional"

ta votegroup, gen(votegroup_)

gcollapse (mean) votegroup_7 votegroup_4 votegroup_1 votegroup_3 votegroup_2 votegroup_5 votegroup_6 [pw=weight], by(year2 ginc)
*graph bar votegroup_7 votegroup_4 votegroup_1 votegroup_3 votegroup_2 votegroup_5 votegroup_6 if geduc == 3, over(year2) stack

order ginc year2
sort ginc year2

tostring year2, replace force
replace year2 = "1948-59" if year2 == "1950"
replace year2 = "1960-69" if year2 == "1960"
replace year2 = "1970-79" if year2 == "1970"
replace year2 = "1980-89" if year2 == "1980"
replace year2 = "1990-99" if year2 == "1990"
replace year2 = "2000-09" if year2 == "2000"
replace year2 = "2010-20" if year2 == "2010"

export excel "$results/GMP2021.xlsx", sheet("vote_ginc_comp") sheetreplace first(var)


// -------------------------------------------------------------------------- //
// Figure A39 to Figure A40: income-education quadrant by party family (long period version)
// -------------------------------------------------------------------------- //

use "$work/gmp-macro", clear
keep if west == 1
drop if value == 0
replace value = value * 100
keep iso year year2 var value

greshape wide value, i(iso year year2 ) j(var) string
renpfix value

keep iso year year2  educ_* inc_*

* collapse by large periods
drop if year < 1960
gen period = 1 if inlist(year2, 1960, 1970, 1980)
replace period = 2 if inlist(year2, 2000, 2010)
drop if mi(period)

* collapse overall
gcollapse (mean) educ_* inc_*, by(iso year2 period)
gcollapse (mean) educ_* inc_*, by(year2 period)
gcollapse (mean) educ_* inc_*, by(period)

greshape long educ_ inc_, i(period) j(party) string
greshape wide educ_ inc_, i(party) j(period)
order party educ_2 inc_2 educ_1 inc_1

replace party = subinstr(party, "_", "", .)
replace party = "All left-wing" if party == "lef"
replace party = "Socialists / Soc.-dem. / Other left" if party == "olf"
replace party = "Greens" if party == "gre"
replace party = "New left" if party == "nlf"
replace party = "Christian" if party == "chr"
replace party = "Anti-immigration" if party == "ext"
replace party = "Social-liberals" if party == "lib"
replace party = "Conservatives / Christians" if party == "olr"
replace party = "All right-wing" if party == "rig"
replace party = "Conserv. / Christ. / Social-lib." if party == "ril"

sort party

export excel "$results/GMP2021.xlsx", sheet("quad_avg_long") sheetreplace first(varl)


// -------------------------------------------------------------------------- //
// Figure A41 to Figure A42: see Figure 5
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure A43 to Figure A49: see Figure 2
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure A50: Correlation between income and education
// -------------------------------------------------------------------------- //

use if west == 1 using "$work/gmp-educ", clear

* generate income quantile
preserve
	use if west == 1 using "$work/gmp", clear
	gcollapse (sum) weight, by(isoname year inc)
	drop if mi(inc)
	bys iso year (inc): gen x = sum(weight)
	bys iso year (inc): egen sum = sum(weight)
	gen qinc = x / sum
	keep iso year inc qinc
	tempfile temp
	save `temp'
restore
merge m:1 isoname year inc using `temp', nogen

*replace educ = 3 if educ == 4

*statsby "corr deduc qinc" corr = r(rho), by(iso year) clear

statsby corr = r(rho), by(isoname year) clear: corr deduc qinc [aw=weight]

replace year = floor(year / 10) * 10
replace year = 1950 if year == 1940
replace year = 2010 if year == 2020

gcollapse (mean) corr, by(isoname year)

greshape wide corr, i(year) j(isoname) string

foreach var of varlist corr*{
	local lab = subinstr(substr("`var'", 5, .), "_", " ", .)
	lab var `var' "`lab'"
}

egen mean = rowmean(corr*)
lab var mean "Average"

ren year year2
tostring year2, replace
replace year2 = "1948-59" if year2 == "1950"
replace year2 = "1960-69" if year2 == "1960"
replace year2 = "1970-79" if year2 == "1970"
replace year2 = "1980-89" if year2 == "1980"
replace year2 = "1990-99" if year2 == "1990"
replace year2 = "2000-09" if year2 == "2000"
replace year2 = "2010-20" if year2 == "2010"

export excel "$results/GMP2021.xlsx", sheet("cor_inc_edu") sheetreplace first(varl)


// -------------------------------------------------------------------------- //
// Figure A51: Kitagawa-Oaxaca-Blinder decomposition of educational cleavage 
// -------------------------------------------------------------------------- //

set matsize 10000

use if west == 1 using "$work/gmp-educ.dta", clear

* keep countries with good data
keep if inlist(iso, "AU", "DK", "FI", "FR", "GB", "NL") | inlist(iso, "NO", "NZ", "SE", "US")

*keep iso isoname year year2 weight voteleft deduc_10 inc agerec sex religion religious rural region race emp marital
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

keep if year2 >= 1960

// Harmonize some variables and set missing values to an arbitrary value
replace religion = "Other" if inlist(religion, "Buddhist", "Hindu", "Jewish", "Sikh")
replace religion = "Other Christian" if religion == "Protestant"

gen rel = 1 if religion == "None"
replace rel = 2 if religion == "Catholic"
replace rel = 3 if religion == "Other Christian"
replace rel = 4 if religion == "Muslim"
replace rel = 5 if religion == "Other"
label define religion 1 "Religion: None" 2 "Religion: Catholic" 3 "Religion: Other Christian" 4 "Religion: Muslim" 5 "Religion: Other"
label values rel religion
drop religion
ren rel religion

replace region = "Region: " + region if !mi(region)
replace region = "Region: Gotland" if region == "Region: Götland" & iso == "SE" // issue with special characters in Excel
replace race = "Race/ethnicity/language: " + race if !mi(race)

foreach var of varlist vote2 region race{
	ren `var' x
	encode x, gen(`var')
	drop x
}
foreach var of varlist educ inc agerec sex religion religious rural region race emp marital union sector house class{
	replace `var' = 999 if mi(`var')
}

replace religious = 3 if religious == 4
replace emp = 3 if emp == 2

gen election = iso + string(year)
encode election, gen(e)

// Run Oaxaca
gen explained = .
gen unexplained = .
*levelsof iso, local(countries)
*foreach c in `countries'{
	levelsof year2, local(years) // if iso == "`c'"
	foreach y in `years'{
		di "`c', `y'"
		*local c BE
		*local y 1990
		preserve
			keep if year2 == `y' // iso == "`c'" & 
			xi: oaxaca voteleft i.inc i.sex i.agerec i.religion i.religious i.rural i.region i.emp i.marital i.sector i.union i.house i.e ///
					[pw=weight], by(deduc_10) nodetail relax weight(0.5)
		restore
		replace explained = _b[explained] if year2 == `y'
		replace unexplained = _b[unexplained] if year2 == `y'
	}
*}

keep year2 explained unexplained
sort year2
gduplicates drop

save "$work/oaxaca-blinder.dta", replace

// Export the results
use "$work/oaxaca-blinder.dta", clear
replace explained = - explained * 100
replace unexplained = - unexplained * 100
gen gap = explained + unexplained

// Balanced panel
*keep if inlist(iso, "AU", "CA", "CH", "DE", "DK", "FR") | inlist(iso, "GB", "IT", "NL", "NO", "SE", "US")
*gcollapse (mean) gap explained unexplained, by(year2)

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
drop year2

order year gap explained unexplained

sort year

export excel "$results/GMP2021.xlsx", sheet("oaxaca") sheetreplace first(var)


// -------------------------------------------------------------------------- //
// Table B1: hand-coded in Excel
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Table B2: see Figure 8
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Table B3 to Table B8: Structure of manifestos by party family
// -------------------------------------------------------------------------- //

use "$work/gmp-cmp-party", clear

gen year2 = floor(year / 10) * 10
replace year2 = 2010 if year == 2020
replace year2 = 1950 if year2 == 1940

*drop if iso == "AT" & vote == "Peter Pilz List"

replace votegroup = "olr" if inlist(votegroup, "Christian", "Old right", "Right")
replace votegroup = "olr" if votegroup == "Liberal"
replace votegroup = "olf" if inlist(votegroup, "Communist", "New left", "Old left", "Left")
replace votegroup = "oth" if inlist(votegroup, "Regional", "Other")
replace votegroup = "gre" if inlist(votegroup, "Green")
replace votegroup = "ext" if inlist(votegroup, "Far right")

// Average of all Manifesto items by party family by decade
ren pervote weight
gcollapse (mean) per* [pw=weight], by(year2 votegroup)
drop if mi(votegroup) | votegroup == "Other"
drop if votegroup == "ext" & inlist(year2, 1950, 1960)

// Reshape
ds per*
local variables `r(varlist)'
foreach var of varlist per*{
	local lab`var': variable label `var'
}
renvars per*, pref(value)
greshape long value, i(year2 votegroup) j(var) string

// Add Bakker-Hobolt categories
gen group = ""
foreach var in per401 per402 per407 per505 per507 per410 per414 per702{ // eco right
	replace group = "Pro-free-market emphases" if var == "`var'"
} 
foreach var in per403 per404 per406 per504 per413 per412 per701 per405 per409 per506 per503{ // eco left
	replace group = "Pro-redistribution emphases" if var == "`var'"
}

foreach var in per305 per601 per603 per605 per608 per606{ // val right
	replace group = "Conservative emphases" if var == "`var'"
}
foreach var in per501 per602 per604 per502 per607 per416 per705 per706 per201 per202{ // val left
	replace group = "Progressive emphases" if var == "`var'"
}

// Label and reshape by year
foreach var in `variables'{
	replace var = "`lab`var''" if var == "`var'"
}
replace var = subinstr(var, "(mean) ", "", .)
replace var = upper(substr(var, 1, 1)) + substr(var, 2, .)

greshape wide value, i(votegroup var group) j(year2)

replace group = "Other" if mi(group)

gen sort = .
replace sort = 1 if group == "Conservative emphases"
replace sort = 2 if group == "Progressive emphases"
replace sort = 3 if group == "Pro-free-market emphases"
replace sort = 4 if group == "Pro-redistribution emphases"
replace sort = 5 if group == "Other"

gsort votegroup sort -value2010
drop sort

// Export averages for each party family
export excel "$results/GMP2021.xlsx", sheet("cmp_des_votegroup") sheetreplace first(var)

// Sources of ideological polarization in the 2010s
greshape long value, i(votegroup var group) j(year)
keep if year == 2010
drop year
greshape wide value, i(var group) j(votegroup) string
drop valueoth

gen sort = .
replace sort = 1 if group == "Conservative emphases"
replace sort = 2 if group == "Progressive emphases"
replace sort = 3 if group == "Pro-free-market emphases"
replace sort = 4 if group == "Pro-redistribution emphases"
replace sort = 5 if group == "Other"

gsort sort -valueolf
drop sort

order var group valuegre valueolf valueolr valueext

export excel "$results/GMP2021.xlsx", sheet("cmp_des_votegroup_2010") sheetreplace first(var)


// -------------------------------------------------------------------------- //
// Table B8 and Table B9: Regressions on link between supply and demand
// -------------------------------------------------------------------------- //

// Import data
use "$work/gmp-cmp-party", clear

gen year2 = floor(year / 10) * 10
replace year2 = 2010 if year == 2020
replace year2 = 1950 if year2 == 1940

replace votegroup = "Conservative" if inlist(votegroup, "Christian", "Old right", "Right")
replace votegroup = "Other" if inlist(votegroup, "Regional")
replace votegroup = "Socdem" if inlist(votegroup, "Communist", "New left", "Old left", "Left")

// Generate fixed effects
replace vote = iso + "-" + vote
gen election = iso + string(year)

encode iso, gen(i)
encode vote, gen(p)
encode election, gen(e)

eststo clear

// Regressions by decade with all variables
* no controls
eststo: reg val geduc_3 if inrange(year2, 1950, 1970)
local t = _b[geduc_3]/_se[geduc_3]
gen b_educ11 = _b[geduc_3]
gen p_educ11 = 2*ttail(e(df_r),abs(`t'))

eststo: reg val geduc_3 if inrange(year2, 1980, 1990)
local t = _b[geduc_3]/_se[geduc_3]
gen b_educ21 = _b[geduc_3]
gen p_educ21 = 2*ttail(e(df_r),abs(`t'))

eststo: reg val geduc_3 if inrange(year2, 2000, 2010)
local t = _b[geduc_3]/_se[geduc_3]
gen b_educ31 = _b[geduc_3]
gen p_educ31 = 2*ttail(e(df_r),abs(`t'))

* with country and year fixed effects
eststo: reg val geduc_3 ginc_3 agerec_1 agerec_2 sex rural rel_non i.i i.year if inrange(year2, 1950, 1970)
local t = _b[geduc_3]/_se[geduc_3]
gen b_educ12 = _b[geduc_3]
gen p_educ12 = 2*ttail(e(df_r),abs(`t'))

eststo: reg val geduc_3 ginc_3 agerec_1 agerec_2 sex rural rel_non i.i i.year if inrange(year2, 1980, 1990)
local t = _b[geduc_3]/_se[geduc_3]
gen b_educ22 = _b[geduc_3]
gen p_educ22 = 2*ttail(e(df_r),abs(`t'))

eststo: reg val geduc_3 ginc_3 agerec_1 agerec_2 sex rural rel_non i.i i.year if inrange(year2, 2000, 2010)
local t = _b[geduc_3]/_se[geduc_3]
gen b_educ32 = _b[geduc_3]
gen p_educ32 = 2*ttail(e(df_r),abs(`t'))

* with election fixed effects
eststo: reg val geduc_3 ginc_3 agerec_1 agerec_2 sex rural rel_non i.e if inrange(year2, 1950, 1970)
local t = _b[geduc_3]/_se[geduc_3]
gen b_educ13 = _b[geduc_3]
gen p_educ13 = 2*ttail(e(df_r),abs(`t'))

eststo: reg val geduc_3 ginc_3 agerec_1 agerec_2 sex rural rel_non i.e if inrange(year2, 1980, 1990)
local t = _b[geduc_3]/_se[geduc_3]
gen b_educ23 = _b[geduc_3]
gen p_educ23 = 2*ttail(e(df_r),abs(`t'))

eststo: reg val geduc_3 ginc_3 agerec_1 agerec_2 sex rural rel_non i.e if inrange(year2, 2000, 2010)
local t = _b[geduc_3]/_se[geduc_3]
gen b_educ33 = _b[geduc_3]
gen p_educ33 = 2*ttail(e(df_r),abs(`t'))

// Export summary table of education results
preserve
	keep b_* p_*
	gduplicates drop
	gen id = 1
	greshape long b_ p_, i(id) j(var) string

	renvars b_ p_ / b p
	tostring b, replace force format(%8.2f)
	replace b = b + "*" if p < 0.1 & p > 0.05
	replace b = b + "**" if p < 0.05 & p > 0.01
	replace b = b + "***" if p < 0.01

	drop p

	gen year = substr(var, 1, 5)
	gen model = substr(var, -1, 1)
	drop id var
	greshape wide b, i(year) j(model) string

	replace year = "1948-1979" if year == "educ1"
	replace year = "1980-1999" if year == "educ2"
	replace year = "2000-2020" if year == "educ3"

	export excel "$results/GMP2021.xlsx", sheet("reg_gmp_educ_val") sheetreplace first(var)
restore

// Export full regression tables
local mlabels "1948-1979" "1980-1999" "2000-2020" "1948-1979" "1980-1999" "2000-2020" "1948-1979" "1980-1999" "2000-2020"
esttab using "$work/temp.csv", ///
	cells(b(star fmt(3)) se(par)) noobs ///
	stats(r2 N, labels("R-squared" "Observations") fmt(%4.2f %4.0f)) ///
	label varlabels(_cons Constant) legend replace ///
	mlabels("`mlabels'") collabels(none) ///
	starlevels(* 0.10 ** 0.05 *** 0.01) drop(*.e *.i *.year agerec_1 agerec_2 sex rural rel_non _cons)

import delimited "$work/temp.csv", clear
foreach var of varlist _all{
	replace `var'=substr(`var',3,.)
	replace `var'=substr(`var',1,strlen(`var')-1)
}

replace v1 = "Share of top 10% educated voters in party's electorate" if v1 == "(mean) Top 10% of educ"
replace v1 = "Share of top 10% income voters in party's electorate" if v1 == "(mean) Top 10% of inc"

drop if _n == _N

export excel "$results/GMP2021.xlsx", sheet("reg_gmp_educ_val_det") sheetreplace first(var)


// -------------------------------------------------------------------------- //
// Table B10: Correlation between income/education gradients and all CMP items by decade
// -------------------------------------------------------------------------- //

use "$work/gmp-cmp-party", clear

gen year2 = floor(year / 10) * 10
replace year2 = 2010 if year == 2020
replace year2 = 1950 if year2 == 1940

keep if year2 >= 1960

replace votegroup = "Conservative" if inlist(votegroup, "Christian", "Old right", "Right")
replace votegroup = "Other" if inlist(votegroup, "Regional")
replace votegroup = "Socdem" if inlist(votegroup, "Communist", "New left", "Old left", "Left")

drop pervote

// Fetch labels
ds per*
local variables `r(varlist)'
foreach var of varlist per*{
	local lab`var': variable label `var'
}

// Evolution of correlations by decade
foreach var of varlist per*{
di "`var'"
forval y = 1960(10)2010{
*local y 1970
*local var per110
	correlate geduc_3 `var' if year2 == `y'
	gen r_`var'_`y' = `r(rho)'
	gen p_`var'_`y' = min(2*1*ttail(r(N)-2,abs(r(rho))*sqrt(r(N)-2)/sqrt(1-r(rho)^2)),1)

	correlate ginc_3 `var' if year2 == `y'
	gen r2_`var'_`y' = `r(rho)'
	gen p2_`var'_`y' = min(2*1*ttail(r(N)-2,abs(r(rho))*sqrt(r(N)-2)/sqrt(1-r(rho)^2)),1)
}
}

// Keep and reshape
keep r_* p_* r2_* p2_*
keep in 1
gen id = 1
greshape long r_ p_ r2_ p2_, i(id) j(var) string

// Separate year and var
gen year2 = real(substr(var, -4 , 4))
replace var = substr(var, 1, 6)
drop id

// Add Bakker-Hobolt categories
gen group = ""
foreach var in per401 per402 per407 per505 per507 per410 per414 per702{ // eco right
	replace group = "Pro-free-market emphases" if var == "`var'"
} 
foreach var in per403 per404 per406 per504 per413 per412 per701 per405 per409 per506 per503{ // eco left
	replace group = "Pro-redistribution emphases" if var == "`var'"
}
foreach var in per305 per601 per603 per605 per608 per606{ // val right
	replace group = "Conservative emphases" if var == "`var'"
}
foreach var in per501 per602 per604 per502 per607 per416 per705 per706 per201 per202{ // val left
	replace group = "Progressive emphases" if var == "`var'"
}
replace group = "Other" if mi(group)

// Label items
foreach var in `variables'{
	replace var = "`lab`var''" if var == "`var'"
}
replace var = upper(substr(var, 1, 1)) + substr(var, 2, .)

// Format numbers and generate significance stars
tostring r_, replace format(%4.2f) force
replace r_ = r_ + "*" if p_ < 0.1 & p_ > 0.05
replace r_ = r_ + "**" if p_ < 0.05 & p_ > 0.01
replace r_ = r_ + "***" if p_ < 0.01
drop p_

tostring r2_, replace format(%4.2f) force
replace r2_ = r2_ + "*" if p2_ < 0.1 & p2_ > 0.05
replace r2_ = r2_ + "**" if p2_ < 0.05 & p2_ > 0.01
replace r2_ = r2_ + "***" if p2_ < 0.01
drop p2_

greshape wide r_ r2_, i(var group) j(year2)

gen sort = .
replace sort = 1 if group == "Conservative emphases"
replace sort = 2 if group == "Progressive emphases"
replace sort = 3 if group == "Pro-free-market emphases"
replace sort = 4 if group == "Pro-redistribution emphases"
replace sort = 5 if group == "Other"

gen sort2 = 0
replace sort2 = 1 if substr(r_2010, -1 , 1) == "*"
replace sort2 = 2 if substr(r_2010, -2 , 2) == "**"
replace sort2 = 3 if substr(r_2010, -3 , 3) == "***"

gsort sort -sort2 r_2010
drop sort sort2

export excel "$results/GMP2021.xlsx", sheet("cor_cmp_gmp_party_full") sheetreplace first(var)



// -------------------------------------------------------------------------- //
// Figure B1: Share of votes captured by CMP-GMP dataset by country
// -------------------------------------------------------------------------- //

use "$work/gmp-cmp-party", clear

drop if mi(eco)
drop if mi(agerec_1)

gcollapse (sum) pervote, by(isoname year)
replace pervote = 100 if pervote > 100
replace pervote = pervote / 100

greshape wide pervote, i(year) j(isoname) string
foreach var of varlist pervote*{
	local lab = subinstr(substr("`var'", 8, .), "_", " ", .)
	lab var `var' "`lab'"
}

export excel "$results/GMP2021.xlsx", sheet("cmp_elec_results") sheetreplace first(varl)



// -------------------------------------------------------------------------- //
// Figure B2 to Figure B8: Political spaces by decade from CMP dataset
// -------------------------------------------------------------------------- //

// Graphs of political space by decade with all key parties
use "$work/gmp-cmp-party", clear

drop if mi(eco)
gen year2 = floor(year / 10) * 10
replace year2 = 2010 if year == 2020
replace year2 = 1950 if year2 == 1940

replace votegroup = "Conservative" if inlist(votegroup, "Christian", "Old right", "Right")
replace votegroup = "Other" if inlist(votegroup, "Regional")
replace votegroup = "Socdem" if inlist(votegroup, "Communist", "New left", "Old left", "Left")
*replace votegroup = "Conservative" if votegroup == "Liberal"

* drop small parties
drop if pervote < 5.1

* normalize by decennial average
foreach var in eco val{
*	bys year2: egen mean = wtmean(`var'), weight(pervote)
	bys iso year: egen mean = wtmean(`var'), weight(pervote)
	replace `var' = (`var' - mean)
	drop mean
}

gcollapse (mean) eco val pervote, by(iso year2 vote votegroup)

drop pervote

levelsof votegroup, local(groups)
foreach v in `groups'{
	local x = subinstr("`v'", " ", "", .)
	gen eco`x' = eco if votegroup == "`v'"
	gen val`x' = val if votegroup == "`v'"
}

keep iso year2 vote eco* val*

order year2 iso vote eco* val*
order year2 iso vote eco val
order ecoLiberal valLiberal, last
sort year2
compress

/*
br if valConservative < 0
*/

export excel "$results/GMP2021.xlsx", sheet("scat_cmp") sheetreplace first(var)


// -------------------------------------------------------------------------- //
// Figure B9: Correlation between party ideology and income/education gradients (top 50%)
// -------------------------------------------------------------------------- //

use "$work/gmp-cmp-party", clear

gen year2 = floor(year / 10) * 10
replace year2 = 2010 if year == 2020
replace year2 = 1950 if year2 == 1940

replace votegroup = "Conservative" if inlist(votegroup, "Christian", "Old right", "Right")
replace votegroup = "Other" if inlist(votegroup, "Regional")
replace votegroup = "Socdem" if inlist(votegroup, "Communist", "New left", "Old left", "Left")

replace geduc_3 = -geduc_1
replace ginc_3 = -ginc_1

*replace geduc_3 = geduc_3 / geduc_1
*replace ginc_3 = ginc_3 / ginc_1

// Evolution of correlations by decade
gen cor_edu_eco = .
gen cor_edu_val = .
gen cor_inc_eco = .
gen cor_inc_val = .
foreach var in cor_edu_eco cor_edu_val cor_inc_eco cor_inc_val{
	gen `var'_lb = .
	gen `var'_ub = .
}
forval y = 1950(10)2010{
*local y 1970
	ci2 geduc_3 eco if year2 == `y', corr
	replace cor_edu_eco = - `r(rho)' if year2 == `y'
	replace cor_edu_eco_lb = - `r(lb)' if year2 == `y'
	replace cor_edu_eco_ub = - `r(ub)' if year2 == `y'
	
	ci2 geduc_3 val if year2 == `y', corr
	replace cor_edu_val = - `r(rho)' if year2 == `y'
	replace cor_edu_val_lb = - `r(lb)' if year2 == `y'
	replace cor_edu_val_ub = - `r(ub)' if year2 == `y'
	
	ci2 ginc_3 eco if year2 == `y', corr
	replace cor_inc_eco = - `r(rho)' if year2 == `y'
	replace cor_inc_eco_lb = - `r(lb)' if year2 == `y'
	replace cor_inc_eco_ub = - `r(ub)' if year2 == `y'
	
	ci2 ginc_3 val if year2 == `y', corr
	replace cor_inc_val = - `r(rho)' if year2 == `y'
	replace cor_inc_val_lb = - `r(lb)' if year2 == `y'
	replace cor_inc_val_ub = - `r(ub)' if year2 == `y'
}

keep year2 cor_*
gduplicates drop

order year cor_edu_val* cor_inc_eco* cor_edu_eco* cor_inc_val*

foreach var in cor_edu_val cor_inc_eco cor_edu_eco cor_inc_val{
	replace `var'_lb = `var' - `var'_lb
	replace `var'_ub = `var'_ub - `var'
}

*tw con cor_edu_val cor_inc_eco year if year >= 1960

tostring year2, replace
replace year2 = "1948-1959" if year2 == "1950"
replace year2 = "1960-69" if year2 == "1960"
replace year2 = "1970-79" if year2 == "1970"
replace year2 = "1980-89" if year2 == "1980"
replace year2 = "1990-99" if year2 == "1900"
replace year2 = "2000-09" if year2 == "2000"
replace year2 = "2010-20" if year2 == "2010"

export excel "$results/GMP2021.xlsx", sheet("cor_cmp_gmp_party_t50") sheetreplace first(var)



// -------------------------------------------------------------------------- //
// Figure B10 to Figure B14: Link between supply and demand by decade
// -------------------------------------------------------------------------- //

use "$work/gmp-cmp-party", clear

gen year2 = floor(year / 10) * 10
replace year2 = 2010 if year == 2020
replace year2 = 1950 if year2 == 1940

drop if iso == "AT" & vote == "Peter Pilz List"

replace votegroup = "Conservative" if inlist(votegroup, "Christian", "Old right", "Right")
replace votegroup = "Other" if inlist(votegroup, "Regional")
replace votegroup = "Socdem" if inlist(votegroup, "Communist", "New left", "Old left", "Left")

// Collapse by decade to show overall correlations	
gcollapse (mean) geduc_3 ginc_3 eco val, by(iso year2 vote votegroup)

drop if mi(geduc_3) & mi(ginc_3)
drop if mi(eco)
keep if year2 >= 1970

renvars geduc_3 ginc_3 / geduc ginc

levelsof votegroup, local(groups)
foreach v in `groups'{
	local x = subinstr("`v'", " ", "", .)
	gen geduc`x' = geduc if votegroup == "`v'"
	gen ginc`x' = ginc if votegroup == "`v'"
}

order year2 iso vote votegroup eco val geduc geducConservative geducSocdem geducLiberal geducFarright geducGreen geducOther ginc gincConservative gincSocdem gincLiberal gincFarright gincGreen gincOther

levelsof year2, local(years)
foreach y in `years'{
	preserve
	keep if year2 == `y'
	export excel "$results/GMP2021.xlsx", sheet("scat_cmp_gmp_`y'") sheetreplace first(var)
	restore
}


// -------------------------------------------------------------------------- //
// Figure B15: Evolution of country-level correlations by decade
// -------------------------------------------------------------------------- //

// CMP - standard deviation, all parties
use "$work/gmp-cmp-party", clear

gen year2 = floor(year / 10) * 10
replace year2 = 2010 if year2 == 2020
replace year2 = 1950 if year2 == 1940

drop if mi(eco)

gcollapse (mean) eco val (sd) sd_eco = eco sd_val = val [aw=pervote], by(iso year year2)

replace eco = sd_eco // / abs(eco)
replace val = sd_val // / abs(val)

merge 1:m iso year using "$work/gmp-macro", nogen keep(master matched)
replace value = value * 100
drop if mi(value)

gcollapse (mean) value eco val sd_*, by(iso year2 var)

// Normalize standard deviations
replace sd_eco = sd_eco / ((sd_val + sd_eco) / 2)
replace sd_val = sd_val / ((sd_val + sd_eco) / 2)

// Evolution of country-level correlations by decade
greshape wide value, i(iso year2 eco val sd_eco sd_val) j(var) string
renpfix value
gen cor_edu_eco = .
gen cor_edu_val = .
gen cor_inc_eco = .
gen cor_inc_val = .
foreach var in cor_edu_eco cor_edu_val cor_inc_eco cor_inc_val{
	gen `var'_lb = .
	gen `var'_ub = .
}
forval y = 1950(10)2010{
*local y 1970
	ci2 vote_educ_dp90 sd_eco if year2 == `y', corr
	replace cor_edu_eco = `r(rho)' if year2 == `y'
	replace cor_edu_eco_lb = `r(lb)' if year2 == `y'
	replace cor_edu_eco_ub = `r(ub)' if year2 == `y'
	
	ci2 vote_educ_dp90 sd_val if year2 == `y', corr
	replace cor_edu_val = `r(rho)' if year2 == `y'
	replace cor_edu_val_lb = `r(lb)' if year2 == `y'
	replace cor_edu_val_ub = `r(ub)' if year2 == `y'
	
	ci2 vote_inc_dp90 sd_eco if year2 == `y', corr
	replace cor_inc_eco = `r(rho)' if year2 == `y'
	replace cor_inc_eco_lb = `r(lb)' if year2 == `y'
	replace cor_inc_eco_ub = `r(ub)' if year2 == `y'
	
	ci2 vote_inc_dp90 sd_val if year2 == `y', corr
	replace cor_inc_val = `r(rho)' if year2 == `y'
	replace cor_inc_val_lb = `r(lb)' if year2 == `y'
	replace cor_inc_val_ub = `r(ub)' if year2 == `y'
}

keep year2 cor_*
gduplicates drop

foreach var in cor_edu_val cor_inc_eco cor_edu_eco cor_inc_val{
	replace `var'_lb = `var' - `var'_lb
	replace `var'_ub = `var'_ub - `var'
}

/*
sort year
tw (con cor_edu_val cor_inc_eco year if year >= 1970, col(ebblue cranberry)) ///
	(rcap cor_edu_val_lb cor_edu_val_ub year if year >= 1970, col(ebblue)) ///
	(rcap cor_inc_eco_lb cor_inc_eco_ub year if year >= 1970, col(cranberry)) ///
	, yline(0, lcol(black)) yla(-0.8(0.2)0.8) ///
	legend(label(1 "Correlation between education gradient and" "libertarian-authoritarian polarization (country-level)") ///
		label(2 "Correlation between income gradient and" "economic polarization (country-level)") r(2) order(1 2)) xt("") yt("") xsize(6)
*/


sort year2
tostring year2, replace
replace year2 = "1948-1959" if year2 == "1950"
replace year2 = "1960-69" if year2 == "1960"
replace year2 = "1970-79" if year2 == "1970"
replace year2 = "1980-89" if year2 == "1980"
replace year2 = "1990-99" if year2 == "1900"
replace year2 = "2000-09" if year2 == "2000"
replace year2 = "2010-20" if year2 == "2010"

export excel "$results/GMP2021.xlsx", sheet("cor_cmp_gmp_ctr") sheetreplace first(varl)


// -------------------------------------------------------------------------- //
// Figure B16: Correlation between LRS from GMP and RILE from CMP
// -------------------------------------------------------------------------- //

use "$work/gmp-cmp-party", clear
keep if year >= 2000
replace votegroup = "Conservative" if inlist(votegroup, "Christian", "Old right", "Right")
replace votegroup = "Other" if inlist(votegroup, "Regional")
replace votegroup = "Socdem" if inlist(votegroup, "Communist", "New left", "Old left", "Left")
replace votegroup = "Conservative" if votegroup == "Liberal"

* drop small parties
drop if pervote < 5.1
replace pervote = sqrt(pervote)

gcollapse (mean) lrs rile pervote, by(iso vote votegroup)

greshape wide lrs rile pervote, i(iso vote) j(votegroup) string

export excel "$results/GMP2021.xlsx", sheet("gmp_cmp_lrs") sheetreplace first(var)



// -------------------------------------------------------------------------- //
// Figure B17: Correlation between LRS from GMP and RILE from CMP (normalized)
// -------------------------------------------------------------------------- //

use "$work/gmp-cmp-party", clear
compress

keep if year >= 2000

replace votegroup = "Conservative" if inlist(votegroup, "Christian", "Old right", "Right")
replace votegroup = "Other" if inlist(votegroup, "Regional")
replace votegroup = "Socdem" if inlist(votegroup, "Communist", "New left", "Old left", "Left")
*replace votegroup = "Conservative" if votegroup == "Liberal"

// Normalize RILE to vote-share-weighted average by country
foreach var in rile{
*local var lrs
	egen mean = wtmean(`var'), weight(pervote) by(iso year)
	replace `var' = `var' - mean
	drop mean
}

// Normalize LRS to vote-share-weighted average by country
preserve
	use if west == 1 using "$work/gmp", clear
	keep if year >= 2000
	drop if mi(votegroup) | mi(vote) | mi(lrs)
	gcollapse (mean) mean = lrs [pw=weight], by(iso)
	tempfile temp
	save `temp'
restore
merge m:1 iso using `temp', nogen
replace lrs = lrs - mean
drop mean

*br iso year vote rile lrs pervote if iso == "IE"

* drop small parties
drop if pervote < 5.1
replace pervote = sqrt(pervote)
*replace pervote = pervote / 10
gcollapse (mean) lrs rile pervote, by(iso vote votegroup)

cor lrs rile

/*
compress
br if votegroup == "Conservative" & (lrs < 0 | rile < 0) & !mi(rile) & !mi(lrs)
br if votegroup == "Conservative" & lrs < 0 & !mi(rile) & !mi(lrs)
br if votegroup == "Conservative" & rile < 0 & !mi(rile) & !mi(lrs)
br if votegroup == "Far right" & lrs < 0 & !mi(rile) & !mi(lrs)
br if votegroup == "Far right" & rile < 0 & !mi(rile) & !mi(lrs)
br if votegroup == "Socdem" & rile > 0 & !mi(rile) & !mi(lrs)
br if votegroup == "Socdem" & lrs > 0 & !mi(rile) & !mi(lrs)

tw (scat rile lrs if votegroup == "Conservative") ///
	(scat rile lrs if votegroup == "Socdem") ///
	(scat rile lrs if votegroup == "Green") ///
	(scat rile lrs if votegroup == "Far right") ///
	(scat rile lrs if votegroup == "Other") ///
	(scat rile lrs if votegroup == "Liberal", col(black)) ///
	, yline(0, lcol(black)) xline(0, lcol(black))
*/

greshape wide lrs rile pervote, i(iso vote) j(votegroup) string


export excel "$results/GMP2021.xlsx", sheet("gmp_cmp_lrs_rel") sheetreplace first(var)



// -------------------------------------------------------------------------- //
// Figure B18 to Figure B25: Main political parties' left-right positioning based on LRS variable
// -------------------------------------------------------------------------- //

use if west == 1 using "$work/gmp", clear

drop if iso == "IT" & year == 1972
drop if iso == "SE" & inlist(year, 1973, 1976)
drop if iso == "LU" & year > 2010

keep if year >= 2000

replace voteolf = voteleft - votegre
replace voteolr = voteright - voteext

drop votegroup
gen votegroup = "Conservatives / Christian Democrats / Liberals" if voteolr == 1
replace votegroup = "Social Democrats / Socialists / Other left" if voteolf == 1
replace votegroup = "Greens" if votegre == 1
replace votegroup = "Anti-immigration" if voteext == 1

drop if mi(votegroup)
drop if mi(vote)
drop if mi(lrs)

// Normalize left-right scores by the country's average
preserve
	gcollapse (mean) mean = lrs [pw=weight], by(iso)
	tempfile temp
	save `temp'
restore
merge m:1 iso using `temp', nogen

gen lrs2 = lrs - mean

gcollapse (mean) lrs lrs2 [pw=weight], by(iso isoname votegroup)

order votegroup iso isoname lrs2 lrs
sort votegroup lrs2 lrs

export excel "$results/GMP2021.xlsx", sheet("lrs_votegroup") sheetreplace first(var)



// -------------------------------------------------------------------------- //
// Figure CA1 to Figure CA4: See Figure 2
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure CA5
// -------------------------------------------------------------------------- //

use "$work/gmp", clear

bys iso: egen x = max(year)
keep if year == x
drop x

drop if mi(age)
keep if west == 1
keep if year2 == 2010

drop if iso == "GB"
drop if iso == "US"

*replace age = floor(age / 10) * 10
replace age = 70 if age >= 70 & !mi(age)
replace age = 20 if age <= 20 & !mi(age)

replace voteolr = 1 if votechr == 1

// Collapse by country and then by age
gcollapse (mean) votegre votenlf voteolf votereg votelib voteext votechr voteolr [pw=weight], by(iso age)

// Smooth
levelsof iso, local(countries)
foreach var of varlist vote*{
foreach c in `countries'{
	lpoly `var' age if iso == "`c'", degree(2) gen(x) at(age) nograph
	replace `var' = x if iso == "`c'"
	drop x
}
}

// Set zeros as missing
foreach var of varlist vote*{
	replace `var' = . if `var' == 0
}

// Overall average
gen voteext2 = voteext if inlist(iso, "CH", "DK", "NO", "NZ", "SE")
gen voteext3 = voteext if inlist(iso, "AT", "ES", "FI", "FR")

gen voteolf2 = voteolf if !inlist(iso, "CA", "FR") // drop countries with no serious new left challenger

ta iso if !mi(votenlf)
ta iso if !mi(votegre)
ta iso if !mi(votelib)

gcollapse (mean) votegre votenlf voteolf votereg votelib voteext* votechr voteolr, by(age)
lab var votegre "Green parties"
lab var votenlf "New left (Germany, Spain, France, Portugal, Norway)"
lab var votelib "Liberal parties"
lab var voteext "Far right"
lab var voteext2 "Anti-immigration (Switzerland, Denmark, Norway, New Zealand, Sweden)"
lab var voteext3 "Anti-immigration (Austria, Spain, Finland, France)"
lab var voteolf "Old left"
lab var voteolr "Old right"

export excel "$results/GMP2021.xlsx", sheet("age_profile") sheetreplace first(varl)


// -------------------------------------------------------------------------- //
// Figure CA6 to Figure CA7: see Figure A33
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure CB1: see Figure 2
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure CB2 to Figure CB6: see Figure A33
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure CB7 to Figure CB8: see Figure 2
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure CC1: see Figure 2
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure CC2 to Figure CC3: see Figure A33
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure CC4: see Figure 2
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure CC5 to Figure CC6: see Figure A33
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure CD1 to Figure CD3: see Figure 2
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure CD4
// -------------------------------------------------------------------------- //

use "$work/gmp-macro", clear

keep if west == 1
keep if inlist(var, "vote_sex_diff", "vote_sex_dif4")

keep if year2 == 2010

replace value = value * 100
gcollapse value, by(iso isoname var)
greshape wide value, i(iso isoname) j(var) string
renpfix value

order iso isoname vote_sex_diff vote_sex_dif4
drop if mi(vote_sex_dif4)
sort vote_sex_diff

export excel "$results/GMP2021.xlsx", sheet("vote_sex_sector") sheetreplace first(varl)


// -------------------------------------------------------------------------- //
// Figure CD5 to Figure CD6: see Figure A33
// -------------------------------------------------------------------------- //


// -------------------------------------------------------------------------- //
// Figure CE1
// -------------------------------------------------------------------------- //

use "$work/gmp", clear

* drop Eastern Europe migrants
drop if ctrbirth == "Eastern Europe"

drop if mi(ctrbirth)
replace ctrbirth = "Other West" if ctrbirth == "Other"
replace ctrbirth = "Other non-West" if ctrbirth == "Brazil"
replace ctrbirth = "Other non-West" if ctrbirth == "Asia"
replace ctrbirth = "Other non-West" if ctrbirth == "Eastern Europe"
replace ctrbirth = "Other non-West" if ctrbirth == "Turkey"
drop if inlist(iso, "HK", "HU", "SE", "CH", "IL")

replace voteleft = 0 if iso == "IE" & vote == "Fianna Fail"

// Add missing countries from ESS
preserve
	use "$work/ess", clear

	* drop Eastern Europe migrants
	drop if ctrbirth == "Eastern Europe"
	drop if ctrbirth2 == "UA"
	drop if ctrbirth2 == "KZ"

	keep if inlist(iso, "CH", "DE", "DK", "ES", "FI") | inlist(iso, "GB", "IT", "NO", "SE")
	replace ctrbirth = "Other" if !inlist(ctrbirth, "Country", "Western", "Eastern Europe")
	replace ctrbirth = "Other" if inlist(ctrbirth, "Eastern Europe")
	replace ctrbirth = "Other West" if ctrbirth == "Western"
	replace ctrbirth = "Other non-West" if ctrbirth == "Other"
	
	keep iso isoname year voteleft ctrbirth weight
	ren weightorig weight
	tempfile temp
	save `temp'
restore
append using `temp'

replace year = 2010 if iso == "FR" & year == 2007

// Collapse
gen var = inlist(ctrbirth, "Other non-West") if !mi(ctrbirth)
replace var = 1 if inlist(iso, "US", "IS") & ctrbirth == "Other West"
drop if ctrbirth == "Other West" & !inlist(iso, "IS", "US")

gcollapse (mean) voteleft [pw=weight], by(iso isoname west year year2 var)
greshape wide voteleft, i(iso year) j(var)
gen diff = (voteleft1 - voteleft0) * 100

gcollapse diff, by(iso isoname year2)
keep if year2 >= 2010
keep iso isoname diff

sort diff

replace isoname = "UK" if isoname == "United Kingdom"
replace isoname = "US" if isoname == "United States"

export excel "$results/GMP2021.xlsx", sheet("ctrbirth_west") sheetreplace first(varl)


// -------------------------------------------------------------------------- //
// Figure CE2
// -------------------------------------------------------------------------- //

use "$work/gmp", clear
keep if west == 1
drop if mi(religion)
replace religion = "1" if religion == "None"
replace religion = "2" if religion == "Catholic"
replace religion = "3" if religion == "Other Christian"
replace religion = "4" if religion == "Muslim"
replace religion = "5" if !inlist(religion, "1", "2", "3", "4", "5")
destring religion, replace

* drop countries which are better in ESS
drop if iso == "NO"

// Add missing countries from ESS
preserve
	use "$work/ess", clear
	keep if inlist(iso, "CH", "DE", "DK", "ES", "FI") | inlist(iso, "IS", "IT", "SE", "PT", "NO")
	keep iso isoname year year2 voteleft ctrbirth religion weight
	ren weightorig weight
	tempfile temp
	save `temp'
restore
append using `temp'

* drop countries with too little data
drop if iso == "IS"
drop if iso == "LU"
drop if iso == "PT"

replace religion = 2 if religion == 3

* in Ireland, remove FF
replace voteleft = 0 if iso == "IE" & vote == "Fianna Fail"

label define religion 1 "No religion" 2 "Christian" 4 "Muslim", replace
label values religion religion

// Difference Muslims vs. non-Muslims
gen var = (religion == 4) if !mi(religion)
drop if mi(var)
gcollapse (mean) voteleft [pw=weight], by(iso isoname year2 var)
greshape wide voteleft, i(iso isoname year2) j(var)
gen diff = (voteleft1 - voteleft0) * 100

keep if year2 == 2010
keep iso isoname diff
sort diff

replace isoname = "UK" if isoname == "United Kingdom"
replace isoname = "US" if isoname == "United States"


export excel "$results/GMP2021.xlsx", sheet("muslim_west") sheetreplace first(varl)


// -------------------------------------------------------------------------- //
// Figure CE3
// -------------------------------------------------------------------------- //

use "$work/gmp", clear
drop if mi(ctrbirth)

// Recode
replace ctrbirth = "Other West" if ctrbirth == "Other"
replace ctrbirth = "Other non-West" if ctrbirth == "Brazil"
replace ctrbirth = "Other non-West" if ctrbirth == "Asia"
replace ctrbirth = "Other non-West" if ctrbirth == "Eastern Europe"
replace ctrbirth = "Other non-West" if ctrbirth == "Turkey"

drop if inlist(iso, "HK", "HU", "SE", "CH", "IL")

replace voteleft = 0 if iso == "IE" & vote == "Fianna Fail"

replace religion = "1" if religion == "None"
replace religion = "2" if religion == "Catholic"
replace religion = "3" if religion == "Other Christian"
replace religion = "4" if religion == "Muslim"
replace religion = "5" if !inlist(religion, "1", "2", "3", "4", "5")
destring religion, replace

// Add missing countries from ESS
preserve
	use "$work/ess", clear
	keep if inlist(iso, "CH", "DE", "DK", "ES", "FI") | inlist(iso, "GB", "IT", "NO", "SE")
	replace ctrbirth = "Other" if !inlist(ctrbirth, "Country", "Western", "Eastern Europe")
	replace ctrbirth = "Other" if inlist(ctrbirth, "Eastern Europe")
	replace ctrbirth = "Other West" if ctrbirth == "Western"
	replace ctrbirth = "Other non-West" if ctrbirth == "Other"
	
	keep iso isoname year voteleft ctrbirth religion weight
	ren weightorig weight
	tempfile temp
	save `temp'
restore
append using `temp'

* add Muslims to the graphs
*replace ctrbirth = "Muslims" if religion == 4

replace year = 2010 if iso == "FR" & year == 2007

keep if year2 == 2010

gcollapse (mean) voteleft [pw=weight], by(iso isoname ctrbirth)
greshape wide voteleft, i(iso isoname) j(ctrbirth) string
renpfix voteleft
renvars, lower

labdtch _all

export excel "$results/GMP2021.xlsx", sheet("vote_west_ctrbirth") sheetreplace first(varl)



// -------------------------------------------------------------------------- //
// Figure CF1 to Figure CF2: see Figure 2
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure CF3 to Figure CF4: see Figure A33
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
// Figure CF5 to Figure CF10: see Figure 2
// -------------------------------------------------------------------------- //



// -------------------------------------------------------------------------- //
// Table D1: reversal of educational divides by country
// -------------------------------------------------------------------------- //

use if west == 1 using "$work/gmp-educ", clear
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c FR
	use if iso == "`c'" using "$work/gmp-educ", clear
	
	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	foreach var of varlist inc agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	foreach var in b1 s1 p1 b2 s2 p2{
		gen `var' = .
	}
	
	drop year
	ren year2 year
	replace year = 1950 if year == 1940
	replace year = 2010 if year == 2020

	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012
	
		// Top 10% - bottom 90%
		reg voteleft geduc_3 if year == `y' [pw=weight], robust cluster(id)
		replace b1 = _b[geduc_3] if year == `y'
		replace s1 = _se[geduc_3] if year == `y'
		replace p1 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year == `y'
		
		reg voteleft geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight], robust cluster(id)
		replace b2 = _b[geduc_3] if year == `y'
		replace s2 = _se[geduc_3] if year == `y'
		replace p2 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year == `y'
	}
	
	// Format
	keep iso isoname west year b1 s1 p1 b2 s2 p2
	gduplicates drop
	tempfile temp
	save `temp'
restore
append using `temp'
}
}

// Keep only after controls
drop b1 s1 p1
renvars b2 s2 p2 / b s p

// Format table
replace b = b * 100
tostring b, replace format(%4.1f) force
replace b = b + "*" if p < 0.1 & p > 0.05
replace b = b + "**" if p < 0.05 & p > 0.01
replace b = b + "***" if p < 0.01
drop p

replace s = s * 100
tostring s, replace format(%4.1f) force
replace s = "(" + s + ")"

// Reshape wide
greshape wide b s, i(isoname) j(year)

gen sort = _n
preserve
	keep isoname sort s*
	replace sort = sort + 0.5
	renvars s*, presub("s" "b")
	ren bort sort
	tempfile temp
	save `temp'
restore
append using `temp'
sort sort
drop s1950-s2010 sort

replace isoname = "" if mod(_n, 2) == 0
labvars b* "1948-59" "1960-69" "1970-79" "1980-89" "1990-99" "2000-09" "2010-2020"

export excel "$results/GMP2021.xlsx", sheet("reg_bycountry_educ") sheetreplace first(varl)



// -------------------------------------------------------------------------- //
// Table D2: stability/decline of income divides by country
// -------------------------------------------------------------------------- //

use if west == 1 using "$work/gmp-inc", clear
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
	foreach var of varlist inc agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	foreach var in b1 s1 p1 b2 s2 p2{
		gen `var' = .
	}
	
	drop year
	ren year2 year
	replace year = 1950 if year == 1940
	replace year = 2010 if year == 2020

	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012
	
		// Top 10% - bottom 90%
		reg voteleft ginc_3 if year == `y' [pw=weight], robust cluster(id)
		replace b1 = _b[ginc_3] if year == `y'
		replace s1 = _se[ginc_3] if year == `y'
		replace p1 = 2*ttail(e(df_r),abs(_b[ginc_3]/_se[ginc_3])) if year == `y'
		
		reg voteleft ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight], robust cluster(id)
		replace b2 = _b[ginc_3] if year == `y'
		replace s2 = _se[ginc_3] if year == `y'
		replace p2 = 2*ttail(e(df_r),abs(_b[ginc_3]/_se[ginc_3])) if year == `y'
	}
	
	// Format
	keep iso isoname west year b1 s1 p1 b2 s2 p2
	gduplicates drop
	tempfile temp
	save `temp'
restore
append using `temp'
}
}

// Keep only after controls
drop b1 s1 p1
renvars b2 s2 p2 / b s p

// Format table
replace b = b * 100
tostring b, replace format(%4.1f) force
replace b = b + "*" if p < 0.1 & p > 0.05
replace b = b + "**" if p < 0.05 & p > 0.01
replace b = b + "***" if p < 0.01
drop p

replace s = s * 100
tostring s, replace format(%4.1f) force
replace s = "(" + s + ")"

// Reshape wide
greshape wide b s, i(isoname) j(year)

gen sort = _n
preserve
	keep isoname sort s*
	replace sort = sort + 0.5
	renvars s*, presub("s" "b")
	ren bort sort
	tempfile temp
	save `temp'
restore
append using `temp'
sort sort
drop s1950-s2010 sort

replace isoname = "" if mod(_n, 2) == 0
labvars b* "1948-59" "1960-69" "1970-79" "1980-89" "1990-99" "2000-09" "2010-2020"

export excel "$results/GMP2021.xlsx", sheet("reg_bycountry_inc") sheetreplace first(varl)



// -------------------------------------------------------------------------- //
// Table D3 to Table D4
// -------------------------------------------------------------------------- //

// Education
use if west == 1 using "$work/gmp-educ", clear
keep if year2 == 2010
levelsof iso, local(countries)

clear
foreach c in `countries'{
preserve
di in red "`c'..."
qui{
	*local c FR
	use if iso == "`c'" using "$work/gmp-educ", clear
	
	foreach var of varlist vote2 religion region race{
		encode `var', gen(x)
		drop `var'
		ren x `var'
	}
	foreach var of varlist inc agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	* redefined old left as left - green, and old right as right - anti-immigration
	replace voteolf = voteleft - votegre
	replace voteolr = voteright - voteext
	
	foreach var in b1 s1 p1 b2 s2 p2 b3 s3 p3 b4 s4 p4{
		gen `var' = .
	}
	
	drop year
	ren year2 year
	replace year = 1950 if year == 1940
	replace year = 2010 if year == 2020
	keep if year == 2010

	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012

		reg voteolf geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight], robust cluster(id)
		replace b1 = _b[geduc_3] if year == `y'
		replace s1 = _se[geduc_3] if year == `y'
		replace p1 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year == `y'
		
		reg voteolr geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight], robust cluster(id)
		replace b2 = _b[geduc_3] if year == `y'
		replace s2 = _se[geduc_3] if year == `y'
		replace p2 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year == `y'

		reg votegre geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight], robust cluster(id)
		replace b3 = _b[geduc_3] if year == `y'
		replace s3 = _se[geduc_3] if year == `y'
		replace p3 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year == `y'
		
		reg voteext geduc_3 i.inc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight], robust cluster(id)
		replace b4 = _b[geduc_3] if year == `y'
		replace s4 = _se[geduc_3] if year == `y'
		replace p4 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year == `y'
	}
	
	// Format
	keep iso isoname west year b1 s1 p1 b2 s2 p2 b3 s3 p3 b4 s4 p4
	gduplicates drop
	tempfile temp
	save `temp'
restore
append using `temp'
}
}

// Format table
forval i = 1/4{
replace b`i' = b`i' * 100
tostring b`i', replace format(%4.1f) force
replace b`i' = b`i' + "*" if p`i' < 0.1 & p`i' > 0.05
replace b`i' = b`i' + "**" if p`i' < 0.05 & p`i' > 0.01
replace b`i' = b`i' + "***" if p`i' < 0.01
drop p`i'

replace s`i' = s`i' * 100
tostring s`i', replace format(%4.1f) force
replace s`i' = "(" + s`i' + ")"
}

// Reshape wide
drop iso west
greshape wide b1 s1 b2 s2 b3 s3 b4 s4, i(isoname) j(year)

gen sort = _n
preserve
	keep isoname sort s*
	replace sort = sort + 0.5
	renvars s*, presub("s" "b")
	ren bort sort
	tempfile temp
	save `temp'
restore
append using `temp'
sort sort
drop s*

replace isoname = "" if mod(_n, 2) == 0
labvars b* "Social Democratic / Socialist / Communist / Other left" "Conservative / Christian Democratic / Liberal" "Green" "Anti-immmigration"

foreach var of varlist b*{
	replace `var' = "" if `var' == "0.0"
	replace `var' = "" if `var' == "(0.0)"
}

export excel "$results/GMP2021.xlsx", sheet("reg_bycountry_educ_fam") sheetreplace first(varl)



// Income
use if west == 1 using "$work/gmp-inc", clear
drop if mi(inc)
keep if year2 == 2010
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
	foreach var of varlist inc agerec sex religion religious rural region race emp marital{
		replace `var' = 99 if mi(`var')
	}
	
	* redefined old left as left - green, and old right as right - anti-immigration
	replace voteolf = voteleft - votegre
	replace voteolr = voteright - voteext
	
	foreach var in b1 s1 p1 b2 s2 p2 b3 s3 p3 b4 s4 p4{
		gen `var' = .
	}
	
	drop year
	ren year2 year
	replace year = 1950 if year == 1940
	replace year = 2010 if year == 2020
	keep if year == 2010

	levelsof year, local(years)
	foreach y in `years'{
	*local y 2012

		reg voteolf ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight], robust cluster(id)
		replace b1 = _b[ginc_3] if year == `y'
		replace s1 = _se[ginc_3] if year == `y'
		replace p1 = 2*ttail(e(df_r),abs(_b[ginc_3]/_se[ginc_3])) if year == `y'
		
		reg voteolr ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight], robust cluster(id)
		replace b2 = _b[ginc_3] if year == `y'
		replace s2 = _se[ginc_3] if year == `y'
		replace p2 = 2*ttail(e(df_r),abs(_b[ginc_3]/_se[ginc_3])) if year == `y'

		reg votegre ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight], robust cluster(id)
		replace b3 = _b[ginc_3] if year == `y'
		replace s3 = _se[ginc_3] if year == `y'
		replace p3 = 2*ttail(e(df_r),abs(_b[ginc_3]/_se[ginc_3])) if year == `y'
		
		reg voteext ginc_3 i.educ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year == `y' [pw=weight], robust cluster(id)
		replace b4 = _b[ginc_3] if year == `y'
		replace s4 = _se[ginc_3] if year == `y'
		replace p4 = 2*ttail(e(df_r),abs(_b[ginc_3]/_se[ginc_3])) if year == `y'
	}
	
	// Format
	keep iso isoname west year b1 s1 p1 b2 s2 p2 b3 s3 p3 b4 s4 p4
	gduplicates drop
	tempfile temp
	save `temp'
restore
append using `temp'
}
}

// Format table
forval i = 1/4{
replace b`i' = b`i' * 100
tostring b`i', replace format(%4.1f) force
replace b`i' = b`i' + "*" if p`i' < 0.1 & p`i' > 0.05
replace b`i' = b`i' + "**" if p`i' < 0.05 & p`i' > 0.01
replace b`i' = b`i' + "***" if p`i' < 0.01
drop p`i'

replace s`i' = s`i' * 100
tostring s`i', replace format(%4.1f) force
replace s`i' = "(" + s`i' + ")"
}

// Reshape wide
drop iso west
greshape wide b1 s1 b2 s2 b3 s3 b4 s4, i(isoname) j(year)

gen sort = _n
preserve
	keep isoname sort s*
	replace sort = sort + 0.5
	renvars s*, presub("s" "b")
	ren bort sort
	tempfile temp
	save `temp'
restore
append using `temp'
sort sort
drop s*

replace isoname = "" if mod(_n, 2) == 0
labvars b* "Social Democratic / Socialist / Communist / Other left" "Conservative / Christian Democratic / Liberal" "Green" "Anti-immmigration"

foreach var of varlist b*{
	replace `var' = "" if `var' == "0.0"
	replace `var' = "" if `var' == "(0.0)"
}

replace b22010 = "0.0" if isoname == "United States" // only exception

export excel "$results/GMP2021.xlsx", sheet("reg_bycountry_inc_fam") sheetreplace first(varl)



// -------------------------------------------------------------------------- //
// Table D5 to Table D6
// -------------------------------------------------------------------------- //

use "$work/gmp-inc-cmp", clear

// Harmonize some variables and set missing values to an arbitrary value
replace year2 = floor(year / 10) * 10
replace year2 = 1950 if year2 == 1940
replace year2 = 2010 if year2 == 2020

encode iso, gen(i)

gen elec = iso + string(year)
encode elec, gen(e)

foreach var of varlist vote2 religion region race{
	encode `var', gen(x)
	drop `var'
	ren x `var'
}
foreach var of varlist agerec sex religion religious rural region race emp marital{
	replace `var' = 99 if mi(`var')
}

// Invert the RILE scale
replace rile = - rile

// Generate university graduates dummy
gen univ = inlist(educ, 3, 4) if !mi(educ)

// Regression of RILE on top 10% income dummy and university graduates
preserve
	eststo clear
	levelsof year2, local(years)
	foreach y in `years'{
		eststo: reg rile ginc_3 univ i.e if year2 == `y' [pw=weight], robust cluster(id)
	}

	*esttab, drop(*.e)

	local mlabels "1948-1959" "1960-69" "1970-79" "1980-89" "1990-99" "2000-09" "2010-20"
	esttab using "$work/temp.csv", ///
		cells(b(star fmt(3)) se(par)) noobs ///
		stats(r2 N, labels("R-squared" "Observations") fmt(%4.2f %4.0f)) ///
		label varlabels(_cons Constant) legend replace ///
		mlabels("`mlabels'") collabels(none) ///
		starlevels(* 0.10 ** 0.05 *** 0.01) drop(*.e _cons)

	import delimited "$work/temp.csv", clear
	foreach var of varlist _all{
		replace `var'=substr(`var',3,.)
		replace `var'=substr(`var',1,strlen(`var')-1)
	}

	replace v1 = "Income: Top 10%" if v1 == "Top 10% of inc"
	replace v1 = "Education: University graduate" if v1 == "univ"

	drop if _n == _N

	export excel "$results/GMP2021.xlsx", sheet("reg_rile_dum") sheetreplace first(var)
restore

// Regression of RILE on top 10% income dummy and university graduates, with controls
preserve
	eststo clear
	levelsof year2, local(years)
	foreach y in `years'{
		eststo: reg rile ginc_3 univ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital i.e if year2 == `y' [pw=weight], robust cluster(id)
	}

	*esttab, drop(*.e *agerec *sex *religion *religious *rural *region *race *emp *marital)

	local mlabels "1948-1959" "1960-69" "1970-79" "1980-89" "1990-99" "2000-09" "2010-20"
	esttab using "$work/temp.csv", ///
		cells(b(star fmt(3)) se(par)) noobs ///
		stats(r2 N, labels("R-squared" "Observations") fmt(%4.2f %4.0f)) ///
		label varlabels(_cons Constant) legend replace ///
		mlabels("`mlabels'") collabels(none) ///
		starlevels(* 0.10 ** 0.05 *** 0.01) ///
		drop(*.e _cons *agerec *sex *religion *religious *rural *region *race *emp *marital)

	import delimited "$work/temp.csv", clear
	foreach var of varlist _all{
		replace `var'=substr(`var',3,.)
		replace `var'=substr(`var',1,strlen(`var')-1)
	}

	replace v1 = "Income: Top 10%" if v1 == "Top 10% of inc"
	replace v1 = "Education: University graduate" if v1 == "univ"

	drop if _n == _N

	export excel "$results/GMP2021.xlsx", sheet("reg_rile_dum_ctr") sheetreplace first(var)
restore



// -------------------------------------------------------------------------- //
// Table D7 to Table D8: continuous left-right scale from CMP dataset, dummy for other variables
// -------------------------------------------------------------------------- //

use "$work/gmp-inc-cmp", clear

// Harmonize some variables and set missing values to an arbitrary value
replace year2 = floor(year / 10) * 10
replace year2 = 1950 if year2 == 1940
replace year2 = 2010 if year2 == 2020

encode iso, gen(i)

gen elec = iso + string(year)
encode elec, gen(e)

foreach var of varlist vote2 religion region race{
	encode `var', gen(x)
	drop `var'
	ren x `var'
}
foreach var of varlist agerec sex religion religious rural region race emp marital{
	replace `var' = 99 if mi(`var')
}

// Invert the RILE scale
replace rile = - rile

// Generate university graduates dummy
gen univ = inlist(educ, 3, 4) if !mi(educ)

// Regression of RILE on top 10% income dummy and university graduates
preserve
	eststo clear
	levelsof year2, local(years)
	foreach y in `years'{
		eststo: reg rile ginc_3 univ i.e if year2 == `y' [pw=weight], robust cluster(id)
	}

	*esttab, drop(*.e)

	local mlabels "1948-1959" "1960-69" "1970-79" "1980-89" "1990-99" "2000-09" "2010-20"
	esttab using "$work/temp.csv", ///
		cells(b(star fmt(3)) se(par)) noobs ///
		stats(r2 N, labels("R-squared" "Observations") fmt(%4.2f %4.0f)) ///
		label varlabels(_cons Constant) legend replace ///
		mlabels("`mlabels'") collabels(none) ///
		starlevels(* 0.10 ** 0.05 *** 0.01) drop(*.e _cons)

	import delimited "$work/temp.csv", clear
	foreach var of varlist _all{
		replace `var'=substr(`var',3,.)
		replace `var'=substr(`var',1,strlen(`var')-1)
	}

	replace v1 = "Income: Top 10%" if v1 == "Top 10% of inc"
	replace v1 = "Education: University graduate" if v1 == "univ"

	drop if _n == _N

	export excel "$results/GMP2021.xlsx", sheet("reg_rile_dum") sheetreplace first(var)
restore

// Regression of RILE on top 10% income dummy and university graduates, with controls
preserve
	eststo clear
	levelsof year2, local(years)
	foreach y in `years'{
		eststo: reg rile ginc_3 univ i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital i.e if year2 == `y' [pw=weight], robust cluster(id)
	}

	*esttab, drop(*.e *agerec *sex *religion *religious *rural *region *race *emp *marital)

	local mlabels "1948-1959" "1960-69" "1970-79" "1980-89" "1990-99" "2000-09" "2010-20"
	esttab using "$work/temp.csv", ///
		cells(b(star fmt(3)) se(par)) noobs ///
		stats(r2 N, labels("R-squared" "Observations") fmt(%4.2f %4.0f)) ///
		label varlabels(_cons Constant) legend replace ///
		mlabels("`mlabels'") collabels(none) ///
		starlevels(* 0.10 ** 0.05 *** 0.01) ///
		drop(*.e _cons *agerec *sex *religion *religious *rural *region *race *emp *marital)

	import delimited "$work/temp.csv", clear
	foreach var of varlist _all{
		replace `var'=substr(`var',3,.)
		replace `var'=substr(`var',1,strlen(`var')-1)
	}

	replace v1 = "Income: Top 10%" if v1 == "Top 10% of inc"
	replace v1 = "Education: University graduate" if v1 == "univ"

	drop if _n == _N

	export excel "$results/GMP2021.xlsx", sheet("reg_rile_dum_ctr") sheetreplace first(var)
restore





// -------------------------------------------------------------------------- //
// Table D9: Education gradient control after control
// -------------------------------------------------------------------------- //

set matsize 10000

use if west == 1 using "$work/gmp-educ", clear

keep if inlist(iso, "AU", "DK", "FI", "FR", "GB", "NL") | inlist(iso, "NO", "NZ", "SE", "US")

// Harmonize some variables and set missing values to an arbitrary value
replace year2 = floor(year / 10) * 10
replace year2 = 1950 if year2 == 1940
replace year2 = 2010 if year2 == 2020

replace religion = "Other" if inlist(religion, "Buddhist", "Hindu", "Jewish", "Sikh")
replace religion = "Other Christian" if religion == "Protestant"

gen rel = 1 if religion == "None"
replace rel = 2 if religion == "Catholic"
replace rel = 3 if religion == "Other Christian"
replace rel = 4 if religion == "Muslim"
replace rel = 5 if religion == "Other"
label define religion 1 "Religion: None" 2 "Religion: Catholic" 3 "Religion: Other Christian" 4 "Religion: Muslim" 5 "Religion: Other"
label values rel religion
drop religion
ren rel religion

replace region = "Region: " + region if !mi(region)
replace region = "Region: Gotland" if region == "Region: Götland" & iso == "SE" // issue with special characters in Excel
replace race = "Race/ethnicity/language: " + race if !mi(race)

foreach var of varlist vote2 region race{
	ren `var' x
	encode x, gen(`var')
	drop x
}
foreach var of varlist educ inc agerec sex religion religious rural region race emp marital union sector house class{
	replace `var' = 999 if mi(`var')
}

replace religious = 3 if religious == 4
replace emp = 3 if emp == 2

gen election = iso + string(year)
encode election, gen(e)

/*
// Look at some country-specific regressions
local c SE
reg voteleft geduc_3 i.e if iso == "`c'" & year2 == 1960 [pw=weight]
di in red _b[geduc_3]
reg voteleft geduc_3 i.inc i.sex i.agerec i.religion i.religious i.rural i.region i.emp i.marital i.sector i.union i.house i.e if iso == "`c'" & year2 == 1960 [pw=weight]
di in red _b[geduc_3]
reg voteleft geduc_3 i.e if iso == "`c'" & year2 == 2010 [pw=weight]
di in red _b[geduc_3]
reg voteleft geduc_3 i.inc i.sex i.agerec i.religion i.religious i.rural i.region i.emp i.marital i.sector i.union i.house i.e if iso == "`c'" & year2 == 2010 [pw=weight]
di in red _b[geduc_3]
*/

// Run regressions
forval i = 1/15{
	gen b_`i' = .
	gen s_`i' = .
	gen p_`i' = .
}

levelsof year2, local(years)
foreach y in `years'{
di in red "`y'"

	qui reg voteleft geduc_3 i.e if year2 == `y' [pw=weight], robust cluster(id)
	replace b_1 = _b[geduc_3] if year2 == `y'
	replace s_1 = _se[geduc_3] if year2 == `y'
	replace p_1 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year2 == `y'
	
	qui reg voteleft geduc_3 i.inc i.e if year2 == `y' [pw=weight], robust cluster(id)
	replace b_2 = _b[geduc_3] if year2 == `y'
	replace s_2 = _se[geduc_3] if year2 == `y'
	replace p_2 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year2 == `y'
	
	qui reg voteleft geduc_3 i.inc i.sex i.e if year2 == `y' [pw=weight], robust cluster(id)
	replace b_3 = _b[geduc_3] if year2 == `y'
	replace s_3 = _se[geduc_3] if year2 == `y'
	replace p_3 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year2 == `y'

	qui reg voteleft geduc_3 i.inc i.sex i.agerec i.e if year2 == `y' [pw=weight], robust cluster(id)
	replace b_4 = _b[geduc_3] if year2 == `y'
	replace s_4 = _se[geduc_3] if year2 == `y'
	replace p_4 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year2 == `y'
	
	qui reg voteleft geduc_3 i.inc i.sex i.agerec i.religion i.e if year2 == `y' [pw=weight], robust cluster(id)
	replace b_5 = _b[geduc_3] if year2 == `y'
	replace s_5 = _se[geduc_3] if year2 == `y'
	replace p_5 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year2 == `y'
	
	qui reg voteleft geduc_3 i.inc i.sex i.agerec i.religion i.religious i.e if year2 == `y' [pw=weight], robust cluster(id)
	replace b_6 = _b[geduc_3] if year2 == `y'
	replace s_6 = _se[geduc_3] if year2 == `y'
	replace p_6 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year2 == `y'
	
	qui reg voteleft geduc_3 i.inc i.sex i.agerec i.religion i.religious i.rural i.e if year2 == `y' [pw=weight], robust cluster(id)
	replace b_7 = _b[geduc_3] if year2 == `y'
	replace s_7 = _se[geduc_3] if year2 == `y'
	replace p_7 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year2 == `y'
	
	qui reg voteleft geduc_3 i.inc i.sex i.agerec i.religion i.religious i.rural i.region i.e if year2 == `y' [pw=weight], robust cluster(id)
	replace b_8 = _b[geduc_3] if year2 == `y'
	replace s_8 = _se[geduc_3] if year2 == `y'
	replace p_8 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year2 == `y'
	
	qui reg voteleft geduc_3 i.inc i.sex i.agerec i.religion i.religious i.rural i.region i.emp i.marital i.e if year2 == `y' [pw=weight], robust cluster(id)
	replace b_9 = _b[geduc_3] if year2 == `y'
	replace s_9 = _se[geduc_3] if year2 == `y'
	replace p_9 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year2 == `y'

	qui reg voteleft geduc_3 i.inc i.sex i.agerec i.religion i.religious i.rural i.region i.emp i.marital i.sector i.e if year2 == `y' [pw=weight], robust cluster(id)
	replace b_10 = _b[geduc_3] if year2 == `y'
	replace s_10 = _se[geduc_3] if year2 == `y'
	replace p_10 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year2 == `y'

	qui reg voteleft geduc_3 i.inc i.sex i.agerec i.religion i.religious i.rural i.region i.emp i.marital i.sector i.union i.e if year2 == `y' [pw=weight], robust cluster(id)
	replace b_11 = _b[geduc_3] if year2 == `y'
	replace s_11 = _se[geduc_3] if year2 == `y'
	replace p_11 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year2 == `y'

	qui reg voteleft geduc_3 i.inc i.sex i.agerec i.religion i.religious i.rural i.region i.emp i.marital i.sector i.union i.house i.e if year2 == `y' [pw=weight], robust cluster(id)
	replace b_12 = _b[geduc_3] if year2 == `y'
	replace s_12 = _se[geduc_3] if year2 == `y'
	replace p_12 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year2 == `y'

	qui reg voteleft geduc_3 i.inc i.sex i.agerec i.religion i.religious i.rural i.region i.emp i.marital i.sector i.union i.house i.class i.e if year2 == `y' [pw=weight], robust cluster(id)
	replace b_13 = _b[geduc_3] if year2 == `y'
	replace s_13 = _se[geduc_3] if year2 == `y'
	replace p_13 = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3])) if year2 == `y'

}

keep year2 b_* s_* p_*
gduplicates drop

// Reshape long
greshape long b_ s_ p_, i(year2) j(var)
drop if mi(b_)
drop if year2 == 1950

// Format table
replace b = b * 100
tostring b, replace format(%4.1f) force
replace b = b + "*" if p < 0.1 & p > 0.05
replace b = b + "**" if p < 0.05 & p > 0.01
replace b = b + "***" if p < 0.01
drop p

replace s = s * 100
tostring s, replace format(%4.1f) force
replace s = "(" + s + ")"

destring var, replace

// Reshape wide
greshape wide b_ s_, i(var) j(year)

gen sort = _n
preserve
	keep var sort s*
	replace sort = sort + 0.5
	renvars s*, presub("s" "b")
	ren bort sort
	tempfile temp
	save `temp'
restore
append using `temp'
sort var sort
drop s_* sort

gen diff = real(subinstr(b_2010, "*", "", .)) - real(subinstr(b_1960, "*", "", .))

tostring var, replace
replace var = "Raw coefficient" if var == "1"
replace var = "After controlling for income" if var == "2"
replace var = "After controlling for the above and: Gender" if var == "3"
replace var = "After controlling for the above and: Age" if var == "4"
replace var = "After controlling for the above and: Religion" if var == "5"
replace var = "After controlling for the above and: Religious practice" if var == "6"
replace var = "After controlling for the above and: Rural/urban" if var == "7"
replace var = "After controlling for the above and: Region" if var == "8"
replace var = "After controlling for the above and: Employment/marital status" if var == "9"
replace var = "After controlling for the above and: Sector of employment" if var == "10"
replace var = "After controlling for the above and: Union membership" if var == "11"
replace var = "After controlling for the above and: Home ownership" if var == "12"
replace var = "After controlling for the above and: Subjective social class" if var == "13"

labvars b* "1960-69" "1970-79" "1980-89" "1990-99" "2000-09" "2010-20"
lab var diff "Difference 2010s-1960s"

replace var = "" if mod(_n, 2) == 0

export excel "$results/GMP2021.xlsx", sheet("educ_bycontrol") sheetreplace first(varl)



// -------------------------------------------------------------------------- //
// Table D10: Heterogeneity of education gradient
// -------------------------------------------------------------------------- //

use if west == 1 using "$work/gmp-educ", clear

// Generate relevant variables
drop year2
gen year2 = floor(year / 10) * 10
replace year2 = 2010 if year2 == 2020
replace year2 = 1950 if year2 == 1940

gen elec = iso + string(year)
encode elec, gen(e)

gen norel = (religion == "None") if !mi(religion)
*gen rel = inlist(religion, "Catholic", "Other Christian") if !mi(religion)
gen rel = !inlist(religion, "None") if !mi(religion)

levelsof year2, local(years)
foreach y in `years'{
foreach var of varlist sex rural norel rel sector class{
*local var class
*local y 1980

	reg voteleft geduc_3 i.e if `var' == 0 & year2 == `y' [pw=weight], robust cluster(id)
	local b0_`var'_`y' = _b[geduc_3]
	local s0_`var'_`y' = _se[geduc_3]
	local p0_`var'_`y' = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3]))
	*di "`b0_`var'_`y'' `s0_`var'_`y'' `p0_`var'_`y''"
	
	reg voteleft geduc_3 i.e if `var' == 1 & year2 == `y' [pw=weight], robust cluster(id)
	local b1_`var'_`y' = _b[geduc_3]
	local s1_`var'_`y' = _se[geduc_3]
	local p1_`var'_`y' = 2*ttail(e(df_r),abs(_b[geduc_3]/_se[geduc_3]))

}
}

// Create table
clear
set obs 1
gen id = 1
foreach y in `years'{
foreach var in sex rural norel rel sector class{
	gen b0_`var'_`y' = `b0_`var'_`y''
	gen s0_`var'_`y' = `s0_`var'_`y''
	gen p0_`var'_`y' = `p0_`var'_`y''
	gen b1_`var'_`y' = `b1_`var'_`y''
	gen s1_`var'_`y' = `s1_`var'_`y''
	gen p1_`var'_`y' = `p1_`var'_`y''
}
}

// Reshape
greshape long b0_ s0_ p0_ b1_ s1_ p1_, i(id) j(var) string
gen year = substr(var, -4, 4)
replace var = substr(var, 1, strlen(var) - 5)
renvars b0_ s0_ p0_ b1_ s1_ p1_, postsub("_" "")
drop id
greshape long b s p, i(var year) j(sub)

// Format table
replace b = b * 100
tostring b, replace format(%4.1f) force
replace b = b + "*" if p < 0.1 & p > 0.05
replace b = b + "**" if p < 0.05 & p > 0.01
replace b = b + "***" if p < 0.01
drop p

replace s = s * 100
tostring s, replace format(%4.1f) force
replace s = "(" + s + ")"

// Reshape wide
greshape wide b s, i(var sub) j(year)

gen diff = real(subinstr(b2010, "*", "", .)) - real(subinstr(b1950, "*", "", .))

gen sort = _n
preserve
	keep var sub sort s*
	replace sort = sort + 0.5
	renvars s*, presub("s" "b")
	renvars bub bort / sub sort
	tempfile temp
	save `temp'
restore
append using `temp'
sort sort
drop s1950-s2010 sort

// Drop specific items
drop if var == "rel" & sub == 0
drop if var == "norel" & sub == 0

// Label
gen lab = ""
replace lab = "Working/Lower class" if var == "class" & sub == 0
replace lab = "Middle/Upper class" if var == "class" & sub == 1
replace lab = "No religion" if var == "norel" & sub == 1
replace lab = "Christian / Other" if var == "rel" & sub == 1
replace lab = "Urban areas" if var == "rural" & sub == 0 
replace lab = "Rural areas" if var == "rural" & sub == 1
replace lab = "Private sector" if var == "sector" & sub == 0
replace lab = "Public sector" if var == "sector" & sub == 1
replace lab = "Men" if var == "sex" & sub == 0
replace lab = "Women" if var == "sex" & sub == 1

gen n = _n
gen sort = 1 if var == "sex"
replace sort = 2 if var == "rural"
replace sort = 3 if var == "norel"
replace sort = 3 if var == "rel"
replace sort = 4 if var == "sector"
replace sort = 5 if var == "class"
sort sort n

drop var sub n sort
order lab

replace lab = "" if mod(_n, 2) == 0

export excel "$results/GMP2021.xlsx", sheet("educ_hete") sheetreplace first(var)



// -------------------------------------------------------------------------- //
// Table E1 to Table E21: Regressions by country
// -------------------------------------------------------------------------- //

use if west == 1 using "$work/gmp-inc", clear

// Harmonize some variables and set missing values to an arbitrary value
replace year2 = floor(year / 10) * 10
replace year2 = 1950 if year2 == 1940
replace year2 = 2010 if year2 == 2020

replace religion = "Other" if inlist(religion, "Buddhist", "Hindu", "Jewish", "Sikh")
replace religion = "Other Christian" if religion == "Protestant"

gen rel = 1 if religion == "None"
replace rel = 2 if religion == "Catholic"
replace rel = 3 if religion == "Other Christian"
replace rel = 4 if religion == "Muslim"
replace rel = 5 if religion == "Other"
label define religion 1 "Religion: None" 2 "Religion: Catholic" 3 "Religion: Other Christian" 4 "Religion: Muslim" 5 "Religion: Other"
label values rel religion
drop religion
ren rel religion

replace region = "Region: " + region if !mi(region)
replace region = "Region: Gotland" if region == "Region: Götland" & iso == "SE" // issue with special characters in Excel
replace race = "Race/ethnicity/language: " + race if !mi(race)

foreach var of varlist vote2 region race{
	ren `var' x
	encode x, gen(`var')
	drop x
}
foreach var of varlist educ ginc agerec sex religion religious rural region race emp marital{
	replace `var' = 999 if mi(`var')
}

replace religious = 3 if religious == 4
replace emp = 3 if emp == 2

label define ginc 1 "Income group: Bottom 50%" 2 "Income group: Middle 40%" 3 "Income group: Top 10%", replace
label define educ 1 "Education: None/Primary" 2 "Education: Secondary" 3 "Education: University" 4 "Education: Postgraduate", replace
label define agerec 1 "Age: 20-39" 2 "Age: 40-59" 3 "Age: 60+", replace
label define sex 0 "Gender: Woman" 1 "Gender: Man", replace
label define religious 1 "Religious practice: Never" 2 "Religious practice: Less than monthly" 3 "Religious practice: Monthly or more" , replace
label define rural 0 "Location: Urban" 1 "Location: Rural", replace
label define emp 1 "Employment status: Employed" 3 "Employment status: Unemployed/Inactive" , replace
label define marital 0 "Marital status: Single" 1 "Marital status: Married/With partner", replace

foreach var of varlist agerec sex religion religious rural region race emp marital{
	label values `var' `var'
}

// Decade
tostring year2, replace force
replace year2 = "1950-59" if year2 == "1950"
replace year2 = "1960-69" if year2 == "1960"
replace year2 = "1970-79" if year2 == "1970"
replace year2 = "1980-89" if year2 == "1980"
replace year2 = "1990-99" if year2 == "1990"
replace year2 = "2000-09" if year2 == "2000"
replace year2 = "2010-20" if year2 == "2010"

// Aggregate some variable values for consistency over time
replace religion = 5 if iso == "US"  & inlist(religion, 1, 4)
replace race = 10 if iso == "NZ" & inlist(race, 2, 11)

// Drop some variables in countries where there are too inconsistently measured
replace religion = 999 if iso == "DK"
replace religion = 999 if iso == "IS"
replace religion = 999 if iso == "NO"
replace religion = 999 if iso == "SE"
replace religious = 999 if iso == "FR" // omitted in 1970s to 1990s so better to drop completely
replace religious = 999 if iso == "GB" // only two values
replace religious = 999 if iso == "IS"
replace religious = 999 if iso == "NO"
replace region = 999 if iso == "DE" & year < 1990
replace region = 999 if iso == "GB" // too inconsistent over the years
replace sex = 999 if iso == "CH" & year2 == "1960-69"

// Complete regression
levelsof iso, local(countries)
foreach c in `countries'{
di in red "`c'"
preserve
*local c SE
	
	keep if iso == "`c'"
	eststo clear
	levelsof year2, local(years) clean
	foreach y in `years'{
		eststo: reg voteleft i.educ i.ginc i.agerec i.sex i.religion i.religious i.rural i.region i.race i.emp i.marital if year2 == "`y'" [pw=weight], robust cluster(id)
	}

	esttab

	// Export to CSV
	local mlabels `years'
	esttab using "$work/temp.csv", ///
		cells(b(star fmt(3)) se(par)) noobs ///
		stats(r2 N N_clust, labels("R-squared" "Observations" "Clusters") fmt(%4.2f %4.0f %4.0f)) ///
		label varlabels(_cons Constant) legend replace ///
		mlabels(`mlabels') collabels(none) ///
		starlevels(* 0.10 ** 0.05 *** 0.01) ///
		order(*.educ *.ginc *.agerec *.sex *.religion *.religious *.rural *.emp *.marital *.race *.region)

	// Import back, clean up and export to Excel
	import delimited "$work/temp.csv", clear
	foreach var of varlist _all{
		replace `var'=substr(`var',3,.)
		replace `var'=substr(`var',1,strlen(`var')-1)
	}
	
	drop if v1 == "999" | v1[_n-1] == "999"
	
	ds v1, not
	foreach var of varlist `r(varlist)'{
		replace `var' = "(baseline)" if `var' == "0.000"
	}

	drop if _n == _N

	export excel "$results/GMP2021.xlsx", sheet("reg_`c'") sheetreplace first(var)
restore
}


// -------------------------------------------------------------------------- //
// Figure EA1 to Figure EB21: Vote for left-wing parties by income and education in each country
// -------------------------------------------------------------------------- //

foreach var in educ geduc dinc ginc{
*local var dinc
if inlist("`var'", "educ") use if west == 1 using "$work/gmp", clear
if inlist("`var'", "geduc") use if west == 1 using "$work/gmp-educ", clear
if inlist("`var'", "dinc", "ginc") use if west == 1 using "$work/gmp-inc", clear

if "`var'" != "dinc"{
gen sort = `var'
cap decode `var', gen(x)
drop `var'
ren x `var'
}
if "`var'" == "dinc" gen sort = dinc

replace year = floor(year / 10) * 10
replace year = 1950 if year == 1940
replace year = 2010 if year == 2020

drop if mi(`var')
gcollapse (mean) voteleft [pw=weight], by(iso year `var' sort)

greshape wide voteleft, i(iso `var' sort) j(year)

lab var voteleft1950 "1948-59"
lab var voteleft1960 "1960-69"
lab var voteleft1970 "1970-79"
lab var voteleft1980 "1980-89"
lab var voteleft1990 "1990-99"
lab var voteleft2000 "2000-09"
lab var voteleft2010 "2010-20"

sort iso sort
drop sort

export excel "$results/GMP2021.xlsx", sheet("byctr_voteby_`var'") sheetreplace first(varl)

}















