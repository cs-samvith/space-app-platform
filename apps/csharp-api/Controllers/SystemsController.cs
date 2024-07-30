using csharp.api.Data;
using csharp.api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace csharp.api.Controllers
{
    [ApiController]
    [Route("[controller]")]
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
            var sysInfo = new SystemInfo();
            sysInfo.ContainerName = System.Environment.MachineName;
            return Task.FromResult(sysInfo);
        }
    }
}
