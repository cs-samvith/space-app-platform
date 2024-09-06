using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace TM.Backend.Api.Health
{
    public interface ICustomHealthCheck : IHealthCheck
    {
        public string Name { get; }

       // public  Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default);
    }
}