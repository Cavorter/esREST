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
        [Parameter(Mandatory = $true)]
        [string]$Index,
		
        [int]$Shards,
		
        [int]$Replicas,
		
        [Parameter(Mandatory = $true)]
        [string]$BaseURI,
		
        [Parameter(Mandatory = $true)]
        [pscredential]$Credential
    )
	
    begin {
        $bodyData = @{ settings = @{} }

		if ( $BaseURI[-1] -eq '/' ) { $BaseURI = $BaseURI.Substring( 0 , $BaseURI.Length - 1 ) }
        $uriString = "$BaseURI/$Index"
        # test if the index already exists
        if ( Test-ESIndex -Index $Index -BaseURI $BaseURI -Credential $Credential ) {
            # The index already exists, so use the Update method
            Write-Verbose "Index already exists. Updating uri string for update operation..."
			$uriString += "/_settings"
			
			Write-Warning "Unable to update shard count on an existing index!"
			# For more information see the following URLS:
			#  https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-update-settings.html
			#  https://www.elastic.co/guide/en/elasticsearch/reference/current/index-modules.html
        }
        else {
            # The index does not exist to use the create method
			Write-Verbose "Creating index $index on $BaseURI..."
			
			# Only attempt to set the shard count during index creation
			if ( $Shards ) { $bodyData.settings.number_of_shards = $Shards }
        }
        [uri]$uri = $uriString
        Write-Verbose "Uri: $($uri.AbsoluteUri)"
		
		# set the replica count
		if ( $Replicas )	{ $bodyData.settings.number_of_replicas = $Replicas }

		$body = $bodyData | ConvertTo-Json -Depth 100 -Compress
        Write-Verbose "Body: $body"
    }
	
    process {
        Invoke-RestMethod -UseBasicParsing -Credential $Credential -Uri $uri -Method Put -Body $body -ContentType "application/json" | Out-Null
    }
}