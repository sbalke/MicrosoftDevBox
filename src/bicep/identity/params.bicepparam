using 'identityModule.bicep'

@description('Workload Name')
param workloadName  = 'Contoso'

@description('Workload Role Definitions')
param workloadRoleDefinitions = [
  'Owner'
  'Contributor'
  'Deployment Environments Reader'
  'Deployment Environments User'
  'DevCenter Dev Box User'
  'DevCenter Project Admin'
  'User Access Administrator'
]
