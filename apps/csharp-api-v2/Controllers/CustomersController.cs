using csharp.api.Data;
using csharp.api.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace csharp.api.Controllers
{
    [ApiController]
    [Route("v2/[controller]")]
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
            _logger.LogInformation("Get Customers Called");
            return await _context.Customers.ToListAsync();
        }
    }
}
