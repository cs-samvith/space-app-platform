param containerAppsConfig array
param envConfig object
param managedIdentityConfig object
param keyVaultConfig object

resource managedEnvironments 'Microsoft.App/managedEnvironments@2023-11-02-preview' existing = [
  for app in containerAppsConfig: {
    name: app.env
    scope: resourceGroup(envConfig.resourceGroup)
  }
]

resource userManagedIdentityResource 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: managedIdentityConfig.name
  scope: resourceGroup(envConfig.resourceGroup)
}

resource containerApps 'Microsoft.App/containerapps@2023-11-02-preview' = [
  for (app, index) in containerAppsConfig: {
    name: app.name
    location: app.location
    identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '${userManagedIdentityResource.id}': {}
      }
    }
    properties: {
      managedEnvironmentId: managedEnvironments[index].id
      workloadProfileName: 'Consumption'
      configuration: {
        secrets: [
          {
            name: 'acrsecret'
            keyVaultUrl: 'https://${keyVaultConfig.name}${az.environment().suffixes.keyvaultDns}/secrets/acrsecret'
            identity: userManagedIdentityResource.id
          }
        ]
        activeRevisionsMode: 'Multiple'
        ingress: {
          external: true
          targetPort: 5000
          exposedPort: 0
          transport: 'Auto'
          traffic: [
            {
              weight: 100
              latestRevision: true
            }
          ]
          allowInsecure: false
          stickySessions: {
            affinity: 'none'
          }
        }
        registries: [
          {
            server: 'spacedevacr.azurecr.io'
            username: 'spacedevacr'
            passwordSecretRef: 'acrsecret'
          }
        ]
        maxInactiveRevisions: 100
      }
      template: {
        revisionSuffix: app.revisionName
        containers: [
          {
            image: 'spacedevacr.azurecr.io/space-dev-platform:latest'
            name: app.name
            env: [
              {
                name: 'Test'
                value: 'Test'
              }
            ]
            resources: {
              cpu: '0.5'
              memory: '1Gi'
            }
          }
        ]
        scale: {
          minReplicas: 2
          maxReplicas: 10
        }
      }
    }
  }
]
