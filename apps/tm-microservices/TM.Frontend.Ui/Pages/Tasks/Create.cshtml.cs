using Dapr.Client;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using TM.Frontend.Ui.Pages.Tasks.Models;

namespace TM.Frontend.Ui.Pages.Tasks
{
    public class CreateModel : PageModel
    {
        //private readonly IHttpClientFactory _httpClientFactory;
        private readonly DaprClient _daprClient;

        public CreateModel(IHttpClientFactory httpClientFactory, DaprClient daprClient)
        {
          //  _httpClientFactory = httpClientFactory;
            _daprClient = daprClient;
        }
        public string? TasksCreatedBy { get; set; }

        public IActionResult OnGet()
        {
            TasksCreatedBy = Request.Cookies["TasksCreatedByCookie"];

            return (!String.IsNullOrEmpty(TasksCreatedBy)) ? Page() : RedirectToPage("../Index");
        }

        [BindProperty]
        public TaskAddModel? TaskAdd { get; set; }

        public async Task<IActionResult> OnPostAsync()
        {
            if (!ModelState.IsValid)
            {
                return Page();
            }

            if (TaskAdd != null)
            {
                var createdBy = Request.Cookies["TasksCreatedByCookie"];

                if (!string.IsNullOrEmpty(createdBy))
                {
                    TaskAdd.TaskCreatedBy = createdBy;

                    //// direct svc to svc http request
                    //var httpClient = _httpClientFactory.CreateClient("BackEndApiExternal");
                    //var result = await httpClient.PostAsJsonAsync("api/tasks/", TaskAdd);

                    // Dapr SideCar Invocation
                    await _daprClient.InvokeMethodAsync(HttpMethod.Post, "tm-backend-api", $"api/tasks", TaskAdd);
                }
            }

            return RedirectToPage("./Index");
        }
    }
}