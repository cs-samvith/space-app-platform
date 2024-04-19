import * as resources from 'resources-config.bicep'

param environment string

module workspace '../resources/workspace.bicep' = {
  name: 'workspace'
  params: {
    workspaceConfig: resources.parameters.appInsights[environment].workspace
    envConfig: resources.parameters.env[environment]
  }
  dependsOn: []
}
