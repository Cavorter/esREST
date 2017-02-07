$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
	$goodUri = "http://some.esserver.com:12345"
	$goodCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
	$commonParams = @{ BaseURI = $goodUri; Credential = $goodCreds }
	
	$repoVal = "someRepo"
	$nameVal = "someSnapshot"
	$goodIndices = @("someIndex","someOtherIndex","YetAnotherIndex","AnIndexWithAWildcard*")
	$goodPattern = 'index_(.+)'
	$goodReplacement = 'restored_index_$1'
	
	$goodParams = @{ Repository = $repoVal; Name = $nameVal }
	
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
		It "passes the value of the Repository parameter properly" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$goodUri/_snapshot/$repoVal/*" } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @goodParams @commonParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "passes the value of the Name parameter properly" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$goodUri/_snapshot/$repoVal/$nameVal/_restore" } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @goodParams @commonParams
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "Passes the value of the Indices parameter properly" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ($Body | ConvertFrom-Json).indices -eq ( $goodIndices -join "," ) } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @goodParams @commonParams -Indices $goodIndices
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "Processes the IgnoreGlobalState parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ($Body | ConvertFrom-Json).include_global_state -eq $false } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @goodParams @commonParams -IgnoreGlobalState
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "Processes the IgnoreAliases parameter" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ($Body | ConvertFrom-Json).include_aliases -eq $false } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @goodParams @commonParams -IgnoreAliases
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
		
		It "Throws if the RenamePattern parameter is specified but the RenameReplacement parameter is NOT" {
			{ Test-Function @goodParams @commonParams -RenamePattern $goodPattern -RenameReplacement } | Should Throw
		}
		
		It "Throws if the RenamePattern parameter is NOT specified but the RenameReplacement parameter is" {
			{ Test-Function @goodParams @commonParams -RenameReplacement $goodReplacement -RenamePattern } | Should Throw
		}
		
		It "Passes the value of the RenamePattern and RenameReplacement parameters properly" {
			$mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ($Body | ConvertFrom-Json).rename_pattern -eq $goodPattern -and ($Body | ConvertFrom-Json).rename_replacement -eq $goodReplacement } }
			Mock @mockParams -MockWith { return $true }
			Test-Function @goodParams @commonParams -RenamePattern $goodPattern -RenameReplacement $goodReplacement
			Assert-MockCalled @mockParams -Exactly 1 -Scope It
		}
	}
}