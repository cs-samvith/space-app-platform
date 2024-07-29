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

builder.Logging.AddFilter<ApplicationInsightsLoggerProvider>("trace", LogLevel.Trace);

IServiceProvider serviceProvider = builder.Services.BuildServiceProvider();
ILogger<Program> logger = serviceProvider.GetRequiredService<ILogger<Program>>();

logger.LogWarning("LogWarning->Logger is working...");
logger.LogTrace("LogTrace->Logger is working...");
logger.LogInformation("LogInformation->Logger is working...");



builder.Services.AddHttpClient();

//var connstring = builder.Configuration.GetConnectionString("MySqlConn");

var connstring = builder.Configuration.GetSection("mysql")
                .GetValue<string>("connectionstring");

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseMySql(connstring, ServerVersion.AutoDetect(connstring));
    //https://www.youtube.com/watch?v=zVv9YWePvlw
    //https://medium.com/@chandrashekharsingh25/build-a-restful-web-api-with-net-8-44fc93b36618
});

builder.Services.ConfigureHealthChecks(connstring);

logger.LogInformation("connstring ==> " + connstring);


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
