$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Get-ESUser" {
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	#store existing environment values
	$existingBaseUri = $env:esBaseUri
	$existingCredential = $esCredential
	
	$globalUri = "http://some.esserver.com:12345"
	$localUri = "http://someother.esserver.com:23456"
	$globalCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
	$localCreds = [pscredential]::new( "SomeLocalUser" , ( ConvertTo-SecureString -String "SomeLocalPassword" -AsPlainText -Force ) )
	
    Context "Standard parameter tests" {
		$env:esBaseUri = $null
		$esCredential = $null
		
		It "throws if the BaseURI parameter and esBaseUri environment variables are null or not specified" {
			$env:esBaseUri = $null
			$esCredential = $globalCreds
			{ Get-ESUser } | Should Throw
		}
		
		It "throws if the Credential parameter and esCredential global variables are null or not specified" {
			<# NRS 11/7/2016 - Disabling this test until it can be tested accurately
			$env:esBaseUri = $globalUri
			$esCredential = $null
			{ Get-ESUser } | Should Throw
			#>
		}
		
		It "passes the value for the BaseURI parameter if specified" {
			$env:esBaseUri = $globalUri
			$esCredential = $globalCreds
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$localUri/*" } }
			Mock @mockParams -MockWith { return $true }
			Get-ESUser -BaseURI $localUri
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the credential object for the Credential object if specified" {
			$env:esBaseUri = $globalUri
			$esCredential = $globalCreds
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Credential -eq $localCreds } }
			Mock @mockParams -MockWith { return $true }
			Get-ESUser -Credential $localCreds
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value for the global esBaseUri variable if the BaseURI parameter is not specified" {
			$env:esBaseUri = $globalUri
			$esCredential = $globalCreds
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$globalUri/*" } }
			Mock @mockParams -MockWith { return $true }
			Get-ESUser
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the credential object for the global esCredential variable if the Credential parameter is not specified" {
			$env:esBaseUri = $globalUri
			$esCredential = $globalCreds
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Credential -eq $globalCreds } }
			Mock @mockParams -MockWith { return $true }
			Get-ESUser
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
	
	Context "Parameter Tests" {
		$env:esBaseUri = $globalUri
		$esCredential = $globalCreds
		
		It "gets the complete list of users if the User parameter is not specified" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -eq "$env:esBaseUri/_shield/user" } }
			Mock @mockParams -MockWith { return $true }
			Get-ESUser
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "returns the specific user if a single string is specified in the User parameter" {
			$userVal = "user1"
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -eq "$env:esBaseUri/_shield/user/$userVal" } }
			Mock @mockParams -MockWith { return $true }
			Get-ESUser -User $userVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "returns all users specified if multiple strings are specified in the User parameter" {
			$userVal = @( "user1" , "user2" , "user3" )
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -eq "$env:esBaseUri/_shield/user/$( $userVal -join ',')" } }
			Mock @mockParams -MockWith { return $true }
			Get-ESUser -User $userVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
	
	#restore environment values
	$env:esBaseUri = $existingBaseUri
	$esCredential = $existingCredential
}