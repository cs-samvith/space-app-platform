using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using TM.Backend.Processor.Models;

namespace TM.Backend.Processor.Controllers
{
    [Route("ScheduledTasksManager")]
    [ApiController]
    public class ScheduledTasksManagerController : ControllerBase
    {
        private readonly ILogger<ScheduledTasksManagerController> _logger;
        private readonly DaprClient _daprClient;
        public ScheduledTasksManagerController(ILogger<ScheduledTasksManagerController> logger, DaprClient daprClient)
        {
            _logger = logger;
            _daprClient = daprClient;
        }

        [HttpPost]
        public async Task CheckOverDueTasksJob()
        {
            var runAt = DateTime.UtcNow;

            _logger.LogInformation($"======> ScheduledTasksManager TIMER TRIGGER <======= :Timer Services triggered at: {runAt}");

            var overdueTasksList = new List<TaskModel>();

            var tasksList = await _daprClient.InvokeMethodAsync<List<TaskModel>>(HttpMethod.Get, "tm-backend-api", $"api/overduetasks");

            _logger.LogInformation($"======> ScheduledTasksManager CALL BACKEND API TO GET OVERDUE TASK <=======::completed query state store for tasks, retrieved tasks count: {tasksList?.Count()}");

            tasksList?.ForEach(taskModel =>
            {
                if (runAt.Date > taskModel.TaskDueDate.Date)
                {
                    overdueTasksList.Add(taskModel);
                }
            });

            if (overdueTasksList.Count > 0)
            {
                _logger.LogInformation($"======> ScheduledTasksManager CALL BACKEND API TO MARK OVERDUE TASK <=======::marking {overdueTasksList.Count()} as overdue tasks");

                await _daprClient.InvokeMethodAsync(HttpMethod.Post, "tm-backend-api", $"api/overduetasks/markoverdue", overdueTasksList);
            }
        }
    }
}