import * as resources from 'resources-config.bicep'

param environment string

module keyVault '../resources/key-vault.bicep' = {
  name: 'keyvault'
  params: {
    keyVaultConfig: resources.parameters.keyVault[environment].keyVault
    envConfig: resources.parameters.env[environment]
  }
  dependsOn: []
}

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: resources.parameters.managedIdentity[environment].name
  scope: resourceGroup(resources.parameters.env[environment].resourceGroup)
}

// module keyVaultAccessPolicyObjects '../resources/key-vault-access-policy.bicep' = [
//   for obj in resources.parameters.keyVault[environment].keyVault.accesspolicies: {
//     name: 'keyvault-access-policy-${obj.objectname}'
//     params: {
//       keyVaultConfig: resources.parameters.keyVault[environment].keyVault
//       objectId: obj.objectid
//       secretsPermissions: obj.secretspermissions
//       keysPermissions: obj.keyspermissions
//       certificatesPermissions: obj.certificatespermissions
//     }
//     dependsOn: [keyVault]
//   }
// ]

// module keyVaultAccessPolicyUserAssignedIdentity '../resources/key-vault-access-policy.bicep' = {
//   name: 'keyvault-access-policy-${resources.parameters.managedIdentity[environment].name}'
//   params: {
//     keyVaultConfig: resources.parameters.keyVault[environment].keyVault
//     objectId: reference(
//       resourceId(
//         resources.parameters.env[environment].resourceGroup,
//         'Microsoft.ManagedIdentity/userAssignedIdentities',
//         resources.parameters.managedIdentity[environment].name
//       ),
//       '2023-01-31',
//       'Full'
//     ).properties.principalId
//     secretsPermissions: resources.parameters.managedIdentity[environment].keyvaultaccesspermissions.secretspermissions
//     keysPermissions: resources.parameters.managedIdentity[environment].keyvaultaccesspermissions.keyspermissions
//     certificatesPermissions: resources.parameters.managedIdentity[environment].keyvaultaccesspermissions.certificatespermissions
//   }
//   dependsOn: [keyVault]
// }

module keyVaultRBAC '../resources/key-vault-role-assignment.bicep' = {
  name: 'keyvault-rbac'
  params: {
    keyVaultConfig: resources.parameters.keyVault[environment].keyVault
    principalId: identity.properties.principalId
  }
  dependsOn: [keyVault]
}

module keyVaultSecrets '../resources/key-vault-secrets.bicep' = {
  name: 'keyvault-secrets'
  params: {
    keyVaultConfig: resources.parameters.keyVault[environment].keyVault
    storageAccountConfig: resources.parameters.storageAccount[environment]
    serviceBusConfig: resources.parameters.serviceBus[environment]
  }
  dependsOn: [keyVaultRBAC]
}
