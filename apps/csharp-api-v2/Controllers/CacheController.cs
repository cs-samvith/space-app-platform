using csharp.api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;

namespace csharp.api.Controllers
{
    [ApiController]
    [Route("v2/[controller]")]
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
            _logger.LogInformation("Set/Get From Cache Called");
            if (_memoryCache.TryGetValue(cacheKey, out var item))
            {
                return Ok(new { item = item });
            }

            var itemtoadd = LongRunningProcess1(200000);

            var options = new MemoryCacheEntryOptions()
            {
                AbsoluteExpirationRelativeToNow = TimeSpan.FromSeconds(3600),
                SlidingExpiration = TimeSpan.FromSeconds(1200)
            };

            _memoryCache.Set(cacheKey, itemtoadd, options);

            return Ok(new { item = itemtoadd });
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
