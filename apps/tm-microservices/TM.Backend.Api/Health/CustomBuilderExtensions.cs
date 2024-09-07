using Dapr.Client;
using Google.Api;
using HealthChecks.UI.Client;
using Microsoft.AspNetCore.Diagnostics.HealthChecks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using static Google.Rpc.Context.AttributeContext.Types;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using csharp.api.Health;

namespace TM.Backend.Api.Health
{
    public static class CustomBuilderExtensions
    {

        public static void ApplyHealthChecks(this WebApplication app)
        {
            app.UseHealthChecks("/readiness", new HealthCheckOptions
            {
                ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse,
                Predicate = (h) => h.Tags.Contains("readiness")
            });

            app.UseHealthChecks("/liveness", new HealthCheckOptions
            {
                ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse,
                Predicate = (h) => h.Tags.Contains("liveness")
            });

            app.UseHealthChecks("/startup", new HealthCheckOptions
            {
                ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse,
            });
        }


        public static void AddHealthCheck(this IServiceCollection services, IConfiguration configuration,bool useDaprHealthChecks = true)
        {
            var healthCheckBuilder = services.AddHealthChecks();
            var serviceProvider = services.BuildServiceProvider();

         
  
            var healthCheckServices = serviceProvider.GetServices<ICustomHealthCheck>();
            foreach (var healthcheckservice in healthCheckServices)
            {
                if (healthcheckservice.Name == "DaprPubSubHealthCheck")
                {
                    healthCheckBuilder.AddCheck(healthcheckservice.Name, healthcheckservice, tags: new[] { "readiness" });
                }
                else if (healthcheckservice.Name == "memory_check")
                {
                    healthCheckBuilder.AddCheck(healthcheckservice.Name, healthcheckservice, tags: new[] { "liveness" });
                }
                else
                {
                    healthCheckBuilder.AddCheck(healthcheckservice.Name, healthcheckservice);
                }
            }

            if (useDaprHealthChecks)
            {
                var daprMetadata = GetDaprMetadata(serviceProvider);
                if (daprMetadata != null && daprMetadata.Components.Any()) RegisterHealthChecks(services, configuration, daprMetadata.Components);
            }
        }


        //public static void AddHealthCheck(this WebApplicationBuilder builder, bool useDaprHealthChecks = true)
        //{
        //    var healthCheckBuilder = builder.Services.AddHealthChecks();
        //    var serviceProvider = builder.Services.BuildServiceProvider();

        //    var healthCheckServices = serviceProvider.GetServices<ICustomHealthCheck>();
        //    foreach (var healthCheckService in healthCheckServices)
        //    {
        //        healthCheckBuilder.AddCheck(healthCheckService.Name, healthCheckService);
        //    }

        //    if (useDaprHealthChecks)
        //    {
        //        var daprMetadata = GetDaprMetadata(serviceProvider);
        //        if (daprMetadata != null && daprMetadata.Components.Any()) RegisterHealthChecks(builder, configuration, daprMetadata.Components);
        //    }
        //}

        private static DaprMetadata GetDaprMetadata(DaprClient daprClient)
        {
            return daprClient.GetMetadataAsync(default).GetAwaiter().GetResult();
        }

        private static DaprMetadata GetDaprMetadata(IServiceProvider serviceProvider)
        {
            var daprClient = serviceProvider.GetRequiredService<DaprClient>();
            //var logger = serviceProvider.GetRequiredService<ILogger>();


            var daprMetadata = GetDaprMetadata(daprClient); 

            if (daprMetadata == null)
            {
               // logger.LogError("GetDaprMetadata invoke error content: {content}");
              //  logger.LogError("GetDaprMetadata invoke error detail: {detail}");
                return null;
            }

            if (daprMetadata != null && daprMetadata.Components.Any())
                return daprMetadata;
            else
                return null;

            //var response = daprClient.GetMetadataAsync(); // null, "/v1.0/metadata", default).GetAwaiter().GetResult();
            //if (!response.IsSuccessStatusCode)
            //{
            //    var content = response.Content.ReadAsStringAsync().GetAwaiter().GetResult();
            //    logger.LogError("GetDaprMetadata invoke error content: {content}", content);
            //    logger.LogError("GetDaprMetadata invoke error detail: {detail}", response.ToString());

            //    return null;
            //}

            //var daprMetadata = response.Content.ReadFromJsonAsync<DaprMetadata>(daprClient.JsonSerializerOptions).GetAwaiter().GetResult();
            //if (daprMetadata is null) logger.LogInformation("Dapr Metadata is null!");

            //return daprMetadata;
        }

        //private static void RegisterHealthChecks(this WebApplicationBuilder builder, IReadOnlyList<DaprComponentsMetadata> components)
        //{
        //    //var secretStoreOptions = builder.Configuration.GetSection("SecretStoreOptions").Get<SecretStoreOptions>();
        //    var stateStoreOptions = builder.Configuration.GetSection("StateStoreOptions").Get<StateStoreOptions>();
        //    //var lockStoreOptions = services.GetOptions<DistributedLockOptions>(DistributedLockOptions.SECTION_NAME);

        //    //if (components.Any(x => x.Name == secretStoreOptions.StoreName)) builder.Services.AddTransient<ICustomHealthCheck, DaprSecretStoreHealthCheck>();
        //    if (components.Any(x => x.Name == stateStoreOptions.StoreName)) builder.Services.AddTransient<ICustomHealthCheck, DaprStateStoreHealthCheck>();
        //    //if (components.Any(x => x.Name == stateStoreOptions.SharedStoreName)) services.AddTransient<ICustomHealthCheck, DaprSharedStateStoreHealthCheck>();
        //    //if (components.Any(x => x.Name == lockStoreOptions.StoreName)) services.AddTransient<ICustomHealthCheck, DaprLockStoreHealthCheck>();
        //}


        private static void RegisterHealthChecks(this IServiceCollection services,IConfiguration configuration, IReadOnlyList<DaprComponentsMetadata> components)
        {
            var secretStoreOptions = configuration.GetSection("SecretStoreOptions").GetValue<string>("StoreName");
            var stateStoreOptions = configuration.GetSection("StateStoreOptions").GetValue<string>("StoreName");
            var distributedEventBusOptions = configuration.GetSection("DistributedEventBusOptions").GetValue<string>("StoreName");

            services.AddTransient<ICustomHealthCheck, DaprHealthCheck>();
            services.AddTransient<ICustomHealthCheck, MemoryHealthCheck>();

            if (components.Any(x => x.Name == secretStoreOptions)) services.AddTransient<ICustomHealthCheck, DaprSecretStoreHealthCheck>();
            if (components.Any(x => x.Name == stateStoreOptions)) services.AddTransient<ICustomHealthCheck, DaprStateStoreHealthCheck>();
            if (components.Any(x => x.Name == distributedEventBusOptions)) services.AddTransient<ICustomHealthCheck, DaprPubSubHealthCheck>();

            //if (components.Any(x => x.Name == stateStoreOptions.SharedStoreName)) services.AddTransient<ICustomHealthCheck, DaprSharedStateStoreHealthCheck>();
            //if (components.Any(x => x.Name == lockStoreOptions.StoreName)) services.AddTransient<ICustomHealthCheck, DaprLockStoreHealthCheck>();
        }
    }
}
