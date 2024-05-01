import * as resources from 'resources-config.bicep'

param environment string

module containerAppEnvs '../resources/cotnainer-apps.bicep' = {
  name: 'cotnainer-apps'
  params: {
    cotnainerAppsConfig: resources.parameters.containerApps[environment].apps
    envConfig: resources.parameters.env[environment]
    keyVaultConfig: resources.parameters.keyVault[environment].keyVault
    managedIdentityConfig: resources.parameters.managedIdentity[environment]
  }
  dependsOn: []
}
