#Requires -RunAsAdministrator
Import-Module WebAdministration

Set-StrictMode -Version 'Latest'

$idsAppPoolName = "DNCIdentityServerAppPool"
$aspNetAppPoolName = "DNCAspNetWebSiteAppPool"
$aspNetCoreAppPoolName = "DNCAspNetCoreWebSiteAppPool"

$idsAppName = "DNCIds"
$aspNetAppName = "DNCAspNet"
$aspNetCoreAppName = "DNCAspNetCore"

$webSite = "Default Web Site"
$directoryPath = "C:\inetpub\dnc2017"

#navigate to the app pools root
cd IIS:\AppPools\


if (!(Test-Path $idsAppPoolName  -pathType container))
{
    $appPool = New-Item $idsAppPoolName 
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value ""
	$appPool.ProcessModel.IdentityType = 'LocalSystem'
}

if (!(Test-Path $aspNetAppPoolName -pathType container))
{
    #create the app pool
    $appPool = New-Item $aspNetAppPoolName
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value "v4.0"
}

if (!(Test-Path $aspNetCoreAppPoolName -pathType container))
{
    #create the app pool
    $appPool = New-Item $aspNetCoreAppPoolName
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value ""
}

#navigate to the sites root
cd IIS:\Sites\$webSite

if (-not (Test-Path $idsAppName -pathType container))
{
	$dir = Join-Path $directoryPath $idsAppName
	New-Item -Path $dir -ItemType Directory
	New-WebApplication -Name $idsAppName -ApplicationPool $idsAppPoolName -physicalPath $dir -Site $webSite
}

if (-not (Test-Path $aspNetAppName -pathType container))
{
	$dir = Join-Path $directoryPath $aspNetAppName
	New-Item -Path $dir -ItemType Directory
	New-WebApplication -Name $aspNetAppName -ApplicationPool $aspNetAppPoolName -physicalPath $dir -Site $webSite
}

if (-not (Test-Path $aspNetCoreAppName -pathType container))
{
	$dir = Join-Path $directoryPath $aspNetCoreAppName
	New-Item -Path $dir -ItemType Directory
	New-WebApplication -Name $aspNetCoreAppName -ApplicationPool $aspNetCoreAppPoolName -physicalPath $dir -Site $webSite
}

