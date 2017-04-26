#Requires -RunAsAdministrator
Import-Module WebAdministration

$idsAppPoolName = "DNCIdentityServerAppPool"
$aspNetAppPoolName = "DNCAspNetWebSiteAppPool"
$aspNetCoreAppPoolName = "DNCAspNetCoreWebSiteAppPool"

$idsAppName = "DNCIds"
$aspNetAppName = "DNCAspNet"
$aspNetCoreAppName = "DNCAspNetCore"

$webSite = "Default Web Site"
$directoryPath = "C:\inetpub\dnc2017"

$webApps = @($idsAppName, $aspNetAppName, $aspNetCoreAppName)
foreach ($webApp in $webApps )
{
	if (Test-Path IIS:\Sites\$webSite\$webApp -pathType container)
	{
		Write-Host "Removing web application $webApp"
		Remove-WebApplication -Name $webApp -Site $webSite
	}
}

$appPools = @( $idsAppPoolName, $aspNetAppPoolName, $aspNetCoreAppPoolName)
foreach ($appPool in $appPools )
{
	if (Test-Path IIS:\AppPools\$appPool  -pathType container)
	{
		Write-Host "Removing application pool $appPool"
		Remove-WebAppPool -Name $appPool
	}
}

if ( Test-Path $directoryPath)
{
	Write-Host "Removing directory $directoryPath"
	Remove-Item $directoryPath -Recurse -Force 
}