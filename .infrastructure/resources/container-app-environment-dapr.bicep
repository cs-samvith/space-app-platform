param cotnainerAppsEnvConfig array
param managedIdentityConfig object
param keyVaultConfig object
param serviceBusConfig object

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
    name: 'statestore'
    parent: containerAppEnvironments[index]
    properties: {
      componentType: 'state.azure.cosmosdb'
      version: 'v1'
      // secretStoreComponent: 'secretstore'
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
        // {
        //   name: 'masterkey'
        //   secretRef: 'cosmos-masterkey'
        // }
      ]
      scopes: app.Dapr.stateStore.scopes
    }
  }
]

//ServiceBus Pub/Sub Component
resource pubsubComponent 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = [
  for (app, index) in cotnainerAppsEnvConfig: {
    name: 'dapr-pubsub-servicebus'
    parent: containerAppEnvironments[index]
    properties: {
      componentType: 'pubsub.azure.servicebus.topics'
      version: 'v1'
      metadata: [
        {
          name: 'namespaceName'
          value: '${serviceBusConfig.name}.servicebus.windows.net'
        }
        {
          name: 'consumerID'
          value: 'sbts-tasks-processor'
        }
        {
          name: 'azureClientId'
          value: identity.properties.clientId
        }
      ]
      scopes: ['tm-backend-api', 'tm-backend-processor']
    }
  }
]

//KeyVault Secret Store Component
resource secretstoreComponent 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = [
  for (app, index) in cotnainerAppsEnvConfig: {
    name: 'secretstoreakv'
    parent: containerAppEnvironments[index]
    properties: {
      componentType: 'secretstores.azure.keyvault'
      version: 'v1'
      metadata: [
        {
          name: 'vaultName'
          value: keyVaultConfig.name
        }
        {
          name: 'azureClientId'
          value: identity.properties.clientId
        }
      ]
      scopes: ['tm-backend-api']
    }
  }
]

//Storage Queue Component
resource storageQueueComponent 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = [
  for (app, index) in cotnainerAppsEnvConfig: {
    name: 'externaltasksmanager'
    parent: containerAppEnvironments[index]
    properties: {
      componentType: 'bindings.azure.storagequeues'
      version: 'v1'
      secretStoreComponent: 'secretstoreakv'
      metadata: [
        {
          name: 'storageAccount'
          value: keyVaultConfig.name
        }
        {
          name: 'storageAccessKey'
          secretRef: 'external-azure-storage-key'
        }
        {
          name: 'queue'
          value: 'external-tasks-queue'
        }
        {
          name: 'decodeBase64'
          value: 'true'
        }
        {
          name: 'route'
          value: '/externaltasksprocessor/process'
        }
        {
          name: 'azureClientId'
          value: identity.properties.clientId
        }
      ]
      scopes: ['tm-backend-processor']
    }
  }
]

//Storage Blob Component
resource storageBlobComponent 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = [
  for (app, index) in cotnainerAppsEnvConfig: {
    name: 'externaltasksblobstore'
    parent: containerAppEnvironments[index]
    properties: {
      componentType: 'bindings.azure.blobstorage'
      version: 'v1'
      secretStoreComponent: 'secretstoreakv'
      metadata: [
        {
          name: 'storageAccount'
          value: keyVaultConfig.name
        }
        {
          name: 'storageAccessKey'
          secretRef: 'external-azure-storage-key'
        }
        {
          name: 'container'
          value: 'externaltaskscontainer'
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
      scopes: ['tm-backend-processor']
    }
  }
]

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
