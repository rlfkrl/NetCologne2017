### Projekt anlegen ###
* leeres ASP.NET Core Projekt anlegen
* Nuget-Packages
	* "IdentityServer4" 
	* Microsoft.Extensions.Logging.Debug
	* "Serilog.Extensions.Logging.File
### IdentityServer einbinden ###

<pre>
* public class Startup
{
    public void ConfigureServices(IServiceCollection services)
    {
        services.AddIdentityServer()
            .AddTemporarySigningCredential();
    }

    public void Configure(IApplicationBuilder app, ILoggerFactory loggerFactory)
    {
        loggerFactory.AddConsole(LogLevel.Debug);
		loggerFactory.AddDebug();

        app.UseDeveloperExceptionPage();

        app.UseIdentityServer();
    }
}
</pre>

### IdentityServer4 konfigurieren - Client anlegen ###

Config.cs

* Resource
* Client
* User

Startup.cs
<pre>
	.AddInMemoryApiResources(Config.GetApiResources())
    .AddInMemoryClients(Config.GetClients())
	.AddTestUsers(Config.GetUsers());
</pre>


### UI hinzufügen ###

https://github.com/IdentityServer/IdentityServer4.Quickstart.UI/tree/release

Packages
* Microsoft.AspNetCore.Mvc
* Microsoft.AspNetCore.StaticFiles
