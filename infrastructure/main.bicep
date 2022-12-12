targetScope = 'subscription'

param systemName string
@allowed([
  'dev'
  'test'
  'acc'
  'prod'
])
param environmentName string
param locationAbbreviation string
param location string = deployment().location

var resourceGroupName = '${systemName}-${environmentName}-${locationAbbreviation}'

resource targetResourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

module resources 'resources.bicep' = {
  scope: targetResourceGroup
  name: 'ResourcesModule'
  params: {
    defaultResourceName: resourceGroupName
    location: location
  }
}

output targetResourceGroupName string = targetResourceGroup.name
output functionResourceName string = resources.outputs.functionResourceName
