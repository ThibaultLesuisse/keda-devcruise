using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace Applications.Functions;

public class ReceivingMessageFunction
{
    private readonly ILogger<ReceivingMessageFunction> _logger;

    public ReceivingMessageFunction(ILogger<ReceivingMessageFunction> logger)
    {
        _logger = logger;
    }
    [Function("RecievingMessage")]
    public void Run(
        [ServiceBusTrigger("keda_servicebus_queue", Connection = "ServiceBusConnection")] ServiceBusReceivedMessage message,
        FunctionContext context)
    {
        // Use a string array to return more than one message.
        _logger.LogInformation("Recevied: {msg1}", message.Body);
    }
}