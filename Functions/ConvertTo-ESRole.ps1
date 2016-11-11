function ConvertTo-ESRole {
	<#
		.SYNOPSIS
			Converts JSON to esREST.Role objects
		.DESCRIPTION
			Helper function to convert PSCustomObject converted from JSON from the ElasticSearch REST API to esREST.Role objects 
		.PARAMETER InputObject
			A PSCustomObject object to be converted to an esREST.Role object
		.LINK
			https://www.elastic.co/guide/en/shield/current/shield-rest.html#shield-roles-rest
			ConvertFrom-ESRole
			Get-ESRole
			New-ESRole
			Set-ESRole
	#>
	Param (
		[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
		[PSCustomObject[]]$InputObject
	)
	Begin {
		# Get the list of roles in the returned object
		$roleNames = ( $InputObject | Get-Member -MemberType NoteProperty ).Name
		Write-Verbose "Found $($roleNames.Count) roles to process"
	}
	Process {
		foreach ( $role in $roleNames ) {
			Write-Verbose "Processing role: $role"
			
			# Make the current role easier to reference
			$roleObj = $InputObject."$role"
			
			# Start a hashtable for properties to pass to New-Object
			$roleProps = @{ Name = $role }
			
			# Process the ClusterPrivileges
			$roleProps.ClusterPrivilege = $roleObj.cluster
			
			# Process the IndexPrivilegeGroups
			$roleProps.IndexPrivilegeGroup = @()
			foreach ( $privGroup in $roleObj.indices ) {
				$roleProps.IndexPrivilegeGroup += New-Object esREST.IndexPrivilegeGroup -Property @{ Index = $privGroup.names ; Privilege = $privGroup.privileges ; Field = $privGroup.fields }
			}
			
			# Process the RunAs items
			$roleProps.RunAs = $roleObj.run_as
			
			# Generate the Role object
			$result = New-Object esREST.Role -Property $roleProps
			
			Write-Output $result
		}
	}
}