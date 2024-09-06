using Dapr.Client;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Options;

namespace TM.Backend.Api.Health
{
    public class DaprPubSubHealthCheck : ICustomHealthCheck
    {
        private readonly DaprClient _daprClient;
        protected readonly DistributedEventBusOptions _distributedEventBusOptions;

        public DaprPubSubHealthCheck(DaprClient daprClient, IOptions<DistributedEventBusOptions> distributedEventBusOptions)
        {
            _daprClient = daprClient;
            _distributedEventBusOptions = distributedEventBusOptions.Value;
        }

        public virtual string Name => typeof(DaprPubSubHealthCheck).Name;
        protected virtual string PubSubName => _distributedEventBusOptions.PubSubName;

        public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
        {
            //try
            //{
            //    var topicName = $"{_distributedEventBusOptions.Prefix}-{"healthCheckTopic"}-{_distributedEventBusOptions.Postfix}";
            //    var timeToLeave = 60;
            //    var publishPath = $"/v1.0/publish/{PubSubName}/{topicName}?metadata.ttlInSeconds={timeToLeave}";

            //    var response = await _daprClient.InvokeMethodAsync(HttpMethod.Post, publishPath, cancellationToken);
            //    await _daprClient.PublishEventAsync("dapr-pubsub-servicebus", "tasksavedtopic", null);


            //    if (!response.IsSuccessStatusCode)
            //    {
            //        var content = await response.Content.ReadAsStringAsync(cancellationToken: cancellationToken);
            //        return new HealthCheckResult(context.Registration.FailureStatus, $"Dapr pubsub: {PubSubName} is unhealthy. HttpStatusCode: {response.StatusCode}, Content: {content}");
            //    }

            //    return HealthCheckResult.Healthy($"Dapr pubsub: {PubSubName} for topic '{topicName}' is healthy.");
            //}
            //catch (Exception ex)
            //{
            //    return new HealthCheckResult(context.Registration.FailureStatus, $"Dapr pubsub: {PubSubName} is unhealthy. Error: {ex.Message}");
            //}

            try
            {
                var topicName = $"{_distributedEventBusOptions.Prefix}-{"healthCheckTopic"}-{_distributedEventBusOptions.Postfix}";
                var timeToLeave = 60;

                await _daprClient.PublishEventAsync(PubSubName, topicName, default);

                return HealthCheckResult.Healthy(
                    $"Dapr pubsub: {PubSubName} for topic '{topicName}' is healthy."
                );
            }
            catch (Exception ex)
            {
                return new HealthCheckResult(
                    context.Registration.FailureStatus,
                    $"Dapr pubsub: {PubSubName} is unhealthy. Error: {ex.Message}"
                );
            }
        }
    }
}
