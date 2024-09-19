using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.DependencyInjection;
using StackExchange.Redis;

var host = new HostBuilder()
    .ConfigureFunctionsWorkerDefaults()
    .ConfigureServices(s =>
    {
        s.AddApplicationInsightsTelemetryWorkerService();
        s.ConfigureFunctionsApplicationInsights();
        s.AddSingleton<ConnectionMultiplexer>(
            ConnectionMultiplexer.Connect("redis-master.redis.svc.cluster.local:6379,password=admin"));
    })
    .Build();

host.Run();