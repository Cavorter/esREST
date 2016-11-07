# Load Functions
foreach ( $function in (Get-ChildItem -Path $PSScriptRoot\Functions\*.ps1 -Exclude *.Tests.*) ) {
	. $function.FullName
}