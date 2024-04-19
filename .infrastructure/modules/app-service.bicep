import * as resources from 'resources-config.bicep'

param environment string

module appServices '../resources/app-service.bicep' = [
  for app in resources.parameters.appService[environment].apps: {
    name: 'app-service-${app.app.name}'
    scope: resourceGroup(resources.parameters.env[environment].resourceGroup)
    params: {
      // appInsightsConfig: resources.parameters.appInsights[environment].appInsight
      appServiceConfig: app
      // keyVaultConfig: resources.parameters.keyVault[environment].keyVault
      envConfig: resources.parameters.env[environment]
      // managedIdentityConfig: resources.parameters.managedIdentity[environment]
    }
    dependsOn: []
  }
]
