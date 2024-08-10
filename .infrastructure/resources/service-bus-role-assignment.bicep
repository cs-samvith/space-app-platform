param principalId string
param serviceBusConfig object

// https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#acrpull
var senderRoleId = '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'
var receiverRoleId = '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'

resource serviceBus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' existing = {
  name: serviceBusConfig.name
}

// Create senderrole assignment
resource senderRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(serviceBus.id, senderRoleId, principalId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', senderRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}

// Create receiverrrole assignment
resource receiverRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(serviceBus.id, receiverRoleId, principalId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', receiverRoleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
