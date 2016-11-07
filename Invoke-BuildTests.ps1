Param (
	[Parameter(Mandatory=$true)]
	[string]$ModuleName,
	
	[Parameter(Mandatory=$true)]
	[string]$Version
)

# Update module version numbers
Write-Output "Setting module version..."
[xml]$nuspec = Get-Content ".\$ModuleName.nuspec"
$nuspec.package.metadata.version = $Version
$nuspec.Save( "$PSScriptRoot\$ModuleName.nuspec" )

$verString = "ModuleVersion = '1.0'"
$manifest = Get-Content ".\$ModuleName.psd1"
$manifest[ $manifest.IndexOf($verString)] = "ModuleVersion = '$Version'"
$manifest | Out-File ".\$ModuleName.psd1"

# Ensure module dependencies are present
Write-Output "Ensuring module dependencies are available..."
foreach ( $module in ( $manifest | Out-String | Invoke-Expression ).RequiredModules ) {
	Write-Output "Attempting to detect module: $module"
	if ( -not ( Get-Module -Name $module ) ) {
		Write-Output "Installing required module: $module"
		Install-Module -Name $module -Scope CurrentUser -Force
	} else {
		Write-Ouptut "Module detected and available!"
	}
}

# Force import the local module before executing the tests
Write-Output "Importing $moduleName..."
Import-Module "$PSScriptRoot\$ModuleName.psd1" -Force

# Output the current function set for the module
Get-Command -Module $ModuleName

Write-Output "Executing tests..."
$testResults = Invoke-Pester -OutputFile Test.xml -OutputFormat NUnitXml -CodeCoverage (Get-ChildItem -Path $PSScriptRoot\*.ps1 -Exclude "*.Tests.*","Invoke-BuildTests.ps1" -Recurse ).FullName -PassThru
Write-Output "##teamcity[buildStatisticValue key='CodeCoverageAbsLTotal' value='$($testResults.CodeCoverage.NumberOfCommandsAnalyzed)']"
Write-Output "##teamcity[buildStatisticValue key='CodeCoverageAbsLCovered' value='$($testResults.CodeCoverage.NumberOfCommandsExecuted)']"