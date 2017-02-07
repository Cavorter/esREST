$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	$goodUri = "http://some.esserver.com:12345"
	$goodCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
	$commonParams = @{ BaseURI = $goodUri; Credential = $goodCreds }
	
	$nameVal = "someIndex"
	$goodParams = @{ Name = $nameVal }
	
    Context "Standard parameter tests" {
		It "throws if the BaseURI parameter is null or not specified" {
			{ Test-Function @goodParams -Credential $goodCreds -BaseURI } | Should Throw
		}
		
		It "throws if the Credential parameter is null or not specified" {
			{ Test-Function @goodParams -BaseURI $goodUri -Credential } | Should Throw
		}
		
		It "passes the value for the BaseURI parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$goodUri/*" } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @goodParams @commonParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value for the Credential parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Credential -eq $goodCreds } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @goodParams @commonParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
	
	Context "Parameter Tests" {
		It "throws if the Name parameter is null or empty" {
			{ Test-Function @commonParams -Name } | Should Throw
		}
		
		It "passes the value of the Name parameter properly" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$goodUri/$nameVal/*" } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @goodParams @commonParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
}