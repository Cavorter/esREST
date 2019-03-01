function Test-ESIndex {
    <#
        .SYNOPSIS
            Tests if the specified index exists on the target server
        .DESCRIPTION
            Uses the Indices Exists API to determine if the specified index exists on the target server
        .PARAMETER Index
            The name of the index to test for
        .PARAMETER BaseURI
            The URI of the ElasticSearch server
        .PARAMETER Credential
            User credentials for the ElasticSearch server
        .LINK
            https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-exists.html
    #>
    Param (
        [Parameter(Mandatory=$true)]    
        [string]$Index,

		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential
    )

	begin {
		if ( $BaseURI[-1] -eq '/' ) { $BaseURI = $BaseURI.Substring( 0 , $BaseURI.Length - 1 ) }
		[uri]$uri = "$BaseURI/$Index"
		Write-Verbose "Uri: $($uri.AbsoluteUri)"
	}
	
	process {
		try {
			Invoke-RestMethod -UseBasicParsing -Credential $Credential -Uri $uri -Method Head | Out-Null
			$return = $true
		} catch {
			if ( $_.Exception.Message -eq "The remote server returned an error: (404) Not Found." ) {
				$return = $false
			} else {
				throw $_
			}
		}
		Write-Output $return
	}
}
