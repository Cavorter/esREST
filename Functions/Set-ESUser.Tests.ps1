$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	$goodUri = "http://some.esserver.com:12345"
	$goodCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
	$commonParams = @{ BaseUri = $goodUri; Credential = $goodCreds }
	
	$usernameVal = "SomeUser"
	$passwordVal = "SomePassword123"
	$rolesSingleVal = "SomeRole"
	$rolesMultiVal = @( "SomeOtherRole","YetAnotherRole" )
	$fullnameVal = "Jane D. User"
	$emailVal = "someuser@some.domain.com"
	$metadataVal = @{ param1 = "Some value"; param2 = $false; paramList = @( 3..9 ) }
	
	$goodParams = @{ Username = $usernameVal; Password = $passwordVal }
	
    Context "Standard parameter tests" {
		It "throws if BaseURI parameter is null or not specified" {
			{ Set-ESUser @goodParams -Credential $credVal -BaseURI } | Should Throw
		}
		
		It "throws if BaseURI parameter is null or not specified" {
			{ Set-ESUser @goodParams -BaseURI $goodUri -Credential } | Should Throw
		}
		
		It "passes the value for the BaseURI parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$goodUri/*" } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @commonParams @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the credential object for the Credential object" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Credential -eq $goodCreds } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @commonParams @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
	
    Context "Parameter Tests" {
		It "throws if the Username parameter is null or not specified" {
			{ Set-ESUser @commonParams -Password $passwordVal -Username } | Should Throw
		}
		
		It "passes the value of the Username parameter in the uri" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "*$Username" } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @commonParams @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "throws if the Password parameter is null or not specified" {
			{ Set-ESUser @commonParams -Username $usernameVal -Password } | Should Throw
		}
		
		It "passes the value of the Password parameter in the body of the request" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ( $Body | ConvertFrom-JSON ).password -eq $passwordVal } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @commonParams @goodParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes a single value for the Roles parameter in the body of the request" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ( $Body | ConvertFrom-JSON ).roles -eq $rolesSingleVal } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @commonParams @goodParams -Roles $rolesSingleVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes multiple values for the Roles parameter in the body of the request" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { -not ( Compare-Object -ReferenceObject ( $Body | ConvertFrom-JSON ).roles -DifferenceObject $rolesMultiVal ) } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @commonParams @goodParams -Roles $rolesMultiVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value of the FullName parameter in the body of the request" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ( $Body | ConvertFrom-JSON ).'full_name' -eq $fullnameVal } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @commonParams @goodParams -FullName $fullnameVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value of the Email parameter in the body of the request" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ( $Body | ConvertFrom-JSON ).email -eq $emailVal } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @commonParams @goodParams -Email $emailVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value of the Metadata parameter in the body of the request" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { -not ( Compare-Object -ReferenceObject ( $Body | ConvertFrom-JSON ).metadata -DifferenceObject (New-Object -TypeName psobject -Property $metadataVal ) ) } }
			Mock @mockParams -MockWith { return $true }
			Set-ESUser @commonParams @goodParams -Metadata $metadataVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
}