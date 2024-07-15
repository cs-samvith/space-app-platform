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

// resource appInsightsDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
//   scope: appInsights
//   name: 'export-to-splunk'
//   properties: {
//     eventHubAuthorizationRuleId: resourceId(subscription().subscriptionId, diagnosticConfig.event_hub_resource_group, 'Microsoft.EventHub/namespaces/authorizationRules', diagnosticConfig.event_hub_namespace, 'RootManageSharedAccessKey')
//     eventHubName: diagnosticConfig.event_hub_name
//     logAnalyticsDestinationType: null
//     logs: [
//       {
//         categoryGroup: 'allLogs'
//         enabled: true
//       }
//     ]
//     metrics: [
//       {
//         category: 'AllMetrics'
//         enabled: true
//       }
//     ]
//   }
//   dependsOn: []
// }
