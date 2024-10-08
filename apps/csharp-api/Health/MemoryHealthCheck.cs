﻿using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Options;

namespace csharp.api.Health
{
    public class MemoryHealthCheck : IHealthCheck
    {
        private readonly IOptionsMonitor<MemoryCheckOptions> _options;

        public MemoryHealthCheck(IOptionsMonitor<MemoryCheckOptions> options)
        {
            _options = options;
        }

        public string Name => "memory_check";

        public Task<HealthCheckResult> CheckHealthAsync(
            HealthCheckContext context,
            CancellationToken cancellationToken = default)
        {
            var options = _options.Get(context.Registration.Name);

            // Include GC information in the reported diagnostics.
            var allocated = GC.GetTotalMemory(forceFullCollection: false);

            var threshold = GC.GetGCMemoryInfo().TotalAvailableMemoryBytes / 5;

            var data = new Dictionary<string, object>()
            {
                { "ConatinerName", System.Environment.MachineName},
                { "AllocatedBytes", allocated },
                { "threshold", threshold},
                { "GetTotalMemory", GC.GetTotalMemory(forceFullCollection: false) },
                { "GetTotalAllocatedBytes", GC.GetTotalAllocatedBytes()},
                //{ "GC.GetGCMemoryInfo().TotalCommittedBytes", GC.GetGCMemoryInfo().TotalCommittedBytes},
                { "GC.GetGCMemoryInfo().TotalAvailableMemoryBytes", GC.GetGCMemoryInfo().TotalAvailableMemoryBytes},
            };
            //var status = allocated < options.Threshold ? HealthStatus.Healthy : HealthStatus.Unhealthy;
      
            var status = allocated < threshold ? HealthStatus.Healthy : HealthStatus.Unhealthy;

            return Task.FromResult(new HealthCheckResult(
                status,
                description: $"Reports degraded status if allocated bytes is greater than or equal to {threshold} bytes",
                exception: null,
                data: data));
        }
    }
    public class MemoryCheckOptions
    {
        public string Memorystatus { get; set; }
        //public int Threshold { get; set; }
        // Failure threshold (in bytes)
        public long Threshold { get; set; } = 1024L * 1024L * 1024L;
    }
}
