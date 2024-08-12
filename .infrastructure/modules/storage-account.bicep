import * as resources from 'resources-config.bicep'

param environment string

module storageAccount '../resources/storage-account.bicep' = {
  name: 'storage-account'
  params: {
    storageAccountConfig: resources.parameters.storageAccount[environment]
    envConfig: resources.parameters.env[environment]
  }
  dependsOn: []
}
