using Microsoft.Owin;
using Microsoft.Owin.Diagnostics;
using Microsoft.Owin.Security;
using Microsoft.Owin.Security.Cookies;
using Microsoft.Owin.Security.OpenIdConnect;
using Owin;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Optimization;
using System.Web.Routing;

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

            app.SetDefaultSignInAsAuthenticationType(CookieAuthenticationDefaults.AuthenticationType);

            app.UseCookieAuthentication(
                new CookieAuthenticationOptions {
                    ExpireTimeSpan = TimeSpan.FromMinutes(60)
                });


            app.UseOpenIdConnectAuthentication(
                new OpenIdConnectAuthenticationOptions
                {
                    ClientId = "client",
                    ClientSecret = "secret",
                    Authority = "http://localhost/dncids",
                    RedirectUri = "http://localhost/dncAspNet/signin-oidc",

                    Scope = "openid profile",
                    ResponseType = "code id_token",
                    
                    TokenValidationParameters = new TokenValidationParameters { NameClaimType = "name" }
                    
                    
                });

            AreaRegistration.RegisterAllAreas();
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

        }
    }
}