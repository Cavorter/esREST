$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	$goodUri = "http://some.esserver.com:12345"
	$goodCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
	$commonParams = @{ BaseURI = $goodUri; Credential = $goodCreds }
	
	$srcVal = "someIndex"
	$destVal = "someOtherIndex"
	$goodParams = @{ Source = $srcVal; Destination = $destVal }
	
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
		foreach ( $missing in $goodParams.Keys ) {
			$testCase = $goodParams.Clone()
			$testCase."$missing" = $null
			It "throws if the $missing parameter is null or not specified" {
				{ Test-Function @testCase } | Should Throw
			}
		}
		
		It "passes the value of the Source parameter properly" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ( $Body | ConvertFrom-JSon ).source.index -eq $srcVal } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @goodParams @commonParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value of the Destination parameter properly" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ( $Body | ConvertFrom-JSon ).dest.index -eq $destVal } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @goodParams @commonParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
}