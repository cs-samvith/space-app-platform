param cotnainerAppsEnvConfig array
// param envConfig object

resource containerAppEnvironments 'Microsoft.App/managedEnvironments@2023-11-02-preview' existing = [
  for app in cotnainerAppsEnvConfig: {
    name: app.env
    // scope: resourceGroup(envConfig.resourceGroup)
  }
]

//Cosmos DB State Store Component
resource statestoreComponent 'Microsoft.App/managedEnvironments/daprComponents@2022-06-01-preview' = [
  for (app, index) in cotnainerAppsEnvConfig: {
    name: 'statestore'
    parent: containerAppEnvironments[index]
    properties: {
      componentType: 'state.azure.cosmosdb'
      version: 'v1'
      secrets: []
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
      ]
      scopes: app.Dapr.stateStore.scopes
    }
  }
]
