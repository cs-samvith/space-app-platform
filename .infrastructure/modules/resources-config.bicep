@export()
var parameters = {
  env: {
    dev: loadJsonContent('../parameters/dev/env-config.json')
  }
  appInsights: {
    dev: loadJsonContent('../parameters/dev/app-insights.json')
  }
  managedIdentity: {
    dev: loadJsonContent('../parameters/dev/managed-identity.json')
  }
  appConfiguration: {
    dev: loadJsonContent('../parameters/dev/app-configuration.json')
  }
  keyVault: {
    dev: loadJsonContent('../parameters/dev/key-vault.json')
  }
  appService: {
    dev: loadJsonContent('../parameters/dev/app-service.json')
  }
  trafficManagerProfile: {
    dev: loadJsonContent('../parameters/dev/traffic-manager.json')
  }
}
