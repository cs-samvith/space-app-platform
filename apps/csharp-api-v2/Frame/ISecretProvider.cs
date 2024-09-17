using System.Collections.Generic;
using System.Threading.Tasks;
using static csharp.api.Frame.AzureKeyVaultSecretProvider;

namespace csharp.api.Frame
{
    public interface ISecretProvider
    {
        IEnumerable<Secret> Get();

        string Get(string key);

        Task<string> GetAsync(string key);
    }


}
