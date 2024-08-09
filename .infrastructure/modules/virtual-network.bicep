import * as resources from 'resources-config.bicep'

param environment string

module virtualNetworks '../resources/virtual-network.bicep' = [
  for vnet in resources.parameters.virtualNetwork[environment].vnets: {
    name: 'virtual-network-${vnet.name}'
    params: {
      vnetConfig: vnet
    }
    dependsOn: []
  }
]
