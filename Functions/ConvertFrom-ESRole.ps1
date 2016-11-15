function ConvertFrom-ESRole {
	<#
		.SYNOPSIS
			Converts one esREST.Role object to JSON
		.DESCRIPTION
			Helper function to convert esREST.Role objects to JSON notation for simple interaction with the ElasticSearch REST API.
		.PARAMETER Role
			An esREST.Role object to be converted to JSON.
		.LINK
			https://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-roles-rest
			ConvertTo-ESRole
			Get-ESRole
			New-ESRole
			Set-ESRole
	#>
	Param (
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[esREST.Role]$Role
	)
	Process {
		$result = @{}
		if ( $Role.ClusterPrivilege ) { $result.cluster = $Role.ClusterPrivilege }
		
		if ( $Role.IndexPrivilegeGroup ) {
			$result.indices = @()
			foreach ( $privGroup in $Role.IndexPrivilegeGroup ) {
				$privHash = @{}
				$privHash.names = $privGroup.Index
				$privHash.privileges = $privGroup.Privilege
				if ( $privGroup.Field ) { $privHash.fields = $privGroup.Field }
				$result.indices += $privHash
			}
		}
		
		if ( $Role.RunAs ) { $result.run_as = $Role.RunAs }
		Write-Output ( $result | ConvertTo-Json -Depth 100 -Compress )
	}
}