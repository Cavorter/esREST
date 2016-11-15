function Remove-ESUser {
	<#
		.SYNOPSIS
			Removes a user from an ElasticSearch cluster
		.DESCRIPTION
			Deletes a user in the "native" realm in an ElasticSearch cluster.
			Wraps DELETE method of REST API at /_shield/user/<username>
		.PARAMETER Username
			The account to delete.
		.PARAMETER BaseURI
			The URI for an ElasticSearch server. If not specified uses the value of $env:esBaseURI
		.PARAMETER Credential
			User account for specified ElasticSearch server. If not specified users the value of $esCredential
		.LINKS
			https://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-users-rest
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Username,
		
		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
	)
	
	begin {
		if ( $BaseURI[-1] -eq '/' ) { $BaseURI = $BaseURI.Substring( 0 , $BaseURI.Length - 1 ) }
		[uri]$uri = "$BaseURI/_shield/user/$Username"
		Write-Verbose "Uri: $($uri.AbsoluteUri)"
	}
	
	process {
		$result = Invoke-RestMethod -UseBasicParsing -Credential $Credential -Method Delete -Uri $uri
		$resultText = $result | ConvertTo-Json -Depth 100 -Compress
		Write-Verbose "Result: $resultText"
		if ( $result.found ) {
			Write-Verbose "User $Username deleted."
		} else {
			Write-Verbose "User $Username not found."
		}
		Write-Output $result.found
	}
}
