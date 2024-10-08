﻿namespace AzureIoTOperations.DaprWorkflow.Activities
{
    using System;
    using System.Threading.Tasks;
    using Dapr.Client;
    using Dapr.Workflow;
    using AzureIoTOperations.DaprWorkflow;
    using Microsoft.Extensions.Logging;

    public class PublishActivity : WorkflowActivity<string, bool>
    {
        private readonly ILogger<PublishActivity> _logger;
        private readonly DaprClient _daprClient;
        private readonly string? _senderPubsubName;
        private readonly string? _senderPubsubTopicName;

        public PublishActivity(
            ILogger<PublishActivity> logger,
            DaprClient daprClient,
            WorkflowParameters parameters)
        {
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
            _daprClient = daprClient ?? throw new ArgumentNullException(nameof(daprClient));

            if (parameters == null)
            {
                throw new ArgumentNullException(nameof(parameters));
            }

            _senderPubsubName = parameters.ReceiverPubSubName;
            _senderPubsubTopicName = parameters.SenderPubSubTopicName;

            _logger.LogTrace($"Entering: {nameof(PublishActivity)}");
        }

        public override async Task<bool> RunAsync(WorkflowActivityContext context, string input)
        {
            _logger.LogTrace($"Publishing data: {input}");
            try
            {
                await _daprClient.PublishEventAsync(_senderPubsubName, _senderPubsubTopicName, input);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, $"Publishing to pubsub {_senderPubsubName}, topic {_senderPubsubTopicName} failed.");
                return false;
            }

            return true;
        }
    }
}
