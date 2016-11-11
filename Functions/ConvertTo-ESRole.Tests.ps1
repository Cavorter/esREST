$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	$singleJsonVal = '"single_role":{"cluster":["all"],"indices":[{"names":["index1"],"privileges":["all"],"fields":["body"],"query":"{\"match\":{\"title\":\"foo\"}}"}],"run_as":["other_user"]}'
	$multiJsonVal = '"multi_role":{"cluster":["manage","transport_client"],"indices":[{"names":["index1","index2"],"privileges":["index","create"],"fields":["title","body"],"query":"{\"match\":{\"title\":\"foo\"}}"},{"names":["index3"],"privileges":["all"]}],"run_as": [ "other_user","other_user2" ]}'
	
	$singleRoleVal = "{ $singleJsonVal }" | ConvertFrom-Json
	$multiRoleVal = "{ $singleJsonVal , $multiJsonVal }" | ConvertFrom-Json
	
    It "throws if the InputObject parameter is null or empty" {
        { Test-Function -InputObject } | Should Throw
    }
	
	It "returns nothing if a non-PSCustomObject object is passed to the InputObject parameter" {
		#( "This is not a PSCustomObject" | Test-Function ) | Should BeNullOrEmpty
	}
	
	Context "Validate single parameter values" {
		$result = Test-Function -InputObject $singleRoleVal
		
		It "populates the Name property" {
			$result.Name | Should Be ( $singleRoleVal | Get-Member -MemberType NoteProperty ).Name
		}
		
		It "populates a single ClusterPrivilege property" {
			Compare-Object -DifferenceObject $singleRoleVal.single_role.cluster -ReferenceObject $result.ClusterPrivilege | Should BeNullOrEmpty
		}
		
		It "populates single IndexPrivilegeGroup properties as single indices" {
			$result.IndexPrivilegeGroup.Count | Should Be $singleRoleVal.single_role.indices.Count
		}
		
		It "populates a single IndexPrivilegeGroup's Index property as an indice's names property" {
			Compare-Object -DifferenceObject $singleRoleVal.single_role.indices.names -ReferenceObject $result.IndexPrivilegeGroup.Index | Should BeNullOrEmpty
		}
		
		It "populates a single IndexPrivilegeGroup's Privilege property as an indice's privileges property" {
			Compare-Object -DifferenceObject $singleRoleVal.single_role.indices.privileges -ReferenceObject $result.IndexPrivilegeGroup.Privilege | Should BeNullOrEmpty
		}
		
		It "populates a single IndexPrivilegeGroup's Field property as an indice's fields property" {
			Compare-Object -DifferenceObject $singleRoleVal.single_role.indices.fields -ReferenceObject $result.IndexPrivilegeGroup.Field | Should BeNullOrEmpty
		}
		
		It "populates a single IndexPrivilegeGroup's Query property as an indices query property" {
		}
		
		It "populates a single RunAs property" {
			Compare-Object -DifferenceObject $singleRoleVal.single_role.run_as -ReferenceObject $result.RunAs | Should BeNullOrEmpty
		}
	}
	
	Context "Validate multiple parameter values" {
		$result = Test-Function -InputObject $multiRoleVal
		
		It "populates the Name property" {
			$result.Name | Should Be ( $multiRoleVal | Get-Member -MemberType NoteProperty ).Name
		}
		
		It "populates multiple ClusterPrivilege properties" {
			Compare-Object -DifferenceObject $multiRoleVal.multi_role.cluster -ReferenceObject $result[0].ClusterPrivilege | Should BeNullOrEmpty
		}
		
		It "populates multiple IndexPrivilegeGroup properties from multiple indices" {
			$result[0].IndexPrivilegeGroup.Count | Should Be $multiRoleVal.multi_role.indices.Count
		}
		
		It "populates a single IndexPrivilegeGroup's Index property as an indice's names property" {
			Compare-Object -DifferenceObject $multiRoleVal.multi_role.indices[0].names -ReferenceObject $result[0].IndexPrivilegeGroup[0].Index | Should BeNullOrEmpty
		}
		
		It "populates a single IndexPrivilegeGroup's Privilege property as an indice's privileges property" {
			Compare-Object -DifferenceObject $multiRoleVal.multi_role.indices[0].privileges -ReferenceObject $result[0].IndexPrivilegeGroup[0].Privilege | Should BeNullOrEmpty
		}
		
		It "populates a single IndexPrivilegeGroup's Field property as an indice's fields property" {
			Compare-Object -DifferenceObject $multiRoleVal.multi_role.indices[0].fields -ReferenceObject $result[0].IndexPrivilegeGroup[0].Field | Should BeNullOrEmpty
		}
		
		It "populates a single IndexPrivilegeGroup's Query property as an indices query property" {
		}
		
		It "populates a single RunAs property" {
			Compare-Object -DifferenceObject $multiRoleVal.multi_role.run_as -ReferenceObject $result[0].RunAs | Should BeNullOrEmpty
		}
	}
}
