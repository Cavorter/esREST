function Set-ESRole {
	<#
		.SYNOPSIS
			Creates or updates a role in an ElasticSearch "native" realm
		.DESCRIPTION
			Creates or updates a role in an ElasticSearch "native" realm. Returns $true if the role is created or false if the role was updated.
			Wraps the POST method of the /_shield/role REST API.
		.PARAMETER Role
			A esREST.Role object that creates or updates a "native" realm role on the ElasticSearch cluster.
		.PARAMETER BaseURI
			The URI for an ElasticSearch server
		.PARAMETER Credential
			User account for specified ElasticSearch cluster
		.LINK
			https://www.elastic.co/guide/en/shield/current/configuring-rbac.html
			https://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-roles-rest
		.LINK
			New-ESRole
			Get-ESRole
			New-ESIndexPrivilegeGroup
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[esREST.Role]$Role,
		
		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
	)
	Begin {
		#set the destination URL
		[uri]$uri = $BaseURI + "/_shield/role/" + $Role.Name
		Write-Verbose "Target URI: $($uri.AbsoluteUri)"
		
		#convert the Role object to json
		$body = ConvertFrom-ESRole -Role $Role
		Write-Verbose "Request Body: $body"
	}
	Process {
		$result = Invoke-RestMethod -Method Post -ContentType "application/json" -Uri $uri.AbsoluteUri -Body $body -Credential $Credential
		if ( $result.role.created -eq $true ) {
			Write-Output $true
		} else {
			Write-Output $false
		}
	}
}
