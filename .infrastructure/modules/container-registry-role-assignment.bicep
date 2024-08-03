import * as resources from 'resources-config.bicep'

param environment string

module containerRegRoleAssignment '../resources/container-registry-role-assignment.bicep' = {
  name: 'container-reg-role-assignment'
  scope: resourceGroup(resources.parameters.containerRegistry[environment].resourceGroup)
  params: {
    containerRegistryConfig: resources.parameters.containerRegistry[environment]
    managedIdentityConfig: resources.parameters.managedIdentity[environment]
    envConfig: resources.parameters.env[environment]
  }
  dependsOn: []
}
