using System.Net;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.Extensions.Logging;

namespace Demo.FunctionsApp.Functions
{
    public class DemoFunction
    {
        private readonly ILogger _logger;

        public DemoFunction(ILoggerFactory loggerFactory)
        {
            _logger = loggerFactory.CreateLogger<DemoFunction>();
        }

        [Function("DemoFunction")]
        public HttpResponseData Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequestData req)
        {
            var response = req.CreateResponse(HttpStatusCode.OK);
            response.Headers.Add("Content-Type", "text/plain; charset=utf-8");
            response.WriteString("Demo function works!");

            return response;
        }
    }
}
