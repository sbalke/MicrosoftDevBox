@description('Workload name')
param workloadName string

@description('Connectivity Resource Group Name')
param connectivityResourceGroupName string

@description('Connectivity Info')
param workloadConnectivityInfo array 

@description('Address Prefixes')
param addressPrefixes array 

@description('Tags')
param tags object = {
  workload: '${workloadName}-DevExp'
  landingZone: 'connectivity'
  resourceType: 'virtualNetwork'
  ProductTeam: 'Platform Engineering'
  Environment: 'Production'
  Department: 'IT'
  offering: 'DevBox-as-a-Service'
}

@description('Virtual Network Resource')
module virtualNetwork 'virtualNetwork/virtualNetworkResource.bicep' = {
  name: 'virtualNetwork'
  scope: resourceGroup(connectivityResourceGroupName)
  params: {
    name: workloadName
    location: resourceGroup().location
    tags: tags
    addressPrefixes: addressPrefixes
    subnets: workloadConnectivityInfo
  }
}

@description('Network Connection Resource')
module networkConnection 'networkConnection/networkConnectionResource.bicep' = [
  for (netConnection, i) in workloadConnectivityInfo: {
    name: 'netCon-${netConnection.name}'
    scope: resourceGroup(connectivityResourceGroupName)
    params: {
      virtualNetworkName: virtualNetwork.outputs.virtualNetworkName
      subnetName: virtualNetwork.outputs.virtualNetworkSubnets[i].name
      virtualNetworkResourceGroupName: connectivityResourceGroupName
      domainJoinType: netConnection.networkConnection.domainJoinType
      tags: tags
    }
  }
]

@description('Network Connections')
output networkConnectionsCreated array = [
  for (netConnection, i) in workloadConnectivityInfo: {
    name: networkConnection[i].outputs.networkConnectionName
    id: networkConnection[i].outputs.networkConnectionId
  }
]
