function Remove-ESIndex {
	<#
		.SYNOPSIS
			Removes an index from the cluster
		.DESCRIPTION
			Removes an index from the cluster
		.PARAMETER Name
			The name of the index to remove
		.PARAMETER BaseURI
			The URI of the ElasticSearch server to interact with
		.PARAMETER Credential
			PSCredential object for the specified ElasticSearch cluster
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
		[uri]$uri = "$BaseURI/$Name"
		Write-Verbose "Uri: $($uri.AbsoluteUri)"
	}
	
	process {
		$result = Invoke-RestMethod -UseBasicParsing -Credential $Credential -Uri $uri -Method Delete
		$resultText = $result | ConvertTo-Json -Depth 100 -Compress
		Write-Verbose "Result: $resultText"
		Write-Output $result
	}
}