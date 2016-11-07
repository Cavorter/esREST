function Get-ESUser {
	<#
		.SYNOPSIS
			Returns one or more users from an ElasticSearch cluster
		.DESCRIPTION
			Returns one or more users from an ElasticSearch cluster.
			Wraps the /_shield/user REST endpoint.
		.PARAMETER User
			One or more user accounts to return.
		.PARAMETER BaseURI
			The URI for an ElasticSearch server. If not specified uses the value of $env:esBaseURI
		.PARAMETER Credential
			User account for specified ElasticSearch server. If not specified users the value of $esCredential
		.LINKS
			https://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-users-rest
	#>
	[CmdletBinding()]
	Param (
		[string[]]$User,
		
		[ValidateNotNullOrEmpty()]
		[string]$BaseURI = $env:esBaseURI,
		
		[ValidateScript({ $_ -ne $null })]
		[pscredential]$Credential = $esCredential
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
