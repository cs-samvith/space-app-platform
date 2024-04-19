param keyVaultConfig object
param envConfig object

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: keyVaultConfig.name
  location: envConfig.centralLocation
  properties: {
    sku: {
      family: 'A'
      name: keyVaultConfig.sku
    }
    tenantId: subscription().tenantId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    accessPolicies: []
  }
}
