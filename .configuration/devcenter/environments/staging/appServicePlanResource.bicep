@description('App Service Plan Name')
param name string

@description('App Service Plan Location')
param location string = resourceGroup().location

@description('App Service Plan Kind')
@allowed([
  'app'
  'app,linux'
  'app,linux,container'
  'hyperV'
  'app,container,windows'
  'app,linux,kubernetes'
  'app,linux,container,kubernetes'
  'functionapp'
  'functionapp,linux'
  'functionapp,linux,container,kubernetes'
  'functionapp,linux,kubernetes'
])
param kind string

@description('App Service Plan SKU')
param sku object = {
  name: 'P1V3'
  tier: 'PremiumV3'
  capacity: 1
}

@description('Tags')
param tags object

@description('App Service Plan Resource')
resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: '${name}-${uniqueString(resourceGroup().id,name)}-svcplan'
  location: location
  sku: sku
  kind: 'linux'
  properties: {
    reserved: (contains(kind, 'linux')) ? true : false
  }
  tags: tags
}

output appServicePlanId string = appServicePlan.id
