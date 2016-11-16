function Set-ESIndex {
	<#
		.SYNOPSIS
			Creates or updates an index on an ElasticSearch cluster
		.DESCRIPTION
			Creates or updates an index on an ElasticSearch cluster.
			Implementes the PUT method of the Index REST API.
		.PARAMETER Index
			The name of the index to create or update.
		.PARAMETER Shards
			The number of shards to assign to the index. If not specified will assign the cluster default value.
		.PARAMETER Replicas
			The number of replicas to assign to the index. If not specified will assign the cluster default value.
		.LINKS
			https://www.elastic.co/guide/en/elasticsearch/reference/2.3/indices-create-index.html
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Index,
		
		[int]$Shards,
		
		[int]$Replicas,
		
		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
	)
	
	begin {
		if ( $BaseURI[-1] -eq '/' ) { $BaseURI = $BaseURI.Substring( 0 , $BaseURI.Length - 1 ) }
		[uri]$uri = "$BaseURI/$Index"
		Write-Verbose "Uri: $($uri.AbsoluteUri)"
		
		$bodyData = @{ settings = @{} }
		if ( $Shards )		{ $bodyData.settings.number_of_shards = $Shards }
		if ( $Replicas )	{ $bodyData.settings.number_of_replicas = $Replicas }
		$body = $bodyData | ConvertTo-Json -Depth 100 -Compress
		Write-Verbose "Body: $body"
	}
	
	process {
		$result = Invoke-RestMethod -UseBasicParsing -Credential $Credential -Uri $uri -Method Post -Body $body -ContentType "application/json"
		$resultText = $result | ConvertTo-Json -Depth 100 -Compress
		Write-Verbose "Result: $resultText"
		Write-Output $result
	}
}