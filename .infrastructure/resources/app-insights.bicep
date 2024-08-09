param workspaceConfig object
param appInsightsConfig object
param envConfig object

resource workspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspaceConfig.name
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  kind: 'web'
  name: appInsightsConfig.name
  location: envConfig.centralLocation
  properties: {
    Request_Source: 'IbizaAIExtension' // TODO - LP - What is this ?
    Application_Type: 'web'
    RetentionInDays: 90
    WorkspaceResourceId: workspace.id
    Flow_Type: 'Redfield' // TODO - LP - What is this ?
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    DisableIpMasking: true
  }
}
