using Azure.Extensions.AspNetCore.Configuration.Secrets;
using Microsoft.Extensions.Configuration;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace csharp.api.Frame
{
    public class AzureKeyVaultSecretProvider : ISecretProvider
    {
        private readonly IConfiguration _secrets;
        private readonly AzureKeyVaultConfigurationProvider _provider;

        public AzureKeyVaultSecretProvider(
            IConfiguration secrets
        ){
            _secrets = secrets;

            var root = secrets as IConfigurationRoot;

            _provider = root.Providers
                .Where(p => p.GetType() == typeof(AzureKeyVaultConfigurationProvider))
                .FirstOrDefault() as AzureKeyVaultConfigurationProvider
                ;
        }

        public string Get(string key)
        {
            return _secrets[key];
        }

        public Task<string> GetAsync(string key)
        {
            var value = _secrets[key];

            return Task.FromResult(value);
        }

        public IEnumerable<Secret> Get()
        {
            var list = new List<Secret>();

            foreach (var key in _provider.GetChildKeys(new List<string>(), null))
            {
                if (_provider.TryGet(key, out var value))
                {
                    list.Add(new Secret(
                        Key: key,
                        Value: value
                    ));
                }
            }

            return list.AsEnumerable();
        }

        public record Secret(
            string Key,
            string Value
        );
    }
}
