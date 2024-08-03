@export()
var parameters = {
  env: {
    dev: loadJsonContent('../parameters/dev/env-config.json')
  }
  virtualNetwork: {
    dev: loadJsonContent('../parameters/dev/virtual-network.json')
  }
  appInsights: {
    dev: loadJsonContent('../parameters/dev/app-insights.json')
  }
  containerAppsEnv: {
    dev: loadJsonContent('../parameters/dev/container-app-environment.json')
  }
  containerApps: {
    dev: loadJsonContent('../parameters/dev/container-apps.json')
  }
  keyVault: {
    dev: loadJsonContent('../parameters/dev/key-vault.json')
  }
  managedIdentity: {
    dev: loadJsonContent('../parameters/dev/managed-identity.json')
  }
  containerRegistry: {
    dev: loadJsonContent('../parameters/dev/container-registry.json')
  }
}
