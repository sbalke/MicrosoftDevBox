param workloadName string

module sp 'appServicePlanResource.bicep' = {
  name: 'appServicePlanResource'
  params:{
    name: workloadName
    kind: 'app,linux'
    tags: {
      environment: 'dev'
      name: workloadName
    }
  }
}

module ws 'appServiceResource.bicep'= {
  name: 'appServiceResource'
  params: {
    name: workloadName
    appServicePlanId: sp.outputs.appServicePlanId 
  }
}

resource sa 'Microsoft.Storage/storageAccounts@2020-08-01-preview' = {
  name: workloadName
  location: 'eastus'
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}
