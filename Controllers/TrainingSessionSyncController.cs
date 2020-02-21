using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using System.Text.Json;
using Microsoft.Extensions.Configuration;

namespace AzureSamples.AzureSQL.Controllers
{
    [ApiController]
    [Route("trainingsession/sync")]
    public class TrainingSessionSyncController : ControllerQuery
    {
        public TrainingSessionSyncController(IConfiguration config, ILogger<TrainingSessionSyncController> logger):
            base(config, logger) {}

        public async Task<JsonElement> Get()
        {
            var clientId = HttpContext.Request.Headers["ClientId"].FirstOrDefault();
            var fromVersion = Int32.Parse(HttpContext.Request.Headers["FromVersion"].FirstOrDefault() ?? "0");

            var payload = new {
                clientId = clientId,
                fromVersion = fromVersion
            };

            var jp = JsonDocument.Parse(JsonSerializer.Serialize(payload));
            
            this._logger.LogInformation($"clientId {clientId}, fromVersion {fromVersion}");

            return await this.Query("get", this.GetType(), payload: jp.RootElement);
        }
    }
}
