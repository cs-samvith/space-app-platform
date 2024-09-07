param keyVaultConfig object
param storageAccountConfig object
param serviceBusConfig object

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultConfig.name
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' existing = {
  name: storageAccountConfig.name
}

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusConfig.name
}

resource serviceBusAuthRules 'Microsoft.ServiceBus/namespaces/AuthorizationRules@2022-01-01-preview' existing = {
  name: 'RootManageSharedAccessKey'
  parent: serviceBus
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

resource secretServiceBus 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: 'servicebus-connectionstring'
  parent: keyVault
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'string'
    value: serviceBusAuthRules.listKeys().primaryConnectionString
  }
}
