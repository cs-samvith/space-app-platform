param principalId string
param keyVaultConfig object

var KEYVAULT_SECRETS_USER_ROLE_ID = '4633458b-17de-408a-b874-0445c86b69e6'

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultConfig.name
}
// Create secret user role  assignment
resource userIdentityRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(keyVault.id, KEYVAULT_SECRETS_USER_ROLE_ID, principalId)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', KEYVAULT_SECRETS_USER_ROLE_ID)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}


var KEYVAULT_ADMINISTRATOR_ROLE_ID = '4633458b-17de-408a-b874-0445c86b69e6'  
var _9502070_carmax_com = '8fdd4134-8053-4a67-8504-5fc854b243b0'  //az ad signed-in-user show --query id

resource userRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(keyVault.id, KEYVAULT_ADMINISTRATOR_ROLE_ID, _9502070_carmax_com)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', KEYVAULT_ADMINISTRATOR_ROLE_ID)
    principalId: _9502070_carmax_com
    principalType: 'User'

  }
}
