$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	$nameVal = "SomeRole"
	
	$indexPrivs = @()
	$indexPrivs += New-ESIndexPrivilegeGroup -Index "someindex" -Privilege read
	$indexPrivs += New-ESIndexPrivilegeGroup -Index "someotherindex" -Privilege all
	
	$singleRunasVal = "someuser"
	$multiRunasVal = "John T User","Jane D User"
	
    It "throws if the Name parameter is null or not specified" {
		{ Test-Function -Name } | Should Throw
    }
	
	It "processes the Name parameter properly" {
		( Test-Function -Name $nameVal ).Name | Should Be $nameVal
	}
	
	It "only accepts values from the esREST.ClusterPrivilege enumeration for the ClusterPrivilege parameter" {
		{ Test-Function -Name $nameVal -ClusterPrivilege "NotAPriv" } | Should Throw
	}
	
	foreach ( $priv in [enum]::GetValues( [type]'esREST.ClusterPrivilege') ) {
		It "accepts ClusterPrivilege value of $priv" {
			( Test-Function -Name $nameVal -ClusterPrivilege $priv ).ClusterPrivilege | Should Be $priv
		}
	}
	
	It "accepts multiple values for the ClusterPrivilege parameter" {
		$priv = "all","manage","transport_client"
		Compare-Object -ReferenceObject ( Test-Function -Name $nameVal -ClusterPrivilege $priv ).ClusterPrivilege -DifferenceObject $priv | Should BeNullOrEmpty
	}
	
	It "accepts a single object for the IndexPrivilegeGroup parameter" {
		Compare-Object -ReferenceObject ( Test-Function -Name $nameVal -IndexPrivilegeGroup $indexPrivs[0] ).IndexPrivilegeGroup -DifferenceObject $indexPrivs[0] | Should BeNullOrEmpty
	}
	
	It "accepts multiple objects for the IndexPrivilegeGroup parameter" {
		Compare-Object -ReferenceObject ( Test-Function -Name $nameVal -IndexPrivilegeGroup $indexPrivs ).IndexPrivilegeGroup -DifferenceObject $indexPrivs | Should BeNullOrEmpty
	}
	
	It "only accepts esREST.IndexPrivilegeGroup objects for the IndexPrivilegeGroup parameter" {
		{ Test-Function -Name $nameVal -IndexPrivilegeGroup 12345 } | Should Throw
	}
	
	It "accepts a single object for the RunAs parameter" {
		( Test-Function -Name $nameVal -RunAs $singleRunasVal ).RunAs | Should Be $singleRunasVal
	}
	
	It "accepts multiple objects for the RunAs parameter" {
		Compare-Object -ReferenceObject ( Test-Function -Name $nameVal -RunAs $multiRunasVal ).RunAs -DifferenceObject $multiRunasVal | Should BeNullOrEmpty
	}
	
	It "returns an object with the type esREST.Role" {
		Test-Function -Name $nameVal | Should BeOfType esREST.Role
	}
}
