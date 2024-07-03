// Local run cmd line.
// dapr run --app-id workflow-module --app-protocol grpc --app-port 5002 --resources-path=./Components --dapr-grpc-port 5005 -- dotnet run -- --receiverPubSubName "local-pub-sub" --receiverPubSubTopicName "telemetry" --senderPubSubName "local-pub-sub" --senderPubSubTopicName "enriched-telemetry"
// mosquitto_pub -h localhost -p 1883 -t telemetry -m '{"ambient":{"temperature":10}}'
// mosquitto_sub -h localhost -p 1883 -t enriched-telemetry
// dapr publish --publish-app-id workflow-module --pubsub local-pub-sub --topic telemetry --data '{"ambient":{"temperature":10}}' --metadata '{"rawPayload":"true"}'

using CommandLine;
using Dapr.Workflow;
using AzureIoTOperations.DaprWorkflow;
using AzureIoTOperations.DaprWorkflow.Services;
using AzureIoTOperations.DaprWorkflow.Workflows;
using Microsoft.AspNetCore.Server.Kestrel.Core;
using AzureIoTOperations.DaprWorkflow.Activities;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddDaprWorkflow(options =>
{
    options.RegisterWorkflow<EnrichTelemetryWorkflow>();
    options.RegisterActivity<EnrichmentActivity>();
    options.RegisterActivity<PublishActivity>();
});

WorkflowParameters? parameters;

var result = Parser.Default.ParseArguments<WorkflowParameters>(args)
    .WithParsed(parsedParams =>
    {
        parameters = parsedParams;
        builder.Services.AddSingleton<WorkflowParameters>(sp => parameters);

        // Already registered by AddDaprWorkflow extension
        //builder.Services.AddSingleton<DaprClient>(new DaprClientBuilder().Build());
        builder.Services.AddTransient<SubscriptionService>(
            sp => new SubscriptionService(
                sp.GetRequiredService<ILogger<SubscriptionService>>(),
                sp.GetRequiredService<DaprWorkflowClient>(),
                parameters));
    })
    .WithNotParsed(errors =>
    {
        Environment.Exit(1);
    });

builder.WebHost.ConfigureKestrel(k => k.ListenLocalhost(5002, op => op.Protocols =
   HttpProtocols.Http2));

// Additional configuration is required to successfully run gRPC on macOS.
// For instructions on how to configure Kestrel and gRPC clients on macOS, visit https://go.microsoft.com/fwlink/?linkid=2099682
builder.Services.AddGrpc();

var app = builder.Build();
app.UseRouting();
// Configure the HTTP request pipeline.
app.MapGrpcService<SubscriptionService>();

app.MapGet("/", () => "Communication with gRPC endpoints must be made through a gRPC client. To learn how to create a client, visit: https://go.microsoft.com/fwlink/?linkid=2086909");

app.Run();
