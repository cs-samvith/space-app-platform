using Microsoft.AspNetCore.Mvc;
using TM.Backend.Api.Models;
using TM.Backend.Api.Services;

namespace TM.Backend.Api.Controllers
{
    [Route("api/tasks")]
    [ApiController]
    public class TasksController : ControllerBase
    {
        private readonly ILogger<TasksController> _logger;
        private readonly ITasksManager _tasksManager;

        public TasksController(ILogger<TasksController> logger, ITasksManager tasksManager)
        {
            _logger = logger;
            _tasksManager = tasksManager;
        }

        [HttpGet]
        public async Task<IEnumerable<TaskModel>> Get(string createdBy)
        {
            _logger.LogInformation("======> TasksController --> Get Task By CreatedBy <=======", createdBy);

            return await _tasksManager.GetTasksByCreator(createdBy);
        }

        [HttpGet("{taskId}")]
        public async Task<IActionResult> GetTask(Guid taskId)
        {
            _logger.LogInformation("======> TasksController --> Get Task By TaskId <=======", taskId);

            var task = await _tasksManager.GetTaskById(taskId);

            return (task != null) ? Ok(task) : NotFound();
        }

        [HttpPost]
        public async Task<IActionResult> Post([FromBody] TaskAddModel taskAddModel)
        {
            _logger.LogInformation("======> TasksController --> Create Task <=======", taskAddModel.TaskName);

            var taskId = await _tasksManager.CreateNewTask(
                taskAddModel.TaskName,
                taskAddModel.TaskCreatedBy,
                taskAddModel.TaskAssignedTo,
                taskAddModel.TaskDueDate
            );

            return Created($"/api/tasks/{taskId}", null);

        }

        [HttpPut("{taskId}")]
        public async Task<IActionResult> Put(Guid taskId, [FromBody] TaskUpdateModel taskUpdateModel)
        {
            _logger.LogInformation("======> TasksController --> Update Task  <=======", taskId);

            var updated = await _tasksManager.UpdateTask(
                taskId,
                taskUpdateModel.TaskName,
                taskUpdateModel.TaskAssignedTo,
                taskUpdateModel.TaskDueDate
            );

            return updated ? Ok() : BadRequest();
        }

        [HttpPut("{taskId}/markcomplete")]
        public async Task<IActionResult> MarkComplete(Guid taskId)
        {
            _logger.LogInformation("======> TasksController --> Mark Complete  <=======", taskId);

            var updated = await _tasksManager.MarkTaskCompleted(taskId);

            return updated ? Ok() : BadRequest();
        }

        [HttpDelete("{taskId}")]
        public async Task<IActionResult> Delete(Guid taskId)
        {
            _logger.LogInformation("======> TasksController --> Delete Task  <=======", taskId);

            var deleted = await _tasksManager.DeleteTask(taskId);

            return deleted ? Ok() : NotFound();
        }
    }
}