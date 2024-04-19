param appServiceConfig object

resource tlsCertificates 'Microsoft.Web/certificates@2022-09-01' = [
  for domain in appServiceConfig.customdomains: if (!empty(domain.vaultcertificatename)) {
    name: '${domain.vaultcertificatename}-${appServiceConfig.region}'
    location: appServiceConfig.region
    properties: {
      keyVaultId: resourceId(domain.certificateresourcegroup, 'Microsoft.KeyVault/vaults', domain.keyvaultname)
      keyVaultSecretName: domain.vaultcertificatename
      serverFarmId: resourceId('Microsoft.Web/serverfarms', appServiceConfig.plan.name)
    }
  }
]

resource hostNameBindingsTls 'Microsoft.Web/sites/hostNameBindings@2022-09-01' = [
  for (domain, index) in appServiceConfig.customdomains: {
    name: '${appServiceConfig.app.name}/${domain.domain}.carmax.com'
    properties: {
      sslState: (!empty(domain.vaultcertificatename)) ? 'SniEnabled' : 'Disabled'
      thumbprint: (!empty(domain.vaultcertificatename)) ? tlsCertificates[index].properties.thumbprint : ''
    }
  }
]
