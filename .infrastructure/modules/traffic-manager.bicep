import * as resources from 'resources-config.bicep'

param environment string

module trafficManager '../resources/traffic-manager.bicep' = {
  name: 'traffic-manager'
  params: {
    trafficManagerProfileConfig: resources.parameters.trafficManagerProfile[environment]
    appServiceConfig: resources.parameters.appService[environment]
    envConfig: resources.parameters.env[environment]
  }
  dependsOn: []
}
