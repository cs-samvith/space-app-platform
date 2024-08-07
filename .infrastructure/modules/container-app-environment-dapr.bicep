import * as resources from 'resources-config.bicep'

param environment string

module containerAppDaprEnvs '../resources/container-app-environment-dapr.bicep' = {
  name: 'container-app-envs-dapr'
  params: {
    cotnainerAppsEnvConfig: resources.parameters.containerAppsEnvDapr[environment].envs
    managedIdentityConfig: resources.parameters.managedIdentity[environment]
    keyVaultConfig: resources.parameters.keyVault[environment].keyVault
  }
  dependsOn: []
}
