function Get-ESSnapshotRepository {
	<#
		.SYNOPSIS
			Retrieves the registered snapshot repositories from an ElasticSearch cluster.
		.DESCRIPTION
			Retrieves one or more registered snapshot repositories from an ElasticSearch cluster.
		.PARAMETER Name
			The name of the repository. Accepts wildcard values.
		.LINKS
			https://www.elastic.co/guide/en/elasticsearch/reference/2.3/indices-get-index.html
	#>
	[CmdletBinding()]
	Param (
		[string]$Name = "_all",
		
		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
	)
	
	begin {
		if ( $BaseURI[-1] -eq '/' ) { $BaseURI = $BaseURI.Substring( 0 , $BaseURI.Length - 1 ) }
		[uri]$uri = "$BaseURI/_snapshot/$Name"
		Write-Verbose "Uri: $($uri.AbsoluteUri)"
	}
	
	process {
		$result = Invoke-RestMethod -UseBasicParsing -Credential $Credential -Uri $uri
		$resultText = $result | ConvertTo-Json -Depth 100 -Compress
		Write-Verbose "Result: $resultText"
		Write-Output $result
	}
}