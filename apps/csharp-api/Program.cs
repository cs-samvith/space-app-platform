using csharp.api.Data;
using csharp.api.Frame;
using csharp.api.Health;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.ApplicationInsights;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.AddSecrets();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

//HealthCheck Middleware

builder.Logging.AddApplicationInsights(
        configureTelemetryConfiguration: (config) =>
            config.ConnectionString = builder.Configuration.GetConnectionString("AppInsights"),
            configureApplicationInsightsLoggerOptions: (options) => {  }
    );

builder.Services.AddApplicationInsightsTelemetry();

builder.Logging.AddFilter<ApplicationInsightsLoggerProvider>("", LogLevel.Information);

IServiceProvider serviceProvider = builder.Services.BuildServiceProvider();
ILogger<Program> logger = serviceProvider.GetRequiredService<ILogger<Program>>();

builder.Services.AddHttpClient();
builder.Services.AddMemoryCache();

//var connstring = builder.Configuration.GetConnectionString("MySqlConn");

//var connstring = builder.Configuration.GetSection("mysql")
//                .GetValue<string>("connectionstring");

var connstring=Environment.GetEnvironmentVariable("AZURE_MYSQL_CONNECTIONSTRING");

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseMySql(connstring, ServerVersion.AutoDetect(connstring));
    //https://www.youtube.com/watch?v=zVv9YWePvlw
    //https://medium.com/@chandrashekharsingh25/build-a-restful-web-api-with-net-8-44fc93b36618
    //https://azure.github.io/java-aks-aca-dapr-workshop/modules/11-aca-challenge/04-deploy-to-aca/
});

builder.Services.ConfigureHealthChecks(connstring);

logger.LogInformation("****Initializing***** ==> " + connstring);
logger.LogInformation("****Initializing->TestSecret1***** ==> " + Environment.GetEnvironmentVariable("test1"));
logger.LogInformation("****Initializing->TestSecret2***** ==> " + Environment.GetEnvironmentVariable("test2"));


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
