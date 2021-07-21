using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System.Net.Http;
using System.Net;

namespace CallAnyUrl
{
    public static class GotoFunction
    {
        [FunctionName("goto")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            string url= req.Query["url"];

            string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
            dynamic data = JsonConvert.DeserializeObject(requestBody);
            url ??= data?.url;

            if (string.IsNullOrEmpty(url))
            {
                return new BadRequestObjectResult("no url provided");
            }
            else
            {
                var client = new HttpClient();
                var innerResponse = await client.GetAsync(url);
                string responseMessage = "couldn't find inner app service";
                if (innerResponse.StatusCode == HttpStatusCode.OK)
                {
                    var message = await innerResponse.Content.ReadAsStringAsync();
                    responseMessage = $"Call succeeded: {message}";
                }

                return new OkObjectResult(responseMessage);
            }
        }
    }
}
