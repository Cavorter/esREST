$functionName = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Split('.')[0]
. "$PSScriptRoot\$functionName.ps1"

Set-Alias -Name Test-Function -Value $functionName -Scope Script

Describe "$functionName" {
	$jsonSingleVal = '{"single_role":{"cluster":["all"],"indices":[{"names":["index1"],"privileges":["all"],"fields":["body"],"query":"{\"match\":{\"title\":\"foo\"}}"}],"run_as":["other_user"]}}'
	$jsonMultiVal = '{"multi_role":{"cluster":["manage","transport_client"],"indices":[ {"names":["index1","index2"],"privileges":["index","create"],"fields":["title","body"],"query":"{\"match\":{\"title\":\"foo\"}}"}, {"names":["index3"],"privileges":["all"]} ],"run_as": [ "other_user","other_user2" ]}}'
	
	$roleSingleVal = ConvertTo-ESRole -Input ( $jsonSingleVal | ConvertFrom-Json )
	$roleMultiVal = ConvertTo-ESRole -Input ( $jsonMultiVal | ConvertFrom-Json )
	
    It "throws if the Role parameter is null or empty" {
        { Test-Function -Role } | Should Throw
    }
	
	It "only accepts esREST.Role objects for the Role parameter" {
		{ Test-Function -Role "InvalidObject" } | Should Throw
	}
	
	Context "Validate single parameter values" {
		$result = Test-Function -Role $roleSingleVal | ConvertFrom-Json
		$compare = $jsonSingleVal | ConvertFrom-Json
		
		It "populates a single ClusterPrivilege property" {
			$result.cluster | Should Be $compare.single_role.cluster
		}
		
		It "populates single IndexPrivilegeGroup properties as single indices" {
			$result.indices.Count | Should Be $compare.single_role.indices.Count
		}
		
		It "populates a single IndexPrivilegeGroup's Index property as an indice's names property" {
			$result.indices.names | Should Be $compare.single_role.indices.names
		}
		
		It "populates a single IndexPrivilegeGroup's Privilege property as an indice's privileges property" {
			$result.indices.privileges | Should Be $compare.single_role.indices.privileges
		}
		
		It "populates a single IndexPrivilegeGroup's Field property as an indice's fields property" {
			$result.indices.fields | Should Be $compare.single_role.indices.fields
		}
		
		It "populates a single IndexPrivilegeGroup's Query property as an indices query property" {
		}
		
		It "populates a single RunAs property" {
			$result.run_as | Should Be $compare.single_role.run_as
		}
	}
	
	Context "Validate multiple parameter values" {
		$result = Test-Function -Role $roleMultiVal | ConvertFrom-Json
		$compare = $jsonMultiVal | ConvertFrom-Json
		
		It "populates multiple ClusterPrivilege properties" {
			Compare-Object -ReferenceObject $result.cluster -DifferenceObject $compare.multi_role.cluster | Should BeNullOrEmpty
		}
		
		It "populates multiple IndexPrivilegeGroup properties as multiple indices" {
			$result.indices.Count | Should Be $compare.multi_role.indices.Count
		}
		
		It "populates multiple IndexPrivilegeGroup's Index properties as an indice's names property" {
			Compare-Object -ReferenceObject $result.indices[0].names -DifferenceObject $compare.multi_role.indices[0].names | Should BeNullOrEmpty
		}
		
		It "populates multiple IndexPrivilegeGroup's Privilege properties as an indice's privileges property" {
			Compare-Object -ReferenceObject $result.indices[0].privileges -DifferenceObject $compare.multi_role.indices[0].privileges | Should BeNullOrEmpty
		}
		
		It "populates multiple IndexPrivilegeGroup's Field properties as an indice's fields property" {
			Compare-Object -ReferenceObject $result.indices[0].fields -DifferenceObject $compare.multi_role.indices[0].fields | Should BeNullOrEmpty
		}
		
		It "populates multiple IndexPrivilegeGroup's Query properties as an indices query property" {
		}
		
		It "populates multiple RunAs properties" {
			Compare-Object -ReferenceObject $result.run_as -DifferenceObject $compare.multi_role.run_as | Should BeNullOrEmpty
		}
	}
}
