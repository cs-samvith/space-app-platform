using csharp.api.Models;
using Microsoft.AspNetCore.Mvc;

namespace csharp.api.Controllers
{
    [ApiController]
    [Route("v2/[controller]")]
    public class SystemsController : ControllerBase
    {
        private readonly ILogger<SystemsController> _logger;

        public SystemsController(ILogger<SystemsController> logger)
        {
            _logger = logger;
        }

        [HttpGet(Name = "GetSystemInfo")]
        public Task<SystemInfo> GetAsync()
        {
            _logger.LogInformation("Get SystemInfo Called");
            var sysInfo = new SystemInfo();
            sysInfo.ContainerName = System.Environment.MachineName;
            return Task.FromResult(sysInfo);
        }
    }
}
