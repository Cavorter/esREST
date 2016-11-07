$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Set-ESUser" {
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	#store existing environment values
	$existingBaseUri = $env:esBaseUri
	$existingCredential = $esCredential
	
	$globalUri = "http://some.esserver.com:12345"
	$localUri = "http://someother.esserver.com:23456"
	$globalCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
	$localCreds = [pscredential]::new( "SomeLocalUser" , ( ConvertTo-SecureString -String "SomeLocalPassword" -AsPlainText -Force ) )
	
	$usernameVal = "SomeUser"
	$passwordVal = "SomePassword123"
	$rolesSingleVal = "SomeRole"
	$rolesMultiVal = @( "SomeOtherRole","YetAnotherRole" )
	$fullnameVal = "Jane D. User"
	$emailVal = "someuser@some.domain.com"
	$metadataVal = @{ param1 = "Some value"; param2 = $false; paramList = @( 3..9 ) }
	
	$goodParams = @{ Username = $usernameVal; Password = $passwordVal }
	
    Context "Standard parameter tests" {
		$env:esBaseUri = $null
		$esCredential = $null
		
		It "throws if the BaseURI parameter and esBaseUri environment variables are null or not specified" {
			$env:esBaseUri = $null
			$esCredential = $globalCreds
			{ Set-ESUser @goodParams } | Should Throw
		}
		
		It "throws if the Credential parameter and esCredential global variables are null or not specified" {
			<# NRS 11/7/2016 - Disabling this test until it can be tested accurately
			$env:esBaseUri = $globalUri
			$esCredential = $null
			{ Set-ESUser @goodParams } | Should Throw
			#>
		}
		
		It "passes the value for the BaseURI parameter if specified" {
			$env:esBaseUri = $globalUri
			$esCredential = $globalCreds
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$localUri/*" } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @goodParams -BaseURI $localUri
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the credential object for the Credential object if specified" {
			$env:esBaseUri = $globalUri
			$esCredential = $globalCreds
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Credential -eq $localCreds } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @goodParams -Credential $localCreds
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value for the global esBaseUri variable if the BaseURI parameter is not specified" {
			$env:esBaseUri = $globalUri
			$esCredential = $globalCreds
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$globalUri/*" } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the credential object for the global esCredential variable if the Credential parameter is not specified" {
			$env:esBaseUri = $globalUri
			$esCredential = $globalCreds
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Credential -eq $globalCreds } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
	
    Context "Parameter Tests" {
		$env:esBaseUri = $globalUri
		$esCredential = $globalCreds
		
		It "throws if the Username parameter is null or not specified" {
			{ Set-ESUser -Password $passwordVal -Username } | Should Throw
		}
		
		It "passes the value of the Username parameter in the uri" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "*$Username" } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "throws if the Password parameter is null or not specified" {
			{ Set-ESUser -Username $usernameVal -Password } | Should Throw
		}
		
		It "passes the value of the Password parameter in the body of the request" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ( $Body | ConvertFrom-JSON ).password -eq $passwordVal } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes a single value for the Roles parameter in the body of the request" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ( $Body | ConvertFrom-JSON ).roles -eq $rolesSingleVal } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @goodParams -Roles $rolesSingleVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes multiple values for the Roles parameter in the body of the request" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { -not ( Compare-Object -ReferenceObject ( $Body | ConvertFrom-JSON ).roles -DifferenceObject $rolesMultiVal ) } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @goodParams -Roles $rolesMultiVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value of the FullName parameter in the body of the request" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ( $Body | ConvertFrom-JSON ).'full_name' -eq $fullnameVal } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @goodParams -FullName $fullnameVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value of the Email parameter in the body of the request" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ( $Body | ConvertFrom-JSON ).email -eq $emailVal } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @goodParams -Email $emailVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value of the Metadata parameter in the body of the request" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { -not ( Compare-Object -ReferenceObject ( $Body | ConvertFrom-JSON ).metadata -DifferenceObject (New-Object -TypeName psobject -Property $metadataVal ) ) } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @goodParams -Metadata $metadataVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
	
	#restore environment values
	$env:esBaseUri = $existingBaseUri
	$esCredential = $existingCredential
}