function Restore-ESSnapshot {
	<#
		.SYNOPSIS
			Restores a snapshot from a repository on an ElasticSearch cluster.
		.DESCRIPTION
			Restores a snapshot from a repository on an ElasticSearch cluster.
		.PARAMETER Repository
			The name of the repository
		.PARAMETER Name
			The name of a snapshot to retore
		.PARAMETER Indices
			A list of indices to restore. If not specified will restore all indices in the snapshot.
		.PARAMETER IgnoreGlobalState
			If specified will NOT restore the global cluster state at the time the snapshot was taken.
		.PARAMETER IgnoreAliases
			If specified will NOT restore aliases with the specified indices.
		.PARAMETER RenamePattern
			An ElasticSearch compatible regular expression pattern to identify which indices to rename during the restore operation. (Required if RenameReplacement is specified)
		.PARAMETER RenameReplacement
			A pattern to replace the name of any indices matched with RenamePattern. (Required if RenamePattern is specified)
		.LINKS
			https://www.elastic.co/guide/en/elasticsearch/reference/2.3/indices-get-index.html
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory=$true)]
		[string]$Repository,
		
		[Parameter(Mandatory=$true)]
		[string]$Name,
		
		[Parameter(Mandatory=$false)]
		[string[]]$Indices,
		
		[Parameter(Mandatory=$false)]
		[switch]$IgnoreGlobalState,
		
		[Parameter(Mandatory=$false)]
		[switch]$IgnoreAliases,
		
		[Parameter(Mandatory=$false)]
		[string]$RenamePattern,
		
		[Parameter(Mandatory=$false)]
		[string]$RenameReplacement,
		
		[Parameter(Mandatory=$true)]
		[string]$BaseURI,
		
		[Parameter(Mandatory=$true)]
		[pscredential]$Credential,
		
		[switch]$Wait
	)
	
	begin {
		$ErrorActionPreference = "Stop"
		if ( $BaseURI[-1] -eq '/' ) { $BaseURI = $BaseURI.Substring( 0 , $BaseURI.Length - 1 ) }
		[uri]$uri = "$BaseURI/_snapshot/$Repository/$Name/_restore"
		Write-Verbose "Uri: $($uri.AbsoluteUri)"
		
		$options = @{}
		if ( $Indices ) { $options.indices = $Indices -join "," }
		if ( $IgnoreGlobalState ) { $options.include_global_state = $false }
		if ( $IgnoreAliases ) { $options.include_aliases = $false }
		if ( $RenamePattern -or $RenameReplacement ) {
			if ( ( -not $RenamePattern ) -and ( -not $RenameReplacement ) ) {
				throw "One of RenamePattern or RenameReplacement parameters specified without specifying BOTH! (RenamePattern: $RenamePattern; RenameReplacement: $RenameReplacement)"
			} else {
				$options.rename_pattern = $RenamePattern
				$options.rename_replacement = $RenameReplacement
			}
		}
		
		if ( $options -ne @{} ) {
			$invokeParams = @{ Body = $options | ConvertTo-Json -Depth 100 -Compress }
		}
		Write-Verbose ( "Restore Options: {0}" -f $invokeParams.Body )
	}
	
	process {
		$result = Invoke-RestMethod -Method Post -UseBasicParsing -Credential $Credential -Uri $uri @invokeParams
		$resultText = $result | ConvertTo-Json -Depth 100 -Compress
		Write-Verbose "Result: $resultText"
		Write-Output $result
	}
}