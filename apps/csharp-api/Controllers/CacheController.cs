using csharp.api.Data;
using csharp.api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;

namespace csharp.api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CacheController : ControllerBase
    {
        private readonly ILogger<CacheController> _logger;
        private readonly IMemoryCache _memoryCache;

        public CacheController(ILogger<CacheController> logger, IMemoryCache memoryCache)
        {
            _logger = logger;
            _memoryCache = memoryCache;
        }

        [HttpGet("{cacheKey}")]
        public async Task<IActionResult> Get(string cacheKey)
        {
            if (_memoryCache.TryGetValue(cacheKey, out var item))
            {
                return Ok(new { item = item });
            }

            item = await LongRunningProcess();


            var itemtoadd = LongRunningProcess1(1000);

            var options = new MemoryCacheEntryOptions()
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromSeconds(3600),
                SlidingExpiration = TimeSpan.FromSeconds(1200)
            };

            _memoryCache.Set(cacheKey, itemtoadd, options);
            return Ok(new { item = item });
        }

        private static async Task<int> LongRunningProcess()
        {
            await Task.Delay(1000);

            var random = new Random();
            return random.Next(100000, 200000);
        }

        private static IEnumerable<Customer> LongRunningProcess1(int count)
        {
            var listCustomer = new
                List<Customer>();

            for (int i = 0; i < count; i++)
            {
                var customer = new Customer();

                customer.Id = i;
                customer.Name = "test";
                customer.EmailAddress = "test";
                listCustomer.Add(customer);
            }

            return listCustomer;
        }
    }
}
