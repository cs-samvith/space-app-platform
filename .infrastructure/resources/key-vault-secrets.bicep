param keyVaultConfig object
param storageAccountConfig object

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultConfig.name
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountConfig.name
}

resource secretStorageKey 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: 'external-azure-storage-key'
  parent: keyVault
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'string'
    value: storageAccount.listKeys().keys[0].value
  }
}
