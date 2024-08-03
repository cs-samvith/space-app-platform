import * as resources from 'resources-config.bicep'

param environment string

module containerAppEnvs '../resources/container-registry-role-assignment.bicep' = {
  name: 'container-apps'
  params: {
    containerRegistryConfig: resources.parameters.containerRegistry[environment]
    managedIdentityConfig: resources.parameters.managedIdentity[environment]
  }
  dependsOn: []
}
