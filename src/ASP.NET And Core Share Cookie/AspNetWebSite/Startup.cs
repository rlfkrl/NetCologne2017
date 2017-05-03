using Microsoft.Owin;
using Microsoft.Owin.Diagnostics;
using Microsoft.Owin.Security;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.Interop;
using Owin;
using System;
using System.IO;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;
using Microsoft.AspNetCore.DataProtection;

[assembly: OwinStartup("Startup", typeof(AspNetWebSite.Startup))]

namespace AspNetWebSite
{
    public class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            app.UseErrorPage(new ErrorPageOptions()
            {
                ShowCookies = true,
                ShowHeaders = true
            } );

            /* used for debugging 
            app.Use(async (Context, next) =>
            {
                await next.Invoke();
            });
            */

            app.SetDefaultSignInAsAuthenticationType(CookieAuthenticationDefaults.AuthenticationType);

            var provider = DataProtectionProvider.Create(new DirectoryInfo(@"c:\shared-auth-ticket-keys\"));
            var dataProtector =  provider.CreateProtector("Microsoft.AspNetCore.Authentication.Cookies.CookieAuthenticationMiddleware",
                                        "Cookies", "v2");

            app.UseCookieAuthentication( new CookieAuthenticationOptions {
                    AuthenticationType = "Cookie",                  
                    ExpireTimeSpan = TimeSpan.FromMinutes(60),
                    CookieName = "DNC2017_SharedAuthCookie",            // the shared cookie name 
                    CookiePath = "/",                                   // force cookie to be send to both
                    CookieSecure = CookieSecureOption.Always,           // enforce encryption
                                                                        // share dataprotection keys
                    TicketDataFormat = new AspNetTicketDataFormat(new DataProtectorShim( dataProtector)),
                    CookieManager = new ChunkingCookieManager()         // add Microsoft.Owin.Security.Interop.ChunkingCookieManager 
                                                                        // since ASP.NET Core uses this new Manager
            });

            AreaRegistration.RegisterAllAreas();
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

        }
    }
}