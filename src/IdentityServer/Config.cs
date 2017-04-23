using IdentityModel;
using IdentityServer4.Models;
using IdentityServer4.Test;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace IdentityServer
{
    public class Config
    {
        public static IEnumerable<ApiResource> GetApiResources()
        {
            return new List<ApiResource>
                {
                    new ApiResource("dnc2017", "DNC2017 API", new [] { JwtClaimTypes.Name } )
                };
        }

        public static IEnumerable<IdentityResource> GetIdentityResources()
        {
            return new List<IdentityResource>
                            {
                                new IdentityResources.OpenId(),
                                new IdentityResources.Profile(),
                            };
        }

        public static IEnumerable<Client> GetClients()
        {
            return new List<Client>
                        {
                            new Client
                            {
                                ClientId = "client",

                                AllowedGrantTypes = GrantTypes.HybridAndClientCredentials,
                                ClientSecrets = new [] { new Secret("secret".Sha256()) },

                                // scopes that client has access to
                                AllowedScopes = {
                                    IdentityServer4.IdentityServerConstants.StandardScopes.OpenId,
                                    IdentityServer4.IdentityServerConstants.StandardScopes.Profile,
                                    "dnc2017"
                                },

                                RedirectUris =
                                {
                                    "http://localhost/dncAspNet/signin-oidc",
                                    "http://localhost/dncAspNetCore/signin-oidc",
                                    Environment.ExpandEnvironmentVariables("http://%COMPUTERNAME%/dncNetAsp/signin-oidc"),
                                    Environment.ExpandEnvironmentVariables("http://%COMPUTERNAME%/dncNetAspCore/signin-oidc"),
                                },
                                RequireConsent = false,
                                AllowOfflineAccess = true,
                                AllowAccessTokensViaBrowser = true,
                                AlwaysIncludeUserClaimsInIdToken = true
                            }
                        };
        }

        public static List<TestUser> GetUsers()
        {
            return new List<TestUser>
                        {
                            new TestUser
                            {
                                SubjectId = "1",
                                Username = "alice",
                                Password = "password"
                            },
                            new TestUser
                            {
                                SubjectId = "2",
                                Username = "bob",
                                Password = "password"
                            }
                        };
        }
    }
}
