param workspaceConfig object
param envConfig object

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceConfig.name
  location: envConfig.centralLocation
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 90
  }
}
