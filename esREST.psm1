# Load custom types
Add-Type -TypeDefinition (Get-Content $PSScriptRoot\esREST-Types.cs | Out-String)

$exportFunctions = @()
# Load Functions
foreach ( $function in (Get-ChildItem -Path $PSScriptRoot\Functions\*.ps1 -Exclude *.Tests.*) ) {
	. $function.FullName
	$exportFunctions += $function.Name.Split('.')[0]
}
Write-Verbose "Exported functions: $exportFunctions"

Export-ModuleMember -Function $exportFunctions