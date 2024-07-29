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
                    .AddMySql(connstring, healthQuery: "SELECT 1 FROM testdb.customers", name: "SQL servere", failureStatus: HealthStatus.Unhealthy, tags: new[] { "testdb", "Database" })
                    //.AddCheck<RemoteHealthCheck>("Remote endpoints Health Check", failureStatus: HealthStatus.Unhealthy)
                    .AddCheck<MemoryHealthCheck>($"Feedback Service Memory Check", failureStatus: HealthStatus.Unhealthy, tags: new[] { "Feedback Service" });

            //.AddUrlGroup(new Uri("https://localhost:44333/api/v1/heartbeats/ping"), name: "base URL", failureStatus: HealthStatus.Unhealthy); 

            ////services.AddHealthChecksUI();

            //services.AddHealthChecksUI(opt =>
            //{
            //    opt.SetEvaluationTimeInSeconds(10); //time in seconds between check    
            //    opt.MaximumHistoryEntriesPerEndpoint(60); //maximum history of checks    
            //    opt.SetApiMaxActiveRequests(1); //api requests concurrency    
            //    opt.AddHealthCheckEndpoint("feedback api", "/api/health"); //map health check api    

            //})
            //    .AddInMemoryStorage();
            
        }

        public static void ApplyHealthChecks(this WebApplication app)
        {
            app.UseHealthChecks("/api/health", new HealthCheckOptions
            {
                ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse
            });
        }
    }
}
