param trafficManagerProfileConfig object
param appServiceConfig object
param envConfig object

var endpoints = [
  for (appService, index) in appServiceConfig.apps: {
    name: appService.app.name
    type: 'Microsoft.Network/trafficManagerProfiles/azureEndpoints'
    properties: {
      endpointStatus: 'Enabled'
      endpointMonitorStatus: 'Online'
      targetResourceId: resourceId(
        subscription().subscriptionId,
        envConfig.resourcegroup,
        'Microsoft.Web/sites',
        appService.app.name
      )
      target: '${appService.app.name}.azurewebsites.net'
      weight: 1
      priority: index + 1
      endpointLocation: appService.region
    }
  }
]

resource trafficManagerProfiles 'Microsoft.Network/trafficmanagerprofiles@2022-04-01' = {
  name: trafficManagerProfileConfig.name
  location: 'global'
  properties: {
    profileStatus: 'Enabled'
    trafficRoutingMethod: 'Performance'
    dnsConfig: {
      relativeName: trafficManagerProfileConfig.name
      ttl: 300
    }
    monitorConfig: {
      profileMonitorStatus: 'Online'
      protocol: 'HTTPS'
      port: 443
      path: '/health'
      intervalInSeconds: 30
      toleratedNumberOfFailures: 5
      timeoutInSeconds: 10
    }
    endpoints: endpoints
    maxReturn: 0
  }
}
