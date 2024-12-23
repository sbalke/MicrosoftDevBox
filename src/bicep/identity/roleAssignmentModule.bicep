@description('Dev Center Name')
param principalId string

@description('Role Definition Ids')
param roleDefinitions array

@description('Role Assignments')
module roleAssignment 'roleAssignmentResource.bicep' = [
  for roleDefinition in roleDefinitions: {
    name: 'roleAssignment${roleDefinition}'
    scope: subscription()
    params: {
      principalId: principalId
      roleDefinitionId: roleDefinition
    }
  }
]
