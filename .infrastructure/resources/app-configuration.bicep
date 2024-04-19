param appConfigurationConfig object
param envConfig object

resource appConfig 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: appConfigurationConfig.name
  location: envConfig.centralLocation
  sku: {
    name: 'standard'
  }
  properties: {
    encryption: {}
  }
}
