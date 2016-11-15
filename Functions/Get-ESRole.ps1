function Get-ESRole {
	<#
		.SYNOPSIS
			Retrieves the native roles from an ElasticSearch cluster
		.DESCRIPTION
			Retrieves the security roles in the "native" Shield realm from an ElasticSearch cluster.
			Wraps the GET method of the /_shield/role REST API.
		.PARAMETER Name
			The names of one or more roles to retrieve. If not specified returns all native roles configured in the cluster.
		.PARAMETER BaseURI
			The URI for an ElasticSearch server
		.PARAMETER Credential
			User account for specified ElasticSearch server
		.LINKS
			https://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-roles-rest
	#>
	[CmdletBinding()]
	Param (
		[string[]]$Name,
		
		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
	)
	Begin {
		$prefix = "/_shield/role"
		[uri]$uri = [uri]::new( [uri]$BaseURI , $prefix )
		Write-Verbose "Target URI: $($uri.AbsoluteUri)"
		if ( $Name ) {
			[uri]$uri = [uri]::new( $uri , "$prefix/" + ( $Name -join "," ) )
			Write-Verbose "Target URI: $($uri.AbsoluteUri)"
		}
	}
	Process {
		$result = Invoke-RestMethod -Uri $uri.AbsoluteUri -Credential $Credential
		Write-Verbose "Returned $($result.Count) results"
		Write-Output $result
	}
}
