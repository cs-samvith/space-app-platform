param cotnainerAppsEnvConfig array
param managedIdentityConfig object
// param keyVaultConfig object
// param serviceBusConfig object
// param storageAccountConfig object

resource containerAppEnvironments 'Microsoft.App/managedEnvironments@2023-11-02-preview' existing = [
  for app in cotnainerAppsEnvConfig: {
    name: app.name
  }
]

resource identity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityConfig.name
}

//Cosmos DB State Store Component
resource statestoreComponent 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = [
  for (app, index) in cotnainerAppsEnvConfig: {
    name: app.Dapr.stateStore.cosmos.name
    parent: containerAppEnvironments[index]
    properties: {
      componentType: 'state.azure.cosmosdb'
      version: 'v1'
      secretStoreComponent: app.Dapr.stateStore.cosmos.secretStoreComponent
      // secrets: [
      //   {
      //     name: 'cosmosmasterkey'
      //     value: 'cosmos-masterkey'
      //     keyVaultUrl: 'https://space-micro-dev-vault.vault.azure.net/secrets/cosmos-masterkey'
      //     identity: '/subscriptions/104f27c7-ec45-4c45-bb93-a29dbd5e44ba/resourcegroups/space-dev-micro/providers/Microsoft.ManagedIdentity/userAssignedIdentities/space-micro-dev-msi'
      //   }
      // ]
      metadata: [
        {
          name: 'url'
          value: app.Dapr.stateStore.cosmos.url
        }
        {
          name: 'database'
          value: app.Dapr.stateStore.cosmos.database
        }
        {
          name: 'collection'
          value: app.Dapr.stateStore.cosmos.collection
        }
        {
          name: 'azureClientId'
          value: identity.properties.clientId
        }
        {
          name: 'masterkey'
          secretRef: app.Dapr.stateStore.cosmos.secretRef
        }
      ]
      scopes: app.Dapr.stateStore.cosmos.scopes
    }
  }
]

//ServiceBus Pub/Sub Component
resource pubsubComponent 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = [
  for (app, index) in cotnainerAppsEnvConfig: {
    name: app.Dapr.pubSub.serviceBus.name
    parent: containerAppEnvironments[index]
    properties: {
      componentType: 'pubsub.azure.servicebus.topics'
      version: 'v1'
      metadata: [
        {
          name: 'namespaceName'
          value: '${app.Dapr.pubSub.serviceBus.serviceBusName}.servicebus.windows.net'
        }
        {
          name: 'consumerID'
          value: app.Dapr.pubSub.serviceBus.consumerId
        }
        {
          name: 'azureClientId'
          value: identity.properties.clientId
        }
      ]
      scopes: app.Dapr.pubSub.serviceBus.scopes
    }
  }
]

//KeyVault Secret Store Component
resource secretstoreComponent 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = [
  for (app, index) in cotnainerAppsEnvConfig: {
    name: app.Dapr.secretStore.keyvault.name
    parent: containerAppEnvironments[index]
    properties: {
      componentType: 'secretstores.azure.keyvault'
      version: 'v1'
      metadata: [
        {
          name: 'vaultName'
          value: app.Dapr.secretStore.keyvault.keyvaultName
        }
        {
          name: 'azureClientId'
          value: identity.properties.clientId
        }
      ]
      scopes: app.Dapr.secretStore.keyvault.scopes
    }
  }
]

//Storage Queue Component
resource storageQueueComponent 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = [
  for (app, index) in cotnainerAppsEnvConfig: {
    name: app.Dapr.stateStore.storageAccount.queue.name
    parent: containerAppEnvironments[index]
    properties: {
      componentType: 'bindings.azure.storagequeues'
      version: 'v1'
      secretStoreComponent: app.Dapr.stateStore.storageAccount.queue.secretStoreComponent
      metadata: [
        {
          name: 'storageAccount'
          value: app.Dapr.stateStore.storageAccount.queue.storageAccountName
        }
        {
          name: 'storageAccessKey'
          secretRef: app.Dapr.stateStore.storageAccount.queue.secretRef
        }
        {
          name: 'queue'
          value: app.Dapr.stateStore.storageAccount.queue.storageAccountQueue
        }
        {
          name: 'decodeBase64'
          value: 'true'
        }
        {
          name: 'route'
          value: app.Dapr.stateStore.storageAccount.queue.route
        }
        {
          name: 'azureClientId'
          value: identity.properties.clientId
        }
      ]
      scopes: app.Dapr.stateStore.storageAccount.queue.scopes
    }
  }
]

//Storage Blob Component
resource storageBlobComponent 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = [
  for (app, index) in cotnainerAppsEnvConfig: {
    name: app.Dapr.stateStore.storageAccount.blob.name
    parent: containerAppEnvironments[index]
    properties: {
      componentType: 'bindings.azure.blobstorage'
      version: 'v1'
      secretStoreComponent: 'secretstoreakv'
      metadata: [
        {
          name: 'accountName'
          value: app.Dapr.stateStore.storageAccount.blob.storageAccountName
        }
        {
          name: 'accountKey'
          secretRef: app.Dapr.stateStore.storageAccount.blob.secretRef
        }
        {
          name: 'containerName'
          value: app.Dapr.stateStore.storageAccount.blob.container
        }
        {
          name: 'decodeBase64'
          value: 'false'
        }
        {
          name: 'azureClientId'
          value: identity.properties.clientId
        }
      ]
      scopes: app.Dapr.stateStore.storageAccount.blob.scopes
    }
  }
]

// {
//   name: 'storageAccount'
//   value: keyVaultConfig.name
// }
// {
//   name: 'storageAccessKey'
//   secretRef: 'external-azure-storage-key'
// }
// {
//   name: 'container'
//   value: 'externaltaskscontainer'
// }

//Cron Job Component
resource cronJobComponent 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = [
  for (app, index) in cotnainerAppsEnvConfig: {
    name: 'scheduledtasksmanager'
    parent: containerAppEnvironments[index]
    properties: {
      componentType: 'bindings.cron'
      version: 'v1'
      metadata: [
        {
          name: 'schedule'
          value: '0 15 * * * *'
        }
      ]
      scopes: ['tm-backend-processor']
    }
  }
]
