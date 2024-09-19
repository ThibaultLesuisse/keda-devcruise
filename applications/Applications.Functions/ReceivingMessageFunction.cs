using System.Text;
using System.Text.Json;
using Applications.Shared;
using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;
using StackExchange.Redis;

namespace Applications.Functions;

public class ReceivingMessageFunction
{
    private readonly ILogger<ReceivingMessageFunction> _logger;
    private readonly ConnectionMultiplexer _connectionMultiplexer;

    public ReceivingMessageFunction(ILogger<ReceivingMessageFunction> logger, ConnectionMultiplexer connectionMultiplexer)
    {
        _logger = logger;
        _connectionMultiplexer = connectionMultiplexer;
    }
    
    [Function("ReceivingMessage")]
    public void Run(
        [ServiceBusTrigger("keda_servicebus_queue", Connection = "ServiceBusConnection")] ServiceBusReceivedMessage message)
    {
        try
        {
            Vote? vote = JsonSerializer.Deserialize<Vote>(Encoding.UTF8.GetString(message.Body));
        
            IDatabase db = _connectionMultiplexer.GetDatabase();

            var practiceManager = vote.PracticeManager;

            db.StringIncrement(Enum.GetName<PracticeManagerEnum>(practiceManager));
        
            _logger.LogInformation("Finished succesfully");
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            throw;
        }
    }
}