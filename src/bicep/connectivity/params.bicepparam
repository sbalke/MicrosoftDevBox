using 'connectivityWorkload.bicep'

@description('Workload name')
param workloadName  = 'Contoso'

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName = '${workloadName}-DevExp-Connectivity-RG'

@description('Connectivity Info')
param contosoConnectivityInfo = [
  {
    name: 'eShop'
    networkConnection: {
      domainJoinType: 'AzureADJoin'
    }
  }
  {
    name: '${workloadName}-Traders'
    networkConnection: {
      domainJoinType: 'AzureADJoin'
    }
  }
]

@description('Address Prefixes')
param addressPrefixes = [
  '10.0.0.0/16'
]

@description('Tags')
param tags = {
  workload: '${workloadName}-DevExp'
  landingZone: 'connectivity'
  resourceType: 'virtualNetwork'
  ProductTeam: 'Platform Engineering'
  Environment: 'Production'
  Department: 'IT'
  offering: 'DevBox-as-a-Service'
}
