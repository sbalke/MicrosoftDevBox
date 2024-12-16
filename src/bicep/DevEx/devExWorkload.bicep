@description('Workload Name')
param workloadName string

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName string

@description('Network Connections')
param networkConnections array

@description('Contoso Dev Center Catalog')
var contosoDevCenterCatalogInfo = {
  name: 'Contoso-DevCenter'
  syncType: 'Scheduled'
  type: 'GitHub'
  uri: 'https://github.com/Evilazaro/DevExp-DevBox.git'
  branch: 'main'
  path: '/customizations/tasks'
}

@description('Tags')
var tags = {
  workload: workloadName
  landingZone: 'DevEx'
  resourceType: 'DevCenter'
  ProductTeam: 'Platform Engineering'
  Environment: 'Production'
  Department: 'IT'
  offering: 'DevBox-as-a-Service'
}

@description('Environment Types Info')
var environmentTypesInfo = [
  {
    name: 'DEV'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Dev'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
    }
  }
  {
    name: 'PROD'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
    }
  }
  {
    name: 'STAGING'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Staging'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
    }
  }
  {
    name: 'UAT'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Uat'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
    }
  }
]

@description('Contoso Dev Center Dev Box Definitions')
var contosoDevCenterDevBoxDefinitionsInfo = [
  {
    name: 'BackEnd-Engineer'
    imageName: 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
    sku: 'general_i_32c128gb512ssd_v2'
    hibernateSupport: 'Disabled'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      roleName: 'BackEnd-Engineer'
    }
  }
  {
    name: 'FrontEnd-Engineer'
    imageName: 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
    sku: 'general_i_16c64gb256ssd_v2'
    hibernateSupport: 'Enabled'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      roleName: 'FrontEnd-Engineer'
    }
  }
  {
    name: 'Web-Designer'
    imageName: 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
    sku: 'general_i_16c64gb256ssd_v2'
    hibernateSupport: 'Enabled'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      roleName: 'Web-Designer-Engineer'
    }
  }
  {
    name: 'DevOps-Engineer'
    imageName: 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
    sku: 'general_i_32c128gb512ssd_v2'
    hibernateSupport: 'Disabled'
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      roleName: 'DevOps-Engineer'
    }
  }
]

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


@description('Environment Type Resource')
module environmentTypes 'DevCenter/EnvironmentConfiguration/environmentTypesResource.bicep' = [for environmentType in environmentTypesInfo:  {
  name: 'EnvironmentTypes-${environmentType.name}'
  scope: resourceGroup()
  params: {
    devCenterName: devCenter.outputs.devCenterName
    name: environmentType.name
    tags: tags
  }
}
]

@description('Output Environment Types created')
output environmentTypesCreated array = [for environmentType in environmentTypesInfo: {
  name: environmentType.name
  tags: environmentType.tags
}]

@description('Network Connection Attachment Resource')
module networkConnectionAttachment 'DevCenter/NetworkConnection/networkConnectionAttachmentResource.bicep' = [
  for (networkConnection, i) in networkConnections: {
    name: 'vnetCon-${networkConnection.name}'
    scope: resourceGroup()
    params: {
      devCenterName: devCenter.outputs.devCenterName
      networkConnectionResourceGroupName: connectivityResourceGroupName
      name: networkConnection.name
    }
  }
]

@description('Output Network Connection Attachments created')
output networkConnectionAttachmentsCreated array = [for (networkConnection, i) in networkConnections: {
  name: networkConnectionAttachment[i].outputs.name
  id: networkConnectionAttachment[i].outputs.networkConnectionId
}]

@description('Projects')
var contosoProjectsInfo = [
  {
    name: 'eShop'
    networkConnectionName: networkConnectionAttachment[0].name
    catalog: {
      projectName: 'eShop'
      catalogName: 'eShop'
      uri: 'https://github.com/Evilazaro/eShop.git'
      branch: 'main'
      path: '/customizations/tasks'
    }    
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      project: 'eShop'
    }
  }
  {
    name: 'Contoso-Traders'
    networkConnectionName: networkConnectionAttachment[1].name
    catalog: {
      projectName: 'Contoso-Traders'
      catalogName: 'ContosoTraders'
      uri: 'https://github.com/Evilazaro/ContosoTraders.git'
      branch: 'main'
      path: '/customizations/tasks'
    }    
    tags: {
      workload: workloadName
      landingZone: 'DevEx'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      project: 'Contoso-Traders'
    }
  }
]


@description('Contoso Dev Center Catalog')
module contosoDevCenterCatalog 'DevCenter/EnvironmentConfiguration/devCentercatalogsResource.bicep' = {
  name: 'DevCenterCatalog'
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
}

@description('Dev Center Dev Box Definitions')
module devCenterDevBoxDefinitions 'DevCenter/EnvironmentConfiguration/devBoxDefinitionResource.bicep' = [for devBoxDefinition in contosoDevCenterDevBoxDefinitionsInfo: {
  name: 'DevBoxDefinition-${devBoxDefinition.name}'
  scope: resourceGroup()
  params:{
    devCenterName: devCenter.outputs.devCenterName
    name: devBoxDefinition.name
    tags: devBoxDefinition.tags
    hibernateSupport: devBoxDefinition.hibernateSupport
    imageName: devBoxDefinition.imageName 
    skuName: devBoxDefinition.sku
  }
}]

@description('Output Dev Center Dev Box Definitions created')
output devBoxDefinitionsCreated array = [for (devBoxDefinition,i) in contosoDevCenterDevBoxDefinitionsInfo: {
  name: devCenterDevBoxDefinitions[i].outputs.devBoxDefinitionName
  tags: devCenterDevBoxDefinitions[i].outputs.devBoxDefinitionTags
  imageReferenceId: devCenterDevBoxDefinitions[i].outputs.devBoxDefinitionImageReferenceId
}]

@description('Contoso Dev Center Projects')
module contosoDevCenterProjects 'DevCenter/Management/projectModule.bicep'= {
  name: 'DevCenterProjects'
  scope: resourceGroup()
  params: {
    contosoProjectsInfo: contosoProjectsInfo
    devCenterName: devCenter.outputs.devCenterName
  }
}
