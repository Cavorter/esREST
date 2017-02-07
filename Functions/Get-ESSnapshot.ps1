function Get-ESSnapshot {
	<#
		.SYNOPSIS
			Retrieves info about a snapshot from a repository from an ElasticSearch cluster.
		.DESCRIPTION
			Retrieves information about one or more existing snapshots from a specified repository on an ElasticSearch cluster.
		.PARAMETER Repository
			The name of the repository
		.PARAMETER Name
			The name of a snapshot to look up
		.LINKS
			https://www.elastic.co/guide/en/elasticsearch/reference/2.3/indices-get-index.html
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Repository,
		
		[string]$Name = "_all",
		
		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
	)
	
	begin {
		if ( $BaseURI[-1] -eq '/' ) { $BaseURI = $BaseURI.Substring( 0 , $BaseURI.Length - 1 ) }
		[uri]$uri = "$BaseURI/_snapshot/$Repository/$Name"
		Write-Verbose "Uri: $($uri.AbsoluteUri)"
	}
	
	process {
		$result = Invoke-RestMethod -UseBasicParsing -Credential $Credential -Uri $uri
		$resultText = $result | ConvertTo-Json -Depth 100 -Compress
		Write-Verbose "Result: $resultText"
		Write-Output $result
	}
}