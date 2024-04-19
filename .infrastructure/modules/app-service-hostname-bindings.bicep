import * as resources from 'resources-config.bicep'

param environment string

module appServicesHostBindings '../resources/app-service-hostname-bindings.bicep' = [
  for app in resources.parameters.appService[environment].apps: {
    name: 'app-service-host-bindings-${app.app.name}'
    params: {
      appServiceConfig: app
    }
    dependsOn: []
  }
]
