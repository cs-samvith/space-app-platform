import * as resources from 'resources-config.bicep'

param environment string

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: resources.parameters.managedIdentity[environment].name
  scope: resourceGroup(resources.parameters.env[environment].resourceGroup)
}

module containerRegRoleAssignment '../resources/service-bus-role-assignment.bicep' = {
  name: 'service-bus-role-assignment'
  scope: resourceGroup(resources.parameters.containerRegistry[environment].resourceGroup)
  params: {
    serviceBusConfig: resources.parameters.containerRegistry[environment]
    //managedIdentityConfig: resources.parameters.managedIdentity[environment]
    //envConfig: resources.parameters.env[environment]
    principalId: identity.properties.principalId
  }
  dependsOn: []
}
