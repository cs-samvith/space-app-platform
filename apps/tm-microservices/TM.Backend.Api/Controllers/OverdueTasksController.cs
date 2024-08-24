using Microsoft.AspNetCore.Mvc;
using TM.Backend.Api.Models;
using TM.Backend.Api.Services;

namespace TM.Backend.Api.Controllers
{
    [Route("api/overduetasks")]
    [ApiController]
    public class OverdueTasksController : ControllerBase
    {
        private readonly ILogger<TasksController> _logger;
        private readonly ITasksManager _tasksManager;

        public OverdueTasksController(ILogger<TasksController> logger, ITasksManager tasksManager)
        {
            _logger = logger;
            _tasksManager = tasksManager;
        }

        [HttpGet]
        public async Task<IEnumerable<TaskModel>> Get()
        {
            _logger.LogInformation("======> OverdueTasksController--> Get Yesterdays Task  <=======");

            return await _tasksManager.GetYesterdaysDueTasks();
        }

        [HttpPost("markoverdue")]
        public async Task<IActionResult> Post([FromBody] List<TaskModel> overdueTasksList)
        {
            _logger.LogInformation("======> OverdueTasksController--> Mark Overdue  <=======");

            await _tasksManager.MarkOverdueTasks(overdueTasksList);

            return Ok();
        }
    }
}