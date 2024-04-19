// import * as resources from 'resources-config.bicep'

// param environment string

// module appInsights '../resources/app-insights.bicep' = {
//   name: 'app-insights'
//   params: {
//     appInsightsConfig: resources.parameters.appInsights[environment].appInsight
//     workspaceConfig: resources.parameters.appInsights[environment].workspace
//     diagnosticConfig: resources.parameters.appInsights[environment].diagnostic
//     envConfig: resources.parameters.env[environment]
//   }
//   dependsOn: []
// }
