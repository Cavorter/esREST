$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	$goodUri = "http://some.esserver.com:12345"
	$goodCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
	
	$goodParams = @{ BaseUri = $goodUri; Credential = $goodCreds }
	
    Context "Standard parameter tests" {
		It "throws if BaseURI parameter is null or not specified" {
			{ Get-ESUser -Credential $credVal -BaseURI } | Should Throw
		}
		
		It "throws if BaseURI parameter is null or not specified" {
			{ Get-ESUser -BaseURI $goodUri -Credential } | Should Throw
		}
		
		It "passes the value for the BaseURI parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$goodUri/*" } }
			Mock @mockParams -MockWith { return $true }
			Get-ESUser @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the credential object for the Credential object" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Credential -eq $goodCreds } }
			Mock @mockParams -MockWith { return $true }
			Get-ESUser @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
	
	Context "Parameter Tests" {
		It "gets the complete list of users if the User parameter is not specified" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -eq "$goodUri/_shield/user" } }
			Mock @mockParams -MockWith { return $true }
			Get-ESUser @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "returns the specific user if a single string is specified in the User parameter" {
			$userVal = "user1"
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -eq "$goodUri/_shield/user/$userVal" } }
			Mock @mockParams -MockWith { return $true }
			Get-ESUser @goodParams -User $userVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "returns all users specified if multiple strings are specified in the User parameter" {
			$userVal = @( "user1" , "user2" , "user3" )
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -eq "$goodUri/_shield/user/$( $userVal -join ',')" } }
			Mock @mockParams -MockWith { return $true }
			Get-ESUser @goodParams -User $userVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
}