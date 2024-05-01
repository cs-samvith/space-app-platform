param vnetConfig object
param envConfig object

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetConfig.name
  location: vnetConfig.region
  properties: {
    addressSpace: {
      addressPrefixes: [vnetConfig.addressPrefix]
    }
    subnets: []
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' = [
  for subnet in vnetConfig.subnets: {
    parent: virtualNetwork
    name: subnet.name
    properties: {
      addressPrefix: subnet.addressPrefix
      delegations: [
        {
          name: 'Microsoft.App.environments'
          properties: {
            serviceName: 'Microsoft.App/environments'
          }
          type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
        }
      ]
    }
  }
]

// resource virtualNetworkSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
//   name: '${vnetConfig.name}/infra-subnet'
//   properties: {
//     addressPrefix: '11.0.0.0/23'
//     serviceEndpoints: []
//     delegations: [
//       {
//         name: 'Microsoft.App.environments'
//         id: '${virtualNetworks_vnet_spacedevplatform_9974_name_infra_subnet.id}/delegations/Microsoft.App.environments'
//         properties: {
//           serviceName: 'Microsoft.App/environments'
//         }
//         type: 'Microsoft.Network/virtualNetworks/subnets/delegations'
//       }
//     ]
//     privateEndpointNetworkPolicies: 'Disabled'
//     privateLinkServiceNetworkPolicies: 'Enabled'
//   }
//   dependsOn: [
//     virtualNetwork
//   ]
// }
