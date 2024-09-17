using HealthChecks.UI.Client;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using System.Reflection;

namespace csharp.api.Health
{
    public static class HealthChecks
    {
        public static void ConfigureHealthChecks(this IServiceCollection services, string connstring)
        {
            services.AddHealthChecks()
                .AddCheck("ApplicationInfo", () => HealthCheckResult.Healthy(data: new Dictionary<string, object>
                    {
                            {"Version", Assembly.GetExecutingAssembly().GetName().Version.ToString() }
                    }))
                    .AddMySql(connstring, healthQuery: "SELECT 1 FROM testdb.customers", name: "MySql Server", failureStatus: HealthStatus.Unhealthy, tags: new[] { "testdb", "Database","readiness" })
                    //.AddCheck<RemoteHealthCheck>("Remote endpoints Health Check", failureStatus: HealthStatus.Unhealthy, tags: new[] { "readiness" })
                    .AddCheck<MemoryHealthCheck>($"Api Memory Check", failureStatus: HealthStatus.Unhealthy, tags: new[] { "Api", "liveness"});
                    //.AddUrlGroup(new Uri("https://localhost:44333/api/v1/heartbeats/ping"), name: "base URL", failureStatus: HealthStatus.Unhealthy); 
        }

        public static void ApplyHealthChecks(this WebApplication app)
        {
            app.UseHealthChecks("/v2/readiness", new HealthCheckOptions
            {
                ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse,
                
            });

            app.UseHealthChecks("/v2/liveness", new HealthCheckOptions
            {
                ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse,
                Predicate = (h) => h.Tags.Contains("liveness")
            });
        }
    }
}
