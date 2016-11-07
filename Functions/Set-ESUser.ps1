function Set-ESUser {
	<#
		.SYNOPSIS
			Updates or creates a native user on an ElasticSearch cluster.
		.DESCRIPTION
			Updates or creates a native user on an ElasticSearch cluster and returns an object with the account information using the Shield plugin.
			
			If the "created" property of the returned object is True the account was created. If the property is False the account was updated.
			
			Wraps the POST method of the /_shield/user/<username> REST api.
		.PARAMETER Username
			The name of the user to create
		.PARAMETER Password
			The password to set for the new account
		.PARAMETER Roles
			One or more roles to set for the new account
		.PARAMETER FullName
			The display name for the account
		.PARAMETER Email
			An email address to associate with the account.
		.PARAMETER Metadata
			A hashtable of arbitrary custom settings for the user.
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
		[ValidateNotNullOrEmpty()]
		[string]$Username,
		
		[Parameter(Mandatory=$true)]
		[ValidateNotNullOrEmpty()]
		[string]$Password,
		
		[string[]]$Roles,
		
		[string]$FullName,
		
		[string]$Email,
		
		[hashtable]$Metadata,
		
		[ValidateNotNullOrEmpty()]
		[string]$BaseURI = $env:esBaseURI,
		
		[ValidateScript({ $_ -ne $null })]
		[pscredential]$Credential = $esCredential
	)
	Begin {
		# Set the request URI
		[uri]$uri = [uri]::new( [uri]$BaseURI , "/_shield/user/$Username" )
		Write-Verbose "Request URI: $($uri.AbsoluteUri)"
		
		# create the request body
		$bodyHash = @{ password = $Password }
		if ( $Roles )		{ $bodyHash.roles		= @( $Roles );	Write-Verbose "Roles added to request body" }
		if ( $FullName )	{ $bodyHash.'full_name'	= $FullName;	Write-Verbose "FullName added to request body" }
		if ( $Email )		{ $bodyHash.email		= $Email;		Write-Verbose "Email added to request body" }
		if ( $Metadata )	{ $bodyHash.metadata	= $Metadata;	Write-Verbose "Metadata added to request body" }
		# convert the hashtable to JSON
		$body = $bodyHash | ConvertTo-JSON -Depth 100 -Compress
		Write-Verbose "Request Body: $body"
	}
	Process {
		$result = Invoke-RestMethod -Method Post -Body $body -ContentType "application/json" -Uri $uri -Credential $Credential
		if ( $result.user.created ) {
			Write-Verbose "User $Username created."
		} else {
			Write-Verbose "User $Username updated."
		}
		Write-Output $result
	}
}
