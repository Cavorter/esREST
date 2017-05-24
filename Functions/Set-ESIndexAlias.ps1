function Set-ESIndexAlias {
	<#
		.SYNOPSIS
			Creates an alias for an index
		.DESCRIPTION
			Adds an alias to an index
		.PARAMETER Index
			The name of the index. Wildcards are not permitted.
		.PARAMETER Alias
			The name of the alias to add.
		.PARAMETER BaseURI
			The URI for a server in an ElasticSearch cluster
		.PARAMETER Credential
			Credential object for the specified cluster
		.LINKS
			https://www.elastic.co/guide/en/elasticsearch/reference/2.3/indices-aliases.html
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Index,
		
		[Parameter(Mandatory=$true)]
		[string]$Alias,
		
		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
	)
	
	begin {
		if ( $BaseURI[-1] -eq '/' ) { $BaseURI = $BaseURI.Substring( 0 , $BaseURI.Length - 1 ) }
		[uri]$uri = "$BaseURI/$Index/_alias/$Alias"
		Write-Verbose "Uri: $($uri.AbsoluteUri)"
	}
	
	process {
		$result = Invoke-RestMethod -UseBasicParsing -Credential $Credential -Uri $uri -Method Put
		$resultText = $result | ConvertTo-Json -Depth 100 -Compress
		Write-Verbose "Result: $resultText"
		Write-Output $result
	}
}