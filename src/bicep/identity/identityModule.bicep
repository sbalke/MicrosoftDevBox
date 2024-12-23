@description('Workload Name')
param workloadName string

@description('Workload Role Definitions')
param workloadRoleDefinitions array 

module customRole 'customRoleResource.bicep' = {
  name: 'customRole'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
  }
}

@description('Custom Role Name')
output customRoleName string = customRole.outputs.customRoleName

var customRoleArray = [customRole.outputs.customRoleId]

var roleDefinitions = union(workloadRoleDefinitions, customRoleArray) 

module managedIdentity 'managedIdentityResource.bicep' = {
  name: 'managedIdentity'
  scope: resourceGroup()
  params: {
    name: '${workloadName}-identity'
  }
}

@description('Managed Identity Role Assignment')
module roleAssignments 'roleAssignmentModule.bicep' = {
  name: 'managedIdentity-RoleAssignments'
  params: {
    principalId: managedIdentity.outputs.principalId
    roleDefinitions: roleDefinitions
  }
}

@description('Role Definition Ids')
output roleDefinitions array = roleDefinitions
