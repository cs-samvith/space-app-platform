param envConfig object
param serviceBusConfig object

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: serviceBusConfig.name
  location: envConfig.centralLocation
  sku: {
    name: serviceBusConfig.sku
    tier: serviceBusConfig.sku
  }
  properties: {
    premiumMessagingPartitions: 0
    minimumTlsVersion: '1.0'
    publicNetworkAccess: 'Enabled'
    disableLocalAuth: false
    privateEndpointConnections: []
    zoneRedundant: false
  }
}

resource serviceBusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  name: 'tasksavedtopic'
  parent: serviceBus
  properties: {
    // autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
    // defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    // duplicateDetectionHistoryTimeWindow: 'PT10M'
    // enableBatchedOperations: true
    // enableExpress: false
    // enablePartitioning: false
    // maxMessageSizeInKilobytes: 1024
    // maxSizeInMegabytes: 1024
    // requiresDuplicateDetection: false
    // status: 'Active'
    // supportOrdering: false
  }
}

resource serviceBusTopicSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  name: 'sbts-tasks-processor'
  parent: serviceBusTopic
  properties: {
    isClientAffine: false
    lockDuration: 'PT1M'
    requiresSession: false
    defaultMessageTimeToLive: 'P10675199DT2H48M5.4775807S'
    deadLetteringOnMessageExpiration: false
    deadLetteringOnFilterEvaluationExceptions: true
    maxDeliveryCount: 10
    status: 'Active'
    enableBatchedOperations: true
    autoDeleteOnIdle: 'P10675199DT2H48M5.4775807S'
  }
}
