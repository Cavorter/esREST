$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	$goodUri = "http://some.esserver.com:12345"
	$goodCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
	$commonParams = @{ BaseURI = $goodUri; Credential = $goodCreds }
	
	$nameVal = "someIndex"
	$featureValues = @( "settings" , "mappings" , "warmers" , "aliases" , "stats" )
	$goodParams = @{ Name = $nameVal }
	
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
	
	Context "Parameter Tests" {
		Test-Function @goodParams @commonParams
		
		It "passes the value of the Name parameter properly" {
			Assert-MockCalled -Exactly 1 -Scope Context -CommandName Invoke-RestMethod -ParameterFilter { $Uri -like "$goodUri/$nameVal/*" }
		}
		
		It -Name "the Feature parameter accepts only specific values"  -Test {
			$result = Compare-Object -DifferenceObject (Get-Command -Name $functionName ).Parameters.Feature.Attributes.ValidValues -ReferenceObject $featureValues
			$result | Should BeNullOrEmpty
		}
	}
}