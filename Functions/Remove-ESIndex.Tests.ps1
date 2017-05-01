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
	
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	Context "Standard Parameter Tests" {
		$mandatoryKeys = @()
		$mandatoryKeys += $goodParams.Keys
		$mandatoryKeys += $commonParams.Keys
		foreach ( $mandatory in $mandatoryKeys ) {
			It "the Mandatory attribute for the $mandatory parameter is $true" {
				( Get-Command -Name $functionName ).Parameters."$mandatory".ParameterSets.__AllParameterSets.IsMandatory | Should Be $true
			}
		}
		
		$testResult = Test-Function @goodParams @commonParams
		It "passes the value for the BaseURI parameter" {
			Assert-MockCalled -Exactly 1 -Scope Context -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "$goodUri*" }
		}
		
		It "passes the value for the Credential parameter" {
			Assert-MockCalled -Exactly 1 -Scope Context -CommandName Invoke-RestMethod -ParameterFilter { $Credential -eq $goodCreds }
		}
	}
	
	Context "Happy Path" {
		$testResult = Test-Function @goodParams @commonParams
		
		It "passes the value of the Name parameter" {
			Assert-MockCalled -Exactly 1 -Scope Context -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "*/$nameVal" }
		}
		
		It "specifies the Delete method" {
			Assert-MockCalled -Exactly 1 -Scope Context -CommandName Invoke-RestMethod -ParameterFilter { $Method -eq "Delete" }
		}
	}
}