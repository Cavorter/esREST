$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
    Mock -CommandName Invoke-RestMethod -MockWith { return $true }
	
    $goodUri = "http://some.esserver.com:12345"
    $goodCreds = [pscredential]::new( "SomeUser" , ( ConvertTo-SecureString -String "SomePassword" -AsPlainText -Force ) )
    $commonParams = @{ BaseURI = $goodUri; Credential = $goodCreds }
	
    $indexVal = "someIndex"
    $goodParams = @{ Index = $indexVal }
	
    $shardsVal = 3
		$replicasVal = 27
		
		Mock -CommandName Test-ESIndex -MockWith { return $false }
	
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
        It "throws if the Index parameter is null or empty" {
            { Test-Function @commonParams -Index } | Should Throw
        }
		
        It "passes the value of the Index parameter properly" {
            $mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { $Uri -like "$goodUri/$indexVal" } }
            Mock @mockParams -MockWith { return $true }
            Test-Function @goodParams @commonParams
            Assert-MockCalled @mockParams -Exactly 1 -Scope It
        }
		
        It "Passes the value of the Shards parameter properly" {
            $mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ( $Body | ConvertFrom-JSon ).settings.number_of_shards -eq $shardsVal } }
            Mock @mockParams -MockWith { return $true }
            Test-Function @goodParams @commonParams -Shards $shardsVal
            Assert-MockCalled @mockParams -Exactly 1 -Scope It
        }
		
        It "Passes the value of the Replicas parameter properly" {
            $mockParams = @{ CommandName = "Invoke-RestMethod"; ParameterFilter = { ( $Body | ConvertFrom-JSon ).settings.number_of_replicas -eq $replicasVal } }
            Mock @mockParams -MockWith { return $true }
            Test-Function @goodParams @commonParams -Replicas $replicasVal
            Assert-MockCalled @mockParams -Exactly 1 -Scope It
        }
    }
}