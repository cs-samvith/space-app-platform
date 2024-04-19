param appServiceConfig object
param envConfig object
param appInsightsConfig object
param keyVaultConfig object
param managedIdentityConfig object

var appSettings = {
  APPINSIGHTS_INSTRUMENTATIONKEY: appInsightsResource.properties.InstrumentationKey
  ASPNETCORE_ENVIRONMENT: envConfig.name
  KeyVault__Uri: 'https://${keyVaultConfig.name}${environment().suffixes.keyvaultDns}'
  KeyVault__Identity: reference(
    resourceId(envConfig.resourceGroup, 'Microsoft.ManagedIdentity/userAssignedIdentities', managedIdentityConfig.name),
    '2023-01-31',
    'Full'
  ).properties.clientId
  WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'True'
  WEBSITE_LOAD_CERTIFICATES: '*'
  WEBSITE_RUN_FROM_PACKAGE: '1'
}

var appServiceProperties = {
  serverFarmId: servicePlan.id
  enabled: true
  reserved: false
  isXenon: false
  hyperV: false
  scmSiteAlsoStopped: false
  clientAffinityEnabled: false
  clientCertEnabled: false
  hostNamesDisabled: false
  containerSize: 0
  dailyMemoryTimeQuota: 0
  httpsOnly: true
  redundancyMode: 'None'
  vnetRouteAllEnabled: false
  vnetImagePullEnabled: false
  vnetContentShareEnabled: false
  clientCertMode: 'Optional'
  clientCertExclusionPaths: '/swagger;/health'

  siteConfig: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v5.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: null
    azureStorageAccounts: {}
    scmType: 'VSTSRM'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: true
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: true
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    healthCheckPath: '/health'
    autoHealEnabled: true
    autoHealRules: {
      triggers: {
        privateBytesInKB: 0
        statusCodes: []
        slowRequests: {
          timeTaken: '00:00:20'
          count: 30
          timeInterval: '00:05:00'
        }
      }
      actions: {
        actionType: 'Recycle'
        minProcessExecutionTime: '00:02:00'
      }
    }
    localMySqlEnabled: false
    // DO NOT UNCOMMENT THE BELOW OR USE ipSecurityRestrictions and scmIpSecurityRestrictions as it wipes out siteshield restricions config
    // ipSecurityRestrictions: [
    //   {
    //     ipAddress: 'Any'
    //     action: 'Allow'
    //     priority: 1
    //     name: 'Allow all'
    //     description: 'Allow all access'
    //   }
    // ]
    // scmIpSecurityRestrictions: [
    //   {
    //     ipAddress: 'Any'
    //     action: 'Allow'
    //     priority: 1
    //     name: 'Allow all'
    //     description: 'Allow all access'
    //   }
    // ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: true
    minTlsVersion: '1.2'
    ftpsState: 'AllAllowed'
    minimumElasticInstanceCount: 1
    cors: {
      allowedOrigins: [
        (envConfig.name == 'prod' ? 'https://www.carmax.com' : 'https://wwwqa.carmax.com')
        (envConfig.name == 'prod' ? 'https://picsy.carmax.com' : 'https://picsy-qa.carmax.com')
      ]
      supportCredentials: false
    }
  }
}

resource servicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  sku: appServiceConfig.plan.sku
  kind: 'app'
  name: appServiceConfig.plan.name
  dependsOn: []
  location: appServiceConfig.region
  properties: {
    reserved: false
  }
}

resource appInsightsResource 'Microsoft.Insights/components@2020-02-02' existing = {
  name: appInsightsConfig.name
  scope: resourceGroup(envConfig.resourceGroup)
}

resource userManagedIdentityResource 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityConfig.name
  scope: resourceGroup(envConfig.resourceGroup)
}

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  kind: 'app'
  name: appServiceConfig.app.name
  location: appServiceConfig.region
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userManagedIdentityResource.id}': {}
    }
  }
  properties: appServiceProperties
  resource configAppSettings 'config@2022-09-01' = {
    name: 'appsettings'
    properties: appSettings
  }
}

resource stagingSlot 'Microsoft.Web/sites/slots@2022-09-01' = {
  location: appServiceConfig.region
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userManagedIdentityResource.id}': {}
    }
  }
  properties: appServiceProperties
  resource configAppSettings 'config@2022-09-01' = {
    name: 'appsettings'
    properties: appSettings
  }
  name: appServiceConfig.app.slot
  parent: appService
}

resource autoScaleCapacity 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: appServiceConfig.autoscale.name
  location: appServiceConfig.region
  properties: {
    profiles: [
      {
        name: 'Auto created scale condition'
        capacity: {
          minimum: appServiceConfig.autoscale.capacity.minimum
          maximum: appServiceConfig.autoscale.capacity.maximum
          default: appServiceConfig.autoscale.capacity.default
        }
        rules: [
          {
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: resourceId('microsoft.web/serverfarms', appServiceConfig.plan.name)
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: appServiceConfig.autoscale.threshold.cpu_scale_out
              dimensions: []
              dividePerInstance: false
            }
          }
          {
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: resourceId('microsoft.web/serverfarms', appServiceConfig.plan.name)
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: appServiceConfig.autoscale.threshold.cpu_scale_in
              dimensions: []
              dividePerInstance: false
            }
          }
          {
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
            metricTrigger: {
              metricName: 'MemoryPercentage'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: resourceId('microsoft.web/serverfarms', appServiceConfig.plan.name)
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: appServiceConfig.autoscale.threshold.memory_scale_out
              dimensions: []
              dividePerInstance: false
            }
          }
          {
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
            metricTrigger: {
              metricName: 'MemoryPercentage'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: resourceId('microsoft.web/serverfarms', appServiceConfig.plan.name)
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: appServiceConfig.autoscale.threshold.memory_scale_in
              dimensions: []
              dividePerInstance: false
            }
          }
          {
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
            metricTrigger: {
              metricName: 'HttpQueueLength'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: resourceId('microsoft.web/serverfarms', appServiceConfig.plan.name)
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: appServiceConfig.autoscale.threshold.http_queue_length_scale_out
              dimensions: []
              dividePerInstance: false
            }
          }
          {
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
            metricTrigger: {
              metricName: 'HttpQueueLength'
              metricNamespace: 'microsoft.web/serverfarms'
              metricResourceUri: resourceId('microsoft.web/serverfarms', appServiceConfig.plan.name)
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT10M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: appServiceConfig.autoscale.threshold.http_queue_length_scale_in
              dimensions: []
              dividePerInstance: false
            }
          }
        ]
      }
    ]
    enabled: appServiceConfig.autoscale.enabled
    name: appServiceConfig.autoscale.name
    targetResourceUri: servicePlan.id
    notifications: [
      {
        operation: 'Scale'
        email: {
          sendToSubscriptionAdministrator: false
          sendToSubscriptionCoAdministrators: false
          customEmails: []
        }
        webhooks: []
      }
    ]
    predictiveAutoscalePolicy: {
      scaleMode: 'Disabled'
    }
  }
}
