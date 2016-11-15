$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	$goodUri = "http://some.esserver.com:12345"
	$goodCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
	
	$rolesSingleVal = "SomeRole"
	$rolesMultiVal = @( "SomeOtherRole","YetAnotherRole" )
	
	$goodParams = @{ BaseUri = $goodUri; Credential = $goodCreds }
	
    Context "Standard parameter tests" {
		It "throws if BaseURI parameter is null or not specified" {
			{ Get-ESRole -Credential $credVal -BaseURI } | Should Throw
		}
		
		It "throws if BaseURI parameter is null or not specified" {
			{ Get-ESRole -BaseURI $goodUri -Credential } | Should Throw
		}
		
		It "passes the value for the BaseURI parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$goodUri/*" } }
			Mock @mockParams -MockWith { return $true }
			Get-ESRole @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the credential object for the Credential object" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Credential -eq $goodCreds } }
			Mock @mockParams -MockWith { return $true }
			Get-ESRole @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
	
	Context "Parameter Tests" {
		It "gets the complete list of roles if the Name parameter is not specified" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -eq "$goodUri/_shield/role" } }
			Mock @mockParams -MockWith { return $true }
			Get-ESRole @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "returns the specific role if a single string is specified in the Name parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -eq "$goodUri/_shield/role/$rolesSingleVal" } }
			Mock @mockParams -MockWith { return $true }
			Get-ESRole -Name $rolesSingleVal @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "returns all roles specified if multiple strings are specified in the Name parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -eq "$goodUri/_shield/role/$( $rolesMultiVal -join ',')" } }
			Mock @mockParams -MockWith { return $true }
			Get-ESRole -Name $rolesMultiVal @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
}