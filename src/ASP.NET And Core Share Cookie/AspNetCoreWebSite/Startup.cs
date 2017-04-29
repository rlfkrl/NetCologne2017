using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using System.IdentityModel.Tokens.Jwt;
using Microsoft.IdentityModel.Tokens;
using System.IO;
using Microsoft.AspNetCore.DataProtection;

namespace AspNetCoreWebSite
{
    public class Startup
    {
        public Startup(IHostingEnvironment env)
        {
            var builder = new ConfigurationBuilder()
                .SetBasePath(env.ContentRootPath)
                .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
                .AddJsonFile($"appsettings.{env.EnvironmentName}.json", optional: true)
                .AddEnvironmentVariables();
            Configuration = builder.Build();
        }

        public IConfigurationRoot Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            // Add framework services.
            services.AddMvc();
        }

        public const string DncAspNetUrl = "https://localhost/dncaspnet";
        public const string DncIdsUrl = "https://localhost/dncids";
        public const string DncAspNetCoreUrl = "https://localhost/dncaspnetcore";

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IHostingEnvironment env, ILoggerFactory loggerFactory)
        {
            loggerFactory.AddConsole(Configuration.GetSection("Logging"));
            loggerFactory.AddDebug();
            loggerFactory.AddFile("Logs/identityServer-{Date}.log");

            app.UseDeveloperExceptionPage();

            app.UseStaticFiles();

            app.UseCookieAuthentication( new CookieAuthenticationOptions {
                AuthenticationScheme = "Cookies",
                AutomaticAuthenticate = true,
                ExpireTimeSpan = TimeSpan.FromMinutes( 60 ),
                CookieName = "DNC2017_SharedAuthCookie",
                CookiePath = "/",
                CookieSecure = Microsoft.AspNetCore.Http.CookieSecurePolicy.Always,
                // @Note: share dataprotection keys
                DataProtectionProvider = DataProtectionProvider.Create(new DirectoryInfo(@"c:\shared-auth-ticket-keys\"))
            });

            JwtSecurityTokenHandler.DefaultInboundClaimTypeMap.Clear();

            app.UseOpenIdConnectAuthentication(
                    new OpenIdConnectOptions {
                        AuthenticationScheme = "oidc",
                        SignInScheme = "Cookies",

                        Authority = DncIdsUrl,
                        RequireHttpsMetadata = false,

                        ClientId = "client",
                        ClientSecret = "secret",
                        
                        ResponseType = "code id_token",
                        Scope = { "openid", "profile" },

                        GetClaimsFromUserInfoEndpoint = true,
                        SaveTokens = true,
                        PostLogoutRedirectUri = DncAspNetCoreUrl,

                        TokenValidationParameters = new TokenValidationParameters() { NameClaimType = "name" },

                    });

            app.UseMvc(routes =>
            {
                routes.MapRoute(
                    name: "default",
                    template: "{controller=Home}/{action=Index}/{id?}");
            });
        }
    }
}
