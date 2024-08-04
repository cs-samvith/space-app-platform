param cotnainerAppsConfig array
param workspaceConfig object
param envConfig object
param appInsightsConfig object
param subnetName string

resource appInsightsResource 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsConfig.name
  scope: resourceGroup(envConfig.resourceGroup)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = if (subnetName != '') {
  name: subnetName
  scope: resourceGroup(envConfig.resourceGroup)
}

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
      daprAIInstrumentationKey: appInsightsResource.properties.InstrumentationKey
      customDomainConfiguration: {}
      vnetConfiguration: subnet != null
        ? {
            infrastructureSubnetId: subnet.id
          }
        : {}
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
