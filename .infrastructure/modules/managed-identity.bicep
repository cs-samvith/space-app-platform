import * as resources from 'resources-config.bicep'

param environment string

module managedIdentity '../resources/managed-identity.bicep' = {
  name: 'managed-identity'
  params: {
    managedIdentityConfig: resources.parameters.managedIdentity[environment]
    envConfig: resources.parameters.env[environment]
  }
  dependsOn: []
}
