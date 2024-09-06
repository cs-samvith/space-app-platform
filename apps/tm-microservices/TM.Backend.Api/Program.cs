using Google.Api;
using Microsoft.ApplicationInsights.Extensibility;
using Microsoft.Extensions.Configuration;
using TM.Backend.Api;
using TM.Backend.Api.Health;
using TM.Backend.Api.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddApplicationInsightsTelemetry();
builder.Services.Configure<TelemetryConfiguration>((o) => {
    o.TelemetryInitializers.Add(new AppInsightsTelemetryInitializer());
});

// Add services to the container.
builder.Services.AddDaprClient();
builder.Services.AddSingleton<ITasksManager, TasksStoreManager>();

// builder.Services.AddSingleton<ITasksManager, FakeTasksManager>();
builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.Configure<StateStoreOptions>(builder.Configuration.GetSection("StateStoreOptions"));
builder.Services.Configure<SecretStoreOptions>(builder.Configuration.GetSection("SecretStoreOptions"));
builder.Services.Configure<DistributedEventBusOptions>(builder.Configuration.GetSection("DistributedEventBusOptions"));

builder.Services.AddSingleton<ICustomHealthCheck, DaprStateStoreHealthCheck>();
builder.Services.AddSingleton<ICustomHealthCheck, DaprSecretStoreHealthCheck>();
builder.Services.AddSingleton<ICustomHealthCheck, DaprHealthCheck>();
builder.Services.AddSingleton<ICustomHealthCheck, DaprPubSubHealthCheck>();

builder.Services.AddHealthCheck(builder.Configuration);

var app = builder.Build();

app.ApplyHealthChecks();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
