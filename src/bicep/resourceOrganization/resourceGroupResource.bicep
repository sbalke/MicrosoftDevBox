targetScope = 'subscription'

@description('Resource Group Name')
param name string = 'myResourceGroup-EYGTP'

@description('Location')
param location string = 'westus3'

@description('tags')
param tags object = {
  environment: 'dev'
}

@description('Resource Group Resource')
resource rg 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: name
  location: location
  tags: tags
}
