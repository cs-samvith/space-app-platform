using Dapr;
using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using TM.Backend.Processor.Models;

namespace TM.Backend.Processor.Controllers
{
    [Route("api/tasksnotifier")]
    [ApiController]
    public class TasksNotifierController : ControllerBase
    {
        private readonly IConfiguration _config;
        private readonly ILogger _logger;
        private readonly DaprClient _daprClient;

        public TasksNotifierController(IConfiguration config, ILogger<TasksNotifierController> logger, DaprClient daprClient)
        {
            _config = config;
            _logger = logger;
            _daprClient = daprClient;
        }

        [Topic("dapr-pubsub-servicebus", "tasksavedtopic")]     //Dapr Pub Sub Service Bus
        [Topic("taskspubsub", "tasksavedtopic")]                //Redis
        [HttpPost("tasksaved")]
        public IActionResult TaskSaved([FromBody] TaskModel taskModel)
        {
            var msg = string.Format("Started processing message with Task Name '{0}'", taskModel.TaskName);
            _logger.LogInformation("======> TasksNotifier  <======= Started processing message with Task Name '{0}'", taskModel.TaskName);

            return Ok(msg);
        }
    }
}