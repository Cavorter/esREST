function Close-ESIndex {
	<#
		.SYNOPSIS
			Closes an index on an ElasticSearch cluster
		.DESCRIPTION
			Sets the state of an index to Closed on an ElasticSearch cluster
		.PARAMETER Name
			The name of the index or indices to retrieve settings for. Accepts wildcard values.
		.PARAMETER BaseURI
			The URI for an ElasticSearch server
		.PARAMETER Credential
			User account for specified ElasticSearch server
		.LINKS
			https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-open-close.html
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Name,
		
		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
	)
	
	begin {
		if ( $BaseURI[-1] -eq '/' ) { $BaseURI = $BaseURI.Substring( 0 , $BaseURI.Length - 1 ) }
		[uri]$uri = "$BaseURI/$Name/_close"
		Write-Verbose "Uri: $($uri.AbsoluteUri)"
	}
	
	process {
		$result = Invoke-RestMethod -UseBasicParsing -Credential $Credential -Uri $uri -Method Post
		$resultText = $result | ConvertTo-Json -Depth 100 -Compress
		Write-Verbose "Result: $resultText"
		Write-Output $result
	}
}