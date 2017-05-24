$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	
	$goodUri = "http://some.esserver.com:12345"
	$goodCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
	
	$indexVal = "someIndex"
	$goodAlias = "someAlias"
	$goodParams = @{ BaseURI = $goodUri; Credential = $goodCreds; Index = $indexVal; Alias = $goodAlias }
	
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	Context "Standard Parameter Tests" {
		foreach ( $mandatory in $goodParams.Keys ) {
			It "the Mandatory attribute for the $mandatory parameter is $true" {
				( Get-Command -Name $functionName ).Parameters."$mandatory".ParameterSets.__AllParameterSets.IsMandatory | Should Be $true
			}
		}
		
		$testResult = Test-Function @goodParams
		$assertParams = @{ CommandName = "Invoke-RestMethod"; Times = 1; Exactly = [switch]$true; Scope = "Context" }
		It "Passes the BaseURI to Invoke-RestMethod" {
			Assert-MockCalled @assertParams -ParameterFilter { $Uri -like "$goodUri*" }
		}
		
		It "Passes the Credential to Invoke-RestMethod" {
			Assert-MockCalled @assertParams -ParameterFilter { $Credential.UserName -eq $goodCreds.UserName }
		}
	}
	
	Context "Happy Path" {
		$testResult = Test-Function @goodParams
		
		$assertParams = @{ CommandName = "Invoke-RestMethod"; Times = 1; Exactly = [switch]$true; Scope = "Context" }
		It "Passes the Index to Invoke-RestMethod" {
			Assert-MockCalled @assertParams -ParameterFilter { $Uri -like "*/$indexVal/_alias/*" }
		}
		
		It "Passes the Alias to Invoke-RestMethod" {
			Assert-MockCalled @assertParams -ParameterFilter { $Uri -like "*/_alias/$goodAlias" }
		}
		
		It "Specifies the PUT method for Invoke-RestMethod" {
			Assert-MockCalled @assertParams -ParameterFilter { $Method -eq "Put" }
		}
	}
}