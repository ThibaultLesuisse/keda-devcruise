using Applications.Front.Components;
using Azure.Messaging.ServiceBus;
using Microsoft.Extensions.Azure;
using MudBlazor.Services;
using StackExchange.Redis;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents()
    .AddInteractiveWebAssemblyComponents();
builder.Services.AddMudServices();
builder.Services.AddAzureClients(sb =>
{
    sb
        .AddServiceBusClient(builder.Configuration.GetConnectionString("ServiceBus"))
        .ConfigureOptions(options =>
        {
            options.TransportType = ServiceBusTransportType.AmqpWebSockets;
            options.RetryOptions = new ServiceBusRetryOptions
            {
                MaxRetries = 3,
                Mode = ServiceBusRetryMode.Exponential
            };
        });
    
    sb.AddClient<ServiceBusSender, ServiceBusClientOptions>((options, _, provider) 
            => provider.GetService<ServiceBusClient>()!.CreateSender("keda_servicebus_queue"))
        .WithName("servicebus");
});
builder.Services.AddSingleton<ConnectionMultiplexer>(
    ConnectionMultiplexer.Connect("redis-master.redis.svc.cluster.local:6379,password=admin"));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseWebAssemblyDebugging();
}
else
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();
app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();