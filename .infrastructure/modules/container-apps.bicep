import * as resources from 'resources-config.bicep'

param environment string

module containerAppEnvs '../resources/container-apps.bicep' = {
  name: 'container-apps'
  params: {
    containerAppsConfig: resources.parameters.containerApps[environment].apps
    envConfig: resources.parameters.env[environment]
    keyVaultConfig: resources.parameters.keyVault[environment].keyVault
    managedIdentityConfig: resources.parameters.managedIdentity[environment]
  }
  dependsOn: []
}
