function Copy-ESIndex {
	<#
		.SYNOPSIS
			Copies the contents of one index into another.
		.DESCRIPTION
			Making use of the Reindex API, this function copies the documents from one index into another.
		.PARAMETER Source
			The index to copy from
		.PARAMETER Destination
			The index to copy to
		.LINK
			https://www.elastic.co/guide/en/elasticsearch/reference/2.3/docs-reindex.html
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Source,
		
		[Parameter(Mandatory=$true)]
		[string]$Destination = "settings",
		
		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
	)
	
	begin {
		if ( $BaseURI[-1] -eq '/' ) { $BaseURI = $BaseURI.Substring( 0 , $BaseURI.Length - 1 ) }
		[uri]$uri = "$BaseURI/_reindex"
		Write-Verbose "Uri: $($uri.AbsoluteUri)"
		
		$body = "{`"source`":{`"index`":`"$Source`"},`"dest`":{`"index`":`"$Destination`"}}"
		Write-Verbose "Body: $body"
	}
	
	process {
		$result = Invoke-RestMethod -Method Post -UseBasicParsing -Credential $Credential -Uri $uri -Body $body
		$resultText = $result | ConvertTo-Json -Depth 100 -Compress
		Write-Verbose "Result: $resultText"
		Write-Output $result
	}
}