# AspNetCoreWebSite
* Add Nuget-Packages:
	* Microsoft.AspNetCore.DataProtection.Extensions
* Startup.cs
	* Add : 
	```C# 
	DataProtectionProvider = DataProtectionProvider.Create(new DirectoryInfo(@"c:\shared-auth-ticket-keys\"))
	```

# AspNetWebSite

* Add Nuget-Packages: 
	* Microsoft.Owin.Security.Interop
	* Microsoft.Owin.Security.DataProtection
* Startup.cs
	* in CookieAuthenticationOptions: 
		```C#
		CookieManager = new ChunkingCookieManager(),
				
		TicketDataFormat = new AspNetTicketDataFormat( 
			new DataProtectorShim(
				DataProtectionProvider.Create(new DirectoryInfo(@"c:\shared-auth-ticket-keys\"))
					.CreateProtector("Microsoft.AspNetCore.Authentication.Cookies.CookieAuthenticationMiddleware",
							"Cookies", 
							"v2"))
			),
		```
	
