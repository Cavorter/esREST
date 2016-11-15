$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "Remove-ESUser" {
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	#store existing environment values
	$existingBaseUri = $env:esBaseUri
	$existingCredential = $esCredential
	
	$goodUri = "http://some.esserver.com:12345"
	$goodCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
	$commonParams = @{ BaseURI = $goodUri; Credential = $goodCreds }
	
	$goodUser = "someuser"
	$badUser = "notauser"
	$goodParams = @{ Username = $goodUser }
	
    Context "Standard parameter tests" {
		$env:esBaseUri = $null
		$esCredential = $null
		
		It "throws if the BaseURI parameter is null or not specified" {
			{ Remove-ESUser @goodParams -Credential $goodCreds -BaseURI } | Should Throw
		}
		
		It "throws if the Credential parameter is null or not specified" {
			{ Remove-ESUser @goodParams -BaseURI $goodUri -Credential } | Should Throw
		}
		
		It "passes the value for the BaseURI parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$goodUri/*" } }
			Mock @mockParams -MockWith { return $true }
			Remove-ESUser @goodParams @commonParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value for the Credential parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Credential -eq $goodCreds } }
			Mock @mockParams -MockWith { return $true }
			Remove-ESUser @goodParams @commonParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
	
	Context "Parameter Tests" {
		It "throws if the Username parameter is null or empty" {
			{ Remove-ESUser @commonParams -Username } | Should Throw
		}
		
		It "passes the value of the Username parameter properly" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "*/_shield/user/$goodUser" } }
			Mock @mockParams -MockWith { return $true }
			Remove-ESUser @goodParams @commonParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "returns $true if the user was deleted" -Pending {
			$resultVal = '{ "found" : true }' #| ConvertFrom-Json
			Mock -CommandName Invoke-RestMethod -MockWith { Write-Output $resultVal }
			Remove-ESUser @goodParams @commonParams -Verbose | Should Be $true
		}
	}
}
