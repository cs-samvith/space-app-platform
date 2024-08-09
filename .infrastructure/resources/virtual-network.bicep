param vnetConfig object

var subnets = [
  for subnet in vnetConfig.subnets: {
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

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetConfig.name
  location: vnetConfig.region
  properties: {
    addressSpace: {
      addressPrefixes: [vnetConfig.addressPrefix]
    }
    subnets: subnets
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}
