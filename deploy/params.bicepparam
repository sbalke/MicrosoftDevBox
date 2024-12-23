using 'deploy.bicep'

@description('Workload Name')
param workloadName  = 'Contoso'

@description('Param for Resource Group Name for Connectivity Resources')
param rgConnectivityName = '${workloadName}-DevExp-Connectivity-RG'

@description('Connectivity Info')
param contosoConnectivityInfo = [
  {
    name: 'eShop'
    networkConnection: {
      domainJoinType: 'AzureADJoin'
    }
  }
  {
    name: 'Contoso-Traders'
    networkConnection: {
      domainJoinType: 'AzureADJoin'
    }
  }
]

@description('Address Prefixes')
param addressPrefixes = [
  '10.0.0.0/16'
]

@description('Contoso Dev Center Catalog')
param contosoDevCenterCatalogInfo = {
  name: 'Contoso-Custom-Tasks'
  syncType: 'Scheduled'
  type: 'GitHub'
  uri: 'https://github.com/Evilazaro/DevExp-DevBox.git'
  branch: 'main'
  path: '/.configuration/devcenter/customizations/tasks'
}

@description('Environment Types Info')
param environmentTypesInfo = [
  {
    name: 'DEV'
    tags: {
      workload: '${workloadName}-DevExp'
      landingZone: 'DevExp'
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
      workload: '${workloadName}-DevExp'
      landingZone: 'DevExp'
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
      workload: '${workloadName}-DevExp'
      landingZone: 'DevExp'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Staging'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
    }
  }
]

@description('Contoso Dev Center Dev Box Definitions')
param contosoDevCenterDevBoxDefinitionsInfo = [
  {
    name: 'Contoso-BackEnd-Engineer'
    imageName: 'microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win11-m365-gen2'
    sku: 'general_i_32c128gb512ssd_v2'
    hibernateSupport: 'Disabled'
    tags: {
      workload: '${workloadName}-DevExp'
      landingZone: 'DevExp'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      roleName: 'BackEnd-Engineer'
    }
  }
  {
    name: 'Contoso-FrontEnd-Engineer'
    imageName: 'microsoftwindowsdesktop_windows-ent-cpc_win11-21h2-ent-cpc-m365'
    sku: 'general_i_16c64gb256ssd_v2'
    hibernateSupport: 'Enabled'
    tags: {
      workload: '${workloadName}-DevExp'
      landingZone: 'DevExp'
      resourceType: 'DevCenter'
      ProductTeam: 'Platform Engineering'
      Environment: 'Production'
      Department: 'IT'
      offering: 'DevBox-as-a-Service'
      roleName: 'FrontEnd-Engineer'
    }
  }
]

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
