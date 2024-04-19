// import * as resources from 'resources-config.bicep'

// param environment string

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
//     dependsOn: []
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
//   dependsOn: [keyVaultAccessPolicyObjects]
// }
