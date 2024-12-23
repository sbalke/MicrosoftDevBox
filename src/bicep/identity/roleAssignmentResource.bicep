@description('Dev Center Name')
param principalId string 

@description('Role Definition Ids')
param roleDefinitionId string 

targetScope = 'subscription'

@description('Role Assignment')
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id, principalId)
  scope: subscription()
  properties: {
    principalId: principalId
    roleDefinitionId: roleDefinitionId
    principalType: 'ServicePrincipal'
  }
}
