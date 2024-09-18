using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace csharp.api.Health
{
    public class CustomHealthCheck : IHealthCheck
    {
        public Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
        {
            var isHealthy = true;

            var data = new Dictionary<string, object>()
            {
                { "ConatinerName", System.Environment.MachineName},
            };

            if (isHealthy)
            {
                return Task.FromResult(
                    HealthCheckResult.Healthy("A healthy result.", data));
            }

            return Task.FromResult(
                new HealthCheckResult(
                    context.Registration.FailureStatus, "An unhealthy result.", null, data));
        }
    }
}
