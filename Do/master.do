
// -------------------------------------------------------------------------- //
// Set directories
// -------------------------------------------------------------------------- //

global dropbox "/Users/ollehammar/Dropbox/Brahmin_Replication/Replication/Replication_Data"

if substr("`c(pwd)'",1,14)=="C:\Users\Amory"{
	global dropbox "/Users/ollehammar/Dropbox/Brahmin_Replication/Replication/Replication_Data"
}

if substr("`c(pwd)'",1,16)=="C:\Users\Amory G" | substr("`c(pwd)'",1,4)=="C:\W"{
	global dropbox "/Users/ollehammar/Dropbox/Brahmin_Replication/Replication/Replication_Data"
}

global user "$dropbox"

global do "$user/Do"
global results "$user/Results"

global work "$user/Data"
global cmp "$user/Data"

cd "$work"




