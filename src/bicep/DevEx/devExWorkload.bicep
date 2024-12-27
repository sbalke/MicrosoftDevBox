@description('Workload Name')
param workloadName string

@description('Workload Role Definitions')
param workloadRoleDefinitions array 

@description('Network Connections')
param networkConnectionsCreated array 

@description('Contoso Dev Center Catalog')
param contosoDevCenterCatalogInfo object 

@description('Projects')
param contosoProjectsInfo array

@description('Tags')
param tags object = {
  workload: '${workloadName}-DevExp'
  landingZone: 'DevExp'
  resourceType: 'DevCenter'
  ProductTeam: 'Platform Engineering'
  Environment: 'Production'
  Department: 'IT'
  offering: 'DevBox-as-a-Service'
}

@description('Environment Types Info')
param environmentTypesInfo array 

@description('Contoso Dev Center Dev Box Definitions')
param contosoDevCenterDevBoxDefinitionsInfo array 

@description('Dev Center Resource')
module devCenter 'DevCenter/devCenterResource.bicep' = {
  name: 'devCenter'
  scope: resourceGroup()
  params: {
    name: workloadName
    location: resourceGroup().location
    catalogItemSyncEnableStatus: 'Enabled'
    microsoftHostedNetworkEnableStatus: 'Enabled'
    installAzureMonitorAgentEnableStatus: 'Enabled'
    tags: tags
  }
}

@description('Role Assignment Resource')
module roleAssignments  '../identity/roleAssignmentResource.bicep' = {
  scope: subscription()
  name: 'devCenter-roleAssignments'
  params: {
    principalId: devCenter.outputs.devCenterPrincipalId
    roleDefinitions: workloadRoleDefinitions
  }
}
@description('Network Connection Attachment Resource')
module networkConnectionAttachment 'DevCenter/NetworkConnection/networkConnectionAttachmentResource.bicep' = {
  name: 'devCenter-networkAttachments'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.outputs.devCenterName
    networkConnectionsCreated: networkConnectionsCreated
  }
}

@description('Environment Type Resource')
module environmentTypes 'DevCenter/EnvironmentConfiguration/environmentTypesResource.bicep' = [
  for environmentType in environmentTypesInfo: {
    name: 'devCenter-${environmentType.name}-envType'
    scope: resourceGroup()
    params: {
      devCenterName: devCenter.outputs.devCenterName
      name: environmentType.name
      tags: tags
    }
    dependsOn: [
      networkConnectionAttachment
      roleAssignments
    ]
  }
]


@description('Contoso Dev Center Catalog')
module contosoDevCenterCatalog 'DevCenter/EnvironmentConfiguration/devCentercatalogsResource.bicep' = {
  name: 'devCenter-devCenterCatalog'
  scope: resourceGroup()
  params: {
    name: contosoDevCenterCatalogInfo.name
    tags: tags
    branch: contosoDevCenterCatalogInfo.branch
    devCenterName: devCenter.outputs.devCenterName
    path: contosoDevCenterCatalogInfo.path
    syncType: contosoDevCenterCatalogInfo.syncType
    type: contosoDevCenterCatalogInfo.type
    uri: contosoDevCenterCatalogInfo.uri
  }
  dependsOn: [
    networkConnectionAttachment
    roleAssignments
  ]
}

@description('Dev Center Dev Box Definitions')
module devCenterDevBoxDefinitions 'DevCenter/EnvironmentConfiguration/devBoxDefinitionResource.bicep' = {
  name: 'devCenter-devBoxDefinitions'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.outputs.devCenterName
    devBoxDefinitionsInfo: contosoDevCenterDevBoxDefinitionsInfo
  }
  dependsOn: [
    networkConnectionAttachment
    roleAssignments
  ]
}

@description('Contoso Dev Center Projects')
module contosoDevCenterProjects 'DevCenter/Management/projectResource.bicep' = [
  for project in contosoProjectsInfo: {
    name: 'devCenter-${project.name}-project'
    scope: resourceGroup()
    params: {
      devCenterName: devCenter.outputs.devCenterName
      name: project.name
      tags: project.tags
      projectCatalogsInfo: project.catalogs
      devBoxDefinitions: devCenterDevBoxDefinitions.outputs.devBoxDefinitions
      networkConnectionName: project.networkConnectionName
      roleDefinitions: workloadRoleDefinitions
    }
    dependsOn: [
      networkConnectionAttachment
      roleAssignments
    ]
  }
]
