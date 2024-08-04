import * as resources from 'resources-config.bicep'

param environment string

module containerAppEnvs '../resources/container-app-environment.bicep' = {
  name: 'container-app-envs'
  params: {
    cotnainerAppsConfig: resources.parameters.containerAppsEnv[environment].envs
    workspaceConfig: resources.parameters.appInsights[environment].workspace
    envConfig: resources.parameters.env[environment]
    appInsightsConfig: resources.parameters.appInsights[environment].appInsight
    subnetName: resources.parameters.env[environment].name == 'dev-micro' ? 'space-micro-vnet-east/infra' : ''
  }
  dependsOn: []
}
