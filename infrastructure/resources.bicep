param defaultResourceName string
param location string

var corsOrigins = []
var corsSupportCredentials = false

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: uniqueString(defaultResourceName)
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: '${defaultResourceName}-plan'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    capacity: 1
  }
  kind: 'functionapp'
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2022-03-01' = {
  name: '${defaultResourceName}-func'
  location: location
  kind: 'functionapp,linux'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

var config = [
  {
    name: 'AzureWebJobsStorage'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  }
  {
    name: 'FUNCTIONS_EXTENSION_VERSION'
    value: '~4'
  }
  {
    name: 'FUNCTIONS_WORKER_RUNTIME'
    value: 'dotnet-isolated'
  }
]

resource appConfig 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'web'
  parent: functionApp
  properties: {
    ftpsState: 'Disabled'
    minTlsVersion: '1.2'
    http20Enabled: true
    netFrameworkVersion: 'v7.0'
    cors: {
      allowedOrigins: corsOrigins
      supportCredentials: corsSupportCredentials
    }
    appSettings: config
  }
}

output functionResourceName string = functionApp.name
output functionResourceIdentity string = functionApp.identity.principalId
