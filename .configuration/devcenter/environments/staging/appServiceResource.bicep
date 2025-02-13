@description('App Service Name')
param name string

@description('App Service Location')
param location string = resourceGroup().location

@description('App Service Plan Id')
param appServicePlanId string

@description('App Service Kind')
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
param kind string = 'app,linux'

@description('App Service Current Stack')
@allowed([
  'dotnetcore'
  'java'
  'node'
  'php'
])
param currentStack string = 'dotnetcore'

@description('netFrameworkVersion')
@allowed([
  '7.0'
  '8.0'
  '9.0'
  ''
])
param dotnetcoreVersion string = '9.0'

module monitoring 'logAnalyticsResource.bicep' = {
  name: 'logAnalyticsResource'
  params: {
    name: name
    tags: {
      environment: 'dev'
      name: name
    }
  }
}

@description('App Settings')
var appSettings = [
  {
    name: 'ASPNETCORE_ENVIRONMENT'
    value: 'Development'
  }
  {
    name: 'PLATFORM_ENGINEERING_ENVIRONMENT'
    value: 'Development'
  }
  {
    name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
    value: monitoring.outputs.InstrumentationKey
  }
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: monitoring.outputs.ConnectionString
  }
  {
    name: 'APPINSIGHTS_PROFILERFEATURE_VERSION'
    value: '1.0.0'
  }
  {
    name: 'APPINSIGHTS_SNAPSHOTFEATURE_VERSION'
    value: '1.0.0'
  }
  {
    name: 'APPLICATIONINSIGHTS_ENABLESQLQUERYCOLLECTION'
    value: 'enabled'
  }
  {
    name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
    value: '~3'
  }
  {
    name: 'DiagnosticServices_EXTENSION_VERSION'
    value: '~3'
  }
  {
    name: 'IdProviderTemplate'
    value: '2.0'
  }
]

@description('Tags')
param tags object = {}

@description('LinuxFxVersion')
var linuxFxVersion = (contains(kind, 'linux')) ? '${toUpper(currentStack)}|${dotnetcoreVersion}' : null

@description('App Service Resource')
resource appService 'Microsoft.Web/sites@2024-04-01' = {
  name: '${name}-app-service'
  location: location
  kind: kind
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlanId
    enabled: true
    siteConfig: {
      linuxFxVersion: linuxFxVersion
      alwaysOn: true
      minimumElasticInstanceCount: 1
      http20Enabled: true
      appSettings: appSettings
    }
  }
}
