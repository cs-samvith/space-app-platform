resource managedEnvironments_space_dev_container_apps_env_name 'Microsoft.App/managedEnvironments@2023-11-02-preview' = {
  name: managedEnvironments_space_dev_container_apps_env_name_param
  location: 'East US'
  properties: {
    vnetConfiguration: {
      internal: false
      infrastructureSubnetId: '${virtualNetworks_vnet_spacedevplatform_9974_externalid}/subnets/infra-subnet'
    }
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: '64e88c0b-547c-44db-928a-75228c0a1a55'
        dynamicJsonColumns: false
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
    infrastructureResourceGroup: 'ME_${managedEnvironments_space_dev_container_apps_env_name_param}_space-dev-platform_eastus'
    peerAuthentication: {
      mtls: {
        enabled: false
      }
    }
  }
}
