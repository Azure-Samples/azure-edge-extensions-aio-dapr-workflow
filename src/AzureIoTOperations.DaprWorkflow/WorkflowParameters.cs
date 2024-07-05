namespace AzureIoTOperations.DaprWorkflow
{
    using CommandLine;

    public class WorkflowParameters
    {
        [Option(
            "receiverPubSubName",
            Default = "aio-mq-pubsu",
            Required = false,
            HelpText = "Dapr pubsub messaging component name for receiving messages.")]
        public string? ReceiverPubSubName { get; set; }

        [Option(
            "receiverPubSubTopicName",
            Default = "telemetry",
            Required = false,
            HelpText = "Dapr pubsub messaging topic name for receiving messages.")]
        public string? ReceiverPubSubTopicName { get; set; }

        [Option(
            "senderPubSubName",
            Default = "aio-mq-pubsub",
            Required = false,
            HelpText = "Dapr pubsub messaging component name for sending messages.")]
        public string? SenderPubSubName { get; set; }

        [Option(
            "senderPubSubTopicName",
            Default = "enriched-telemetry",
            Required = false,
            HelpText = "Dapr workflow pubsub messaging topic name for sending messages.")]
        public string? SenderPubSubTopicName { get; set; }
    }
}
