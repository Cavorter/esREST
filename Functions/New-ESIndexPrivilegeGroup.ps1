function New-ESIndexPrivilegeGroup {
	<#
		.SYNOPSIS
			Generates a new IndexPrivilegeGroup object used with Set-ESRole
		.DESCRIPTION
			The Set-ESRole function allows for one or more specific sets of privileges to be set for indices in an ElasticSearch cluster. This function helps generate objects to populate the Role parameter for Set-ESRole.
			
			This function does not yet support the query/document property.
		.PARAMETER Index
			One or more index these privileges will apply to in the ElasticSearch cluster.
		.PARAMETER Privilege
			The name of one or more privileges to set for the specified indices.
		.PARAMETER Field
			The name of one or more fields to restrict the scope of the role in the specified indices.
		.EXAMPLE
			C:\PS> $privGroup = New-ESIndexPrivilegeGroup -Index "foo","bar" -Privilege read
			C:\PS> Set-ESRole -Role foobar_read -IndexPrivilegeGroup $privGroup -BaseURI http://some.escluster.url:12345 -Credential (Get-Credential)
			
			While creating a new role that grants the Read privilege to the foo and bar indices we first generate an IndexPrivilegeGroup with those specifications and then pass the resulting object to Set-ESRole.
		.EXAMPLE
			C:\PS> $baseUri = "http://some.escluster.url:12345"; $esCreds = Get-Credential
			C:\PS> $existingRole = Get-ESRole -Role morecomplicated -BaseURI $baseUri -Credential $esCreds
			C:\PS> $existingRole.PrivilegeGroup += New-ESIndexPrivilegeGroup -Index someindex -Privilege all
			C:\PS> $existingRole.PrivilegeGroup += New-ESIndexPrivilegeGroup -Index yetanotherindex -Privilege read -Field "source","message"
			C:\PS> Set-ESRole -Role $existingRole -BaseURI $baseUri -Credential $esCreds
			
			Reads an existing role called "morecomplicated" and then adds two new IndexPrivilegeGroups to the role object before updating the role on the cluster.
		.LINK
			https://www.elastic.co/guide/en/shield/current/configuring-rbac.html
	#>
	Param (
		[Parameter(Mandatory=$true)]
		[string[]]$Index,
		
		[string[]]$Field
		
		<# TODO - Implement query/document property
		[hashtable]$Query
		#>
	)
    DynamicParam {
		# Generate the Privilege parameter
		$RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
		
		$ParameterName = 'Privilege'
		$AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
		$ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
		$ParameterAttribute.Mandatory = $Mandatory
		$ParameterAttribute.Position = 1
		$AttributeCollection.Add($ParameterAttribute)

		# Set the ValidateSet
		$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute( [enum]::GetValues( [type]'esREST.IndexPrivilege') )
		$AttributeCollection.Add($ValidateSetAttribute)
		
		$RuntimeParameterDictionary.Add( $ParameterName, ( New-Object System.Management.Automation.RuntimeDefinedParameter( $ParameterName, [string[]], $AttributeCollection ) ) )
		return $RuntimeParameterDictionary
    }
	Begin {
		$Privilege = $PsBoundParameters['Privilege']
	}
	Process {
		$result = New-Object -TypeName esRest.IndexPrivilegeGroup -Property @{ Index = $Index; Privilege = $Privilege; Field = $Field }
		Write-Output $result
	}
}