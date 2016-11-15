$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	$goodRole = New-Object -TypeName esREST.Role -Property @{ Name = "testRole1"; ClusterPrivilege = "all" }
	
	$goodUri = "http://some.esserver.com:12345"
	$goodCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
	$commonParams = @{ BaseUri = $goodUri; Credential = $goodCreds; }
	
    Context "Standard parameter tests" {
		It "throws if BaseURI parameter is null or not specified" {
			{ Test-Function -Role $goodRole -Credential $credVal -BaseURI } | Should Throw
		}
		
		It "throws if BaseURI parameter is null or not specified" {
			{ Test-Function -Role $goodRole -BaseURI $goodUri -Credential } | Should Throw
		}
		
		It "passes the value for the BaseURI parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$goodUri/*" } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @commonParams -Role $goodRole
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the credential object for the Credential object" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Credential -eq $goodCreds } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @commonParams -Role $goodRole
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
	
	Context "Parameter Tests" {
		It "throws if the Role parameter is null or not specified" {
			{ Set-ESRole @commonParams -Role } | Should Throw
		}
		
		It "only accepts esREST.Role objects for the Role parameter" {
			{ Set-ESRole @commonParams -Role "incorrectObject" } | Should Throw
		}
		
		It "passes the role name as part of the uri" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like ( "*/_shield/role/" + $goodRole.Name ) } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @commonParams -Role $goodRole
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "returns $true if the role was created" -Pending {
			Mock -CommandName Invoke-RestMethod -MockWith { return ('{"role":{"created": true }}' | ConvertFrom-JSON) }
			Set-ESRole @commonParams -Role $goodRole | Should Be $true
		}
		
		It "returns $false if the role was updated" {
			Mock -CommandName Invoke-RestMethod -MockWith { return ('{"role":{"created": false }}' | ConvertFrom-JSON) }
			Set-ESRole @commonParams -Role $goodRole | Should Be $false
		}
	}
}