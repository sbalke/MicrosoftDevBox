using 'deploy.bicep'

param workloadName = 'Contoso'

param rgConnectivityName = '${workloadName}-DevExp-Connectivity-RG'

param workloadConnectivityInfo = [
  {
    name: 'eShop'
    networkConnection: {
      domainJoinType: 'AzureADJoin'
    }
  }
  {
    name: 'identityProvider'
    networkConnection: {
      domainJoinType: 'AzureADJoin'
    }
  }
]

param addressPrefixes = [
  '10.0.0.0/16'
]

param workloadCatalogInfo = {
  name: 'Custom-Tasks'
  syncType: 'Scheduled'
  type: 'GitHub'
  uri: 'https://github.com/Evilazaro/DevExp-DevBox.git'
  branch: 'main'
  path: '/.configuration/devcenter/tasks'
}

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

param workloadDevBoxDefinitionsInfo = [
  {
    name: 'BackEnd-Engineer'
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
    name: 'FrontEnd-Engineer'
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

param workloadRoleDefinitions = [
  'b24988ac-6180-42a0-ab88-20f7382dd24c'
  'eb960402-bf75-4cc3-8d68-35b34f960f72'
  '18e40d4e-8d2e-438d-97e1-9528336e149c'
  '45d50f46-0b78-4001-a660-4198cbe8cd05'
  '331c37c6-af14-46d9-b9f4-e1909e1b95a0'
]
