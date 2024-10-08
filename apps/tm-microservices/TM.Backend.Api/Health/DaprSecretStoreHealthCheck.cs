﻿using Dapr.Client;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Options;

namespace TM.Backend.Api.Health
{
        public class DaprSecretStoreHealthCheck : ICustomHealthCheck
        {
            private readonly DaprClient _daprClient;
            private readonly SecretStoreOptions _secretStoreOptions;

            public DaprSecretStoreHealthCheck(DaprClient daprClient, IOptions<SecretStoreOptions> secretStoreOptions)
            {
                _daprClient = daprClient;
                _secretStoreOptions = secretStoreOptions.Value;
            }

            public string Name => typeof(DaprSecretStoreHealthCheck).Name;
            protected string SecretStoreName => _secretStoreOptions.StoreName;

            public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
            {
                try
                {
                    var secret = await _daprClient.GetBulkSecretAsync(storeName: SecretStoreName, cancellationToken: cancellationToken).ConfigureAwait(false);
                    if (secret is null) return new HealthCheckResult(context.Registration.FailureStatus, Constants.DaprSecretStoreIsUnhealthy);
                }
                catch (Exception ex)
                {
                    return new HealthCheckResult(context.Registration.FailureStatus, $"Dapr secret store is unhealthy. Exception: {ex.Message}");
                }

                return HealthCheckResult.Healthy(Constants.DaprSecretStoreIsHealthy);
            }
        
    }
}
