#Requires -RunAsAdministrator

<#
.SYNOPSIS
    removes all footprints the dotnet cologne sample app in local IIS
.DESCRIPTION
	removes web applications in website DNC2017: (DNCIds, DNCAspNet, DNCAspNetCore)
    removes applications pools : ( DNCIdentityServerAppPool, DNCAspNetWebSiteAppPool, DNCAspNetCoreWebSiteAppPool )
	removes a web site: DNC2017 
	removes the certificate with friendly name : "DNC2017 localhost testcertificate" from "/localmachine/my" and "localmachine/root"
	deletes folder "C:\inetpub\dnc2017"
    
.NOTES
    requires IIS installed
    Author         : Ralf Karle
#>

Import-Module WebAdministration

$idsAppPoolName = "DNCIdentityServerAppPool"
$aspNetAppPoolName = "DNCAspNetWebSiteAppPool"
$aspNetCoreAppPoolName = "DNCAspNetCoreWebSiteAppPool"

$idsAppName = "DNCIds"
$aspNetAppName = "DNCAspNet"
$aspNetCoreAppName = "DNCAspNetCore"

$webSite = "DNC2017"
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
        Stop-WebAppPool $appPool -ErrorAction SilentlyContinue
		Remove-WebAppPool -Name $appPool
	}
}

cd IIS:\Sites
if ( Test-Path $webSite -PathType Container )
{
    Write-Host "Removing website $webSite"
    Remove-Item $webSite -Recurse
}
Pop-Location


if ( Test-Path $directoryPath)
{
	Write-Host "Removing directory $directoryPath"
	Remove-Item $directoryPath -Recurse -Force 
}

# remove certificates
$friendlyName = "DNC2017 localhost testcertificate"

Set-Location -Path "cert:\LocalMachine\My"
$cert = Get-ChildItem | Where-Object { $_.FriendlyName -eq $friendlyName }
if ( $cert )
{
	Write-Host "Removing certificate from LocalMachine\My"
    $cert.PSPath | remove-item 
}

Set-Location -Path "cert:\LocalMachine\Root"
$cert = Get-ChildItem | Where-Object { $_.FriendlyName -eq $friendlyName }
if ( $cert )
{
	Write-Host "Removing certificate from LocalMachine\Root"
    $cert.PSPath | remove-item 
}
