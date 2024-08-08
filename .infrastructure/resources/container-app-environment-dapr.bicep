param cotnainerAppsEnvConfig array
// param envConfig object

resource containerAppEnvironments 'Microsoft.App/managedEnvironments@2023-11-02-preview' existing = [
  for app in cotnainerAppsEnvConfig: {
    name: app.name
    // scope: resourceGroup(envConfig.resourceGroup)
  }
]

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
          value: 'd5ddad76-e30d-4cdb-aa1d-94d93defe36e'
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


//keyvault secret store Component
resource secretstoreComponent 'Microsoft.App/managedEnvironments/daprComponents@2024-03-01' = {
    name: 'space-micro-env/secretstore'
    properties: {
      componentType: 'secretstores.azure.keyvault'
      version: 'v1'
     
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
          name: 'vaultName'
          value: 'space-micro-dev-vault'
        }
        {
          name: 'azureClientId'
          value: 'd5ddad76-e30d-4cdb-aa1d-94d93defe36e'
        }

      ]
      scopes: ['tm-backend-api']
    }
  }

