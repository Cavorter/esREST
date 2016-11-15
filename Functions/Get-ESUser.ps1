function Get-ESUser {
	<#
		.SYNOPSIS
			Returns one or more native users from an ElasticSearch cluster
		.DESCRIPTION
			Returns one or more native users from an ElasticSearch cluster.
			
			NOTE: This will not retrieve information for users from the "file realm" on a cluster and if no users exist in the "native" realm then no records will be returned.
			
			Wraps the /_shield/user REST endpoint.
		.PARAMETER User
			One or more user accounts to return. If the parameter is not specified all native users are returned.
		.PARAMETER BaseURI
			The URI for an ElasticSearch server
		.PARAMETER Credential
			User account for specified ElasticSearch server
		.LINKS
			https://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-users-rest
	#>
	[CmdletBinding()]
	Param (
		[string[]]$User,
		
		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
	)
	Begin {
		$prefix = "/_shield/user"
		[uri]$uri = [uri]::new( [uri]$BaseURI , $prefix )
		Write-Verbose "Target URI: $($uri.AbsoluteUri)"
		if ( $User ) {
			[uri]$uri = [uri]::new( $uri , "$prefix/" + ( $User -join "," ) )
			Write-Verbose "Target URI: $($uri.AbsoluteUri)"
		}
	}
	Process {
		$result = Invoke-RestMethod -Uri $uri.AbsoluteUri -Credential $Credential
		Write-Verbose "Returned $($result.Count) results"
		Write-Output $result
	}
}
