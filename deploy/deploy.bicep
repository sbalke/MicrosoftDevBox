@description('Workload Name')
param workloadName string

@description('Param for Resource Group Name for Connectivity Resources')
param rgConnectivityName string

@description('Connectivity Info')
param contosoConnectivityInfo array

@description('Address Prefixes')
param addressPrefixes array

@description('Contoso Dev Center Catalog')
param contosoDevCenterCatalogInfo object

@description('Environment Types Info')
param environmentTypesInfo array

@description('Contoso Dev Center Dev Box Definitions')
param contosoDevCenterDevBoxDefinitionsInfo array

@description('Workload Role Definitions')
param workloadRoleDefinitions array


@description('Deploy Identity Resources')
module identityResources '../src/bicep/identity/identityModule.bicep' = {
  name: 'identity'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
    workloadRoleDefinitions: workloadRoleDefinitions
  }
}

@description('Deploy Connectivity Resources')
module connectivityResources '../src/bicep/connectivity/connectivityWorkload.bicep' = {
  name: 'connectivity'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
    connectivityResourceGroupName: rgConnectivityName
    contosoConnectivityInfo: contosoConnectivityInfo
    addressPrefixes: addressPrefixes
  }
}

@description('Projects')
var contosoProjectsInfo = [
  {
    name: 'eShop'
    networkConnectionName: connectivityResources.outputs.networkConnectionsCreated[0].name
    catalogs: [
      {
        catalogName: 'imageDefinitions'
        uri: 'https://github.com/Evilazaro/eShop.git'
        branch: 'main'
        path: '/devEx/customizations'
      }
      {
        catalogName: 'environments'
        uri: 'https://github.com/Evilazaro/eShop.git'
        branch: 'main'
        path: '/devEx/environments'
      }
    ]
    tags: {
      workload: '${workloadName}-DevExp'
      landingZone: 'DevExp'
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
    networkConnectionName: connectivityResources.outputs.networkConnectionsCreated[1].name
    catalogs: [
      {
        catalogName: 'imageDefinitions'
        uri: 'https://github.com/Evilazaro/contosotraders.git'
        branch: 'main'
        path: '/devEx/customizations'
      }
      {
        catalogName: 'environments'
        uri: 'https://github.com/Evilazaro/contosotraders.git'
        branch: 'main'
        path: '/devEx/environments'
      }
    ]
    tags: {
      workload: '${workloadName}-DevExp'
      landingZone: 'DevExp'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      project: 'Contoso-Traders'
    }
  }
]


@description('Deploy DevEx Resources')
module devExResources '../src/bicep/DevEx/devExWorkload.bicep' = {
  name: 'devBox'
  scope: resourceGroup()
  params: {
    workloadName: workloadName
    networkConnectionsCreated: connectivityResources.outputs.networkConnectionsCreated
    workloadroleDefinitions: identityResources.outputs.roleDefinitions
    contosoDevCenterCatalogInfo: contosoDevCenterCatalogInfo
    environmentTypesInfo: environmentTypesInfo
    contosoDevCenterDevBoxDefinitionsInfo: contosoDevCenterDevBoxDefinitionsInfo
    contosoProjectsInfo: contosoProjectsInfo
  }
}
