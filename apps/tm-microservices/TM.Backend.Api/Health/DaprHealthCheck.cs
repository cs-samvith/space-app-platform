using Dapr.Client;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.VisualBasic;

namespace TM.Backend.Api.Health
{
    public class DaprHealthCheck :ICustomHealthCheck 
    {
        private readonly DaprClient _daprClient;

        public DaprHealthCheck(DaprClient daprClient)
        {
            _daprClient = daprClient;
        }

        public string Name => typeof(DaprHealthCheck).Name;

        public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
        {
            var healthy = await _daprClient.CheckHealthAsync(cancellationToken);
            if (healthy) return HealthCheckResult.Healthy(Constants.DaprSidecarIsHealthy);

            return new HealthCheckResult(context.Registration.FailureStatus, Constants.DaprSidecarIsUnhealthy);
        }
    }
}
