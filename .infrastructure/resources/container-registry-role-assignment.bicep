param managedIdentityConfig object
param containerRegistryConfig object
param envConfig object

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull
var roleId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
// Get a reference to the existing registry
resource registry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' existing = {
  name: containerRegistryConfig.name
  scope: resourceGroup(containerRegistryConfig.resourceGroup)
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityConfig.name
  scope: resourceGroup(envConfig.resourceGroup)
}

// Create role assignment
resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(registry.id, roleId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: identity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
