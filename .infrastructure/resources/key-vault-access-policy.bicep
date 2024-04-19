param keyVaultConfig object
param objectId string
param secretsPermissions array
param keysPermissions array
param certificatesPermissions array

resource keyVaultAccessPolicies 'Microsoft.KeyVault/vaults/accessPolicies@2022-07-01' = {
  name: '${keyVaultConfig.name}/add'
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: objectId
        permissions: {
          secrets: secretsPermissions
          keys: keysPermissions
          certificates: certificatesPermissions
        }
      }
    ]
  }
}
