$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	$singleIndexVal = "index1"
	$multiIndexVal = "index1","index2","index3"
	
	$singlePrivVal = "all"
	$multiPrivVal = "manage","index","delete_index"
	
	$singleFieldVal = "field1"
	$multiFieldVal = "field1","field2","field3"
	
	It "throws if the Index parameter is null or not specified" {
		{ Test-Function -Privilege $singlePrivVal -Index } | Should Throw
	}
	
	It "accepts a single value for the index parameter" {
		( Test-Function -Index $singleIndexVal -Privilege $singlePrivVal ).Index | Should Be $singleIndexVal
	}
	
	It "accepts multiple values for the Index parameter" {
		Compare-Object -ReferenceObject ( Test-Function -Index $multiIndexVal -Privilege $singlePrivVal ).Index -DifferenceObject $multiIndexVal | Should BeNullOrEmpty
	}
	
	It "throws if the Privilege parameter is null or not specified" {
		{ Test-Function -Index $singleIndexVal -Privilege } | Should Throw
	}
	
	It "accepts a single value for the Privilege parameter" {
		( Test-Function -Index $singleIndexVal -Privilege $singlePrivVal ).Privilege | Should Be $singlePrivVal
	}
	
	It "accepts multiple values for the Privilege parameter" {
		Compare-Object -ReferenceObject ( Test-Function -Index $singleIndexVal -Privilege $multiPrivVal ).Privilege -DifferenceObject $multiPrivVal | Should BeNullOrEmpty
	}
	
	It "only accepts values from 'esIndexPrivilege' module variable" {
		{ Test-Function -Index $singleIndexVal -Privilege "NotAPrivilege" } | Should Throw
	}
	
	foreach ( $priv in $esIndexPrivilege ) {
		It "accepts esIndexPrivilege value of $priv" {
			( Test-Function -Index $singleIndexVal -Privilege $priv ).Privilege | Should Be $priv
		}
	}
	
	It "accepts a single value for the Field parameter" {
		( Test-Function -Index $singleIndexVal -Privilege $singlePrivVal -Field $singleFieldVal ).Field | Should Be $singleFieldVal
	}
	
	It "accepts multiple values for the Field parameter" {
		Compare-Object -ReferenceObject ( Test-Function -Index $singleIndexVal -Privilege $singlePrivVal -Field $multiFieldVal ).Field -DifferenceObject $multiFieldVal | Should BeNullOrEmpty
	}
	
	It "returns an object of type esREST.IndexPrivilegeGroup" {
		Test-Function -Index $singleIndexVal -Privilege $singlePrivVal | Should BeOfType esREST.IndexPrivilegeGroup
	}
}
