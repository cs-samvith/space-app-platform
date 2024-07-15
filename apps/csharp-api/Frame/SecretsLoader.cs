using Azure.Extensions.AspNetCore.Configuration.Secrets;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;
using csharp.api.Frame;

namespace csharp.api.Frame;

public static class SecretsLoader
{
    public static void AddSecrets(this WebApplicationBuilder builder)
    {
        Load(builder.Configuration);
        builder.Services.AddSingleton<ISecretProvider, AzureKeyVaultSecretProvider>();
    }

    private static void Load(IConfigurationBuilder builder)
    {
        var settings = builder.Build().GetSection("azureKeyVault");

        var credential = new DefaultAzureCredential(new DefaultAzureCredentialOptions
        {
            ManagedIdentityClientId = settings.GetValue<string>("identity")
        });

        var client = new SecretClient(new Uri(settings.GetValue<string>("uri")), credential);

        var options = new AzureKeyVaultConfigurationOptions
        {
            ReloadInterval = TimeSpan.FromMinutes(30)
        };

        builder.AddAzureKeyVault(client, options);
    }
}
