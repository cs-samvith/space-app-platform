param appServiceConfig object
param envConfig object
// param appInsightsConfig object
// param keyVaultConfig object
// param managedIdentityConfig object

var appSettings = {
  // APPLICATIONINSIGHTS_CONNECTION_STRING: appInsightsResource.properties.ConnectionString
  // AZURE_CLIENT_ID: userManagedIdentityResource.properties.clientId
  CUSTOM_BUILD_COMMAND: (envConfig.name == 'prod') ? 'npm run build' : 'npm run build:qa'
  // KeyVault__Uri: 'https://${keyVaultConfig.name}${az.environment().suffixes.keyvaultDns}'
  PRE_BUILD_COMMAND: 'npm ci --production  --ignore-scripts'
  SCM_DO_BUILD_DURING_DEPLOYMENT: false
  WEBSITE_ENABLE_SYNC_UPDATE_SITE: 'True'
  WEBSITE_LOAD_CERTIFICATES: '*'
  WEBSITES_CONTAINER_START_TIME_LIMIT: 1000
}

var environment = (envConfig.name == 'prod') ? 'production' : 'development'

var appServiceProperties = {
  serverFarmId: servicePlan.id
  enabled: true
  reserved: true
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
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'NODE|20-lts'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    scmType: 'None'
    use32BitWorkerProcess: true
    webSocketsEnabled: false
    alwaysOn: true
    appCommandLine: 'pm2 start app.config.js --no-daemon --env ${environment}'
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
        slowRequestsWithPath: []
        statusCodesRange: []
      }
      actions: {
        actionType: 'Recycle'
        minProcessExecutionTime: '00:02:00'
      }
    }
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    localMySqlEnabled: false
    xManagedServiceIdentityId: 9896
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
    scmMinTlsVersion: '1.2'
    ftpsState: 'AllAllowed'
    preWarmedInstanceCount: 0
    elasticWebAppScaleLimit: 0
    // healthCheckPath: '/sell-my-car/api/health'
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 0
    azureStorageAccounts: {}
  }
}

resource servicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  sku: appServiceConfig.plan.sku
  kind: 'app,linux'
  name: appServiceConfig.plan.name
  dependsOn: []
  location: appServiceConfig.region
  properties: {
    reserved: true
  }
}

// resource appInsightsResource 'Microsoft.Insights/components@2020-02-02' existing = {
//   name: appInsightsConfig.name
//   scope: resourceGroup(envConfig.resourceGroup)
// }

// resource userManagedIdentityResource 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
//   name: managedIdentityConfig.name
//   scope: resourceGroup(envConfig.resourceGroup)
// }

resource appService 'Microsoft.Web/sites@2022-09-01' = {
  kind: 'app,linux'
  name: appServiceConfig.app.name
  location: appServiceConfig.region
  // identity: {
  //   type: 'UserAssigned'
  //   // userAssignedIdentities: {
  //   //   '${userManagedIdentityResource.id}': {}
  //   // }
  // }
  properties: appServiceProperties
  resource configAppSettings 'config@2022-09-01' = {
    name: 'appsettings'
    properties: appSettings
  }
}

resource stagingSlot 'Microsoft.Web/sites/slots@2022-09-01' = {
  location: appServiceConfig.region
  // identity: {
  //   type: 'UserAssigned'
  //   // userAssignedIdentities: {
  //   //   '${userManagedIdentityResource.id}': {}
  //   // }
  // }
  properties: appServiceProperties
  resource configAppSettings 'config@2022-09-01' = {
    name: 'appsettings'
    properties: appSettings
  }
  name: appServiceConfig.app.slot
  parent: appService
}

