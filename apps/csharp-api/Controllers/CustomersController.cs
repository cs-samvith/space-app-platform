using csharp.api.Data;
using csharp.api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace csharp.api.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class CustomersController : ControllerBase
    {
        private readonly ILogger<CustomersController> _logger;
        private readonly AppDbContext _context;

        public CustomersController(AppDbContext context,ILogger<CustomersController> logger)
        {
            _logger = logger;
            _context = context;
        }

        [HttpGet(Name = "GetCustomers")]
        public async Task<IEnumerable<Customer>> GetAsync()
        {
            _logger.LogTrace("LogTrace --> Get Customer Called--1");
            _logger.LogWarning("LogWarning --> Get Customer Called--2");
            _logger.LogError("LogError --> Get Customer Called--3");
            _logger.LogInformation("LogInformation --> Get Customer Called--4");
            return await _context.Customers.ToListAsync();
        }
    }
}
