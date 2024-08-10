import * as resources from 'resources-config.bicep'

param environment string

module serviceBus '../resources/service-bus.bicep' = {
  name: 'service-bus'
  params: {
    serviceBusConfig: resources.parameters.serviceBus[environment]
    envConfig: resources.parameters.env[environment]
  }
  dependsOn: []
}
