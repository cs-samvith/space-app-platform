@export()
var parameters = {
  env: {
    dev: loadJsonContent('../parameters/dev/env-config.json')
    devmicro: loadJsonContent('../parameters/devmicro/env-config.json')
  }
  virtualNetwork: {
    dev: loadJsonContent('../parameters/dev/virtual-network.json')
    devmicro: loadJsonContent('../parameters/devmicro/virtual-network.json')
  }
  appInsights: {
    dev: loadJsonContent('../parameters/dev/app-insights.json')
    devmicro: loadJsonContent('../parameters/devmicro/app-insights.json')
  }
  containerAppsEnv: {
    dev: loadJsonContent('../parameters/dev/container-app-environment.json')
    devmicro: loadJsonContent('../parameters/devmicro/container-app-environment.json')
  }
  containerAppsEnvDapr: {
    devmicro: loadJsonContent('../parameters/devmicro/container-app-environment-dapr.json')
  }
  containerApps: {
    dev: loadJsonContent('../parameters/dev/container-apps.json')
    devmicro: loadJsonContent('../parameters/devmicro/container-apps.json')
  }
  keyVault: {
    dev: loadJsonContent('../parameters/dev/key-vault.json')
    devmicro: loadJsonContent('../parameters/devmicro/key-vault.json')
  }
  managedIdentity: {
    dev: loadJsonContent('../parameters/dev/managed-identity.json')
    devmicro: loadJsonContent('../parameters/devmicro/managed-identity.json')
  }
  containerRegistry: {
    dev: loadJsonContent('../parameters/dev/container-registry.json')
    devmicro: loadJsonContent('../parameters/devmicro/container-registry.json')
  }
}
