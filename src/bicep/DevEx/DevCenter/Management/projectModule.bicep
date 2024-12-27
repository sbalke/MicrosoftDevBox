@description('Dev Center Name')
param devCenterName string

@description('Projects')
param workloadProjectsInfo array

@description('Dev Box Definitions')
param devBoxDefinitions array

@description('Role Definition Ids')
param roleDefinitions array

resource devCenter 'Microsoft.DevCenter/devcenters@2024-10-01-preview' existing = {
  name: devCenterName
  scope: resourceGroup()
}

@description('Contoso Dev Center Projects')
module projects 'projectResource.bicep' = [
  for project in workloadProjectsInfo: {
    name: '${project.name}-project'
    scope: resourceGroup()
    params: {
      devCenterName: devCenter.name
      name: project.name
      tags: project.tags
      projectCatalogsInfo: project.catalogs
      devBoxDefinitions: devBoxDefinitions
      networkConnectionName: project.networkConnectionName
      roleDefinitions: roleDefinitions
    }
  }
]
