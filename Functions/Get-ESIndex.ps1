function Get-ESIndex {
	<#
		.SYNOPSIS
			Retrieves the settings for an index from an ElasticSearch cluster.
		.DESCRIPTION
			Reads the _settings, _mappings, _warmers and _aliases features for the specified index or indices from an ElasticSearch cluster. Implements the GET method for the Index endpoint of the REST API.
		.PARAMETER Name
			The name of the index or indices to retrieve settings for. Accepts wildcard values.
		.LINKS
			https://www.elastic.co/guide/en/elasticsearch/reference/2.3/indices-get-index.html
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Name,
		
		[ValidateSet( "settings" , "mappings" , "warmers" , "aliases" , "stats" )]
		[string]$Feature = "settings",
		
		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
	)
	
	begin {
		if ( $BaseURI[-1] -eq '/' ) { $BaseURI = $BaseURI.Substring( 0 , $BaseURI.Length - 1 ) }
		[uri]$uri = "$BaseURI/$Name/_$($Feature.ToLower())"
		Write-Verbose "Uri: $($uri.AbsoluteUri)"
	}
	
	process {
		$result = Invoke-RestMethod -UseBasicParsing -Credential $Credential -Uri $uri
		$resultText = $result | ConvertTo-Json -Depth 100 -Compress
		Write-Verbose "Result: $resultText"
		Write-Output $result
	}
}