param cotnainerAppsConfig array
param workspaceConfig object
param envConfig object

resource managedEnvironments 'Microsoft.App/managedEnvironments@2023-11-02-preview' = [
  for env in cotnainerAppsConfig: {
    name: env.name
    location: env.region
    properties: {
      appLogsConfiguration: {
        destination: 'log-analytics'
        logAnalyticsConfiguration: {
          customerId: reference(
            resourceId(envConfig.resourceGroup, 'Microsoft.OperationalInsights/workspaces/', workspaceConfig.name),
            '2020-08-01'
          ).customerId
          sharedKey: listKeys(
            resourceId(envConfig.resourceGroup, 'Microsoft.OperationalInsights/workspaces/', workspaceConfig.name),
            '2020-08-01'
          ).primarySharedKey
        }
      }
      zoneRedundant: false
      kedaConfiguration: {}
      daprConfiguration: {}
      customDomainConfiguration: {}
      workloadProfiles: [
        {
          workloadProfileType: 'Consumption'
          name: 'Consumption'
        }
      ]
      peerAuthentication: {
        mtls: {
          enabled: false
        }
      }
    }
  }
]
