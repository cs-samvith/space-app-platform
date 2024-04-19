param managedIdentityConfig object
param envConfig object

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityConfig.name
  location: envConfig.eastLocation
  tags: {}
}
