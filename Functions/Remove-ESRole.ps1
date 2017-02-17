function Remove-ESRole {
	<#
		.SYNOPSIS
			Removes a role from an ElasticSearch cluster
		.DESCRIPTION
			Deletes a role in the "native" realm in an ElasticSearch cluster.
			Wraps DELETE method of REST API at /_shield/role/<rolename>
		.PARAMETER Role
			The account to delete.
		.PARAMETER BaseURI
			The URI for an ElasticSearch server. If not specified uses the value of $env:esBaseURI
		.PARAMETER Credential
			User account for specified ElasticSearch server. If not specified users the value of $esCredential
		.LINKS
			https://www.elastic.co/guide/en/shield/current/shield-rest.html
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Role,
		
		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
	)
	
	begin {
		if ( $BaseURI[-1] -eq '/' ) { $BaseURI = $BaseURI.Substring( 0 , $BaseURI.Length - 1 ) }
		[uri]$uri = "$BaseURI/_shield/role/$Role"
		Write-Verbose "Uri: $($uri.AbsoluteUri)"
	}
	
	process {
		$result = Invoke-RestMethod -UseBasicParsing -Credential $Credential -Method Delete -Uri $uri
		$resultText = $result | ConvertTo-Json -Depth 100 -Compress
		Write-Verbose "Result: $resultText"
		if ( $result.found ) {
			Write-Verbose "Role $Role deleted."
		} else {
			Write-Verbose "Role $Role not found."
		}
		Write-Output $result.found
	}
}
