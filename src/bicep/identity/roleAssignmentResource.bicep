@description('Dev Center Name')
param principalId string = '45100800-8f03-4e70-aa91-c47eb8d842d5'

@description('Role Definition Ids')
param roleDefinitionName string = 'b24988ac-6180-42a0-ab88-20f7382dd24c'

targetScope = 'subscription'

resource roleDefinition 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' existing = {
  name: roleDefinitionName
}

output roleName string = roleDefinition.properties.roleName




// @description('Role Assignment')
// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(subscription().id, principalId, roleDefinition.id)
//   scope: subscription()
//   properties: {
//     principalId: principalId
//     roleDefinitionId: roleDefinition.properties.core
//     principalType: 'ServicePrincipal'
//   }
// }
