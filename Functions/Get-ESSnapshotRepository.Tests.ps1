$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	$goodUri = "http://some.esserver.com:12345"
	$goodCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
	$commonParams = @{ BaseURI = $goodUri; Credential = $goodCreds }
	
	$nameVal = "someRepo"
	
    Context "Standard parameter tests" {
		It "throws if the BaseURI parameter is null or not specified" {
			{ Test-Function -Credential $goodCreds -BaseURI } | Should Throw
		}
		
		It "throws if the Credential parameter is null or not specified" {
			{ Test-Function -BaseURI $goodUri -Credential } | Should Throw
		}
		
		It "passes the value for the BaseURI parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$goodUri/*" } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @commonParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value for the Credential parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Credential -eq $goodCreds } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @commonParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
	
	Context "Parameter Tests" {
		It "passes the default value if the Name parameter is not specified" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$goodUri/_snapshot/_all" } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @commonParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value of the Name parameter properly" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$goodUri/_snapshot/$nameVal" } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @commonParams -Name $nameVal
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
}