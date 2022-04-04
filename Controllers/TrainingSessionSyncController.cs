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
    [Route("/api/v1/training-session/sync/{versionId?}")]
    public class TrainingSessionSyncController : ControllerQuery
    {
        public TrainingSessionSyncController(IConfiguration config, ILogger<TrainingSessionSyncController> logger):
            base(config, logger) {}

        public async Task<JsonElement> Get(int? versionId)
        {
            var clientId = HttpContext.Request.Headers["ClientId"].FirstOrDefault();
            var fromVersion = versionId.HasValue ? versionId.Value : 0;

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
