#Requires -RunAsAdministrator

<#
.SYNOPSIS
    installs the dotnet cologne sample app on local IIS
.DESCRIPTION
	creates a web site: DNC2017 
    creates applications pool : ( DNCIdentityServerAppPool, DNCAspNetWebSiteAppPool, DNCAspNetCoreWebSiteAppPool )
	creates web application in website DNC2017: (DNCIds, DNCAspNet, DNCAspNetCore)
	creates a certificate with friendly name : DNC2017 localhost testcertificate
	installs this certificate in /localmachine/my and localmachine/root 
	configures https binding for localhost on website 2017
	deploys all projects to "C:\inetpub\dnc2017"
    
.NOTES
    requires IIS installed
    Author         : Ralf Karle
#>

Import-Module WebAdministration

Set-StrictMode -Version 'Latest'


cd Cert:\LocalMachine\My
$computerName = [System.Environment]::MachineName

$idsAppPoolName = "DNCIdentityServerAppPool"
$aspNetAppPoolName = "DNCAspNetWebSiteAppPool"
$aspNetCoreAppPoolName = "DNCAspNetCoreWebSiteAppPool"

$idsAppName = "DNCIds"
$aspNetAppName = "DNCAspNet"
$aspNetCoreAppName = "DNCAspNetCore"

$webSite = "DNC2017"
$directoryPath = "C:\inetpub\dnc2017"

#navigate to the app pools root
Push-Location
cd IIS:\AppPools\


if (!(Test-Path $idsAppPoolName  -pathType container))
{
	Write-Host "Creating app pool $idsAppPoolName"
    $appPool = New-Item $idsAppPoolName 
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value ""
    Set-ItemProperty IIS:\AppPools\$idsAppPoolName -name processModel.identityType -value 1
}

if (!(Test-Path $aspNetAppPoolName -pathType container))
{
    Write-Host "Creating app pool $aspNetAppPoolName"
    $appPool = New-Item $aspNetAppPoolName
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value "v4.0"
}

if (!(Test-Path $aspNetCoreAppPoolName -pathType container))
{
    Write-Host "Creating app pool $aspNetCoreAppPoolName"
    $appPool = New-Item $aspNetCoreAppPoolName
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value ""
}

Pop-Location

# create webSite
cd IIS:\Sites

if ( -not (Test-Path $webSite -PathType Container ) )
{
	Write-Host "Creating website $webSite"
    New-Item $webSite -bindings @{protocol="https";bindingInformation=":443:" } -physicalPath $directoryPath
}
Pop-Location

#navigate to the sites root
cd IIS:\Sites\$webSite

if (-not (Test-Path $idsAppName -pathType container))
{
	Write-Host "Creating web application $idsAppName"
	$dir = Join-Path $directoryPath $idsAppName
	New-Item -Path $dir -ItemType Directory
	New-WebApplication -Name $idsAppName -ApplicationPool $idsAppPoolName -physicalPath $dir -Site $webSite
}
else
{
	Restart-WebAppPool -Name $idsAppPoolName
}

if (-not (Test-Path $aspNetAppName -pathType container))
{
	Write-Host "Creating web application $aspNetAppName"

	$dir = Join-Path $directoryPath $aspNetAppName
	New-Item -Path $dir -ItemType Directory
	New-WebApplication -Name $aspNetAppName -ApplicationPool $aspNetAppPoolName -physicalPath $dir -Site $webSite
}
else
{
	Restart-WebAppPool -Name $aspNetAppPoolName
}

if (-not (Test-Path $aspNetCoreAppName -pathType container))
{
	Write-Host "Creating web application $aspNetCoreAppName"

	$dir = Join-Path $directoryPath $aspNetCoreAppName
	New-Item -Path $dir -ItemType Directory
	New-WebApplication -Name $aspNetCoreAppName -ApplicationPool $aspNetCoreAppPoolName -physicalPath $dir -Site $webSite
}
else
{
	Restart-WebAppPool -Name $aspNetCoreAppPoolName 
}

# publish the project
$msbuild = "C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin\msbuild.exe"
$solutionDir = $PSScriptRoot

$project = join-path $solutionDir "AspNetCoreWebSite\AspNetCoreWebSite.csproj"
Write-Host "Deploying $project"
& $msbuild "$project" /p:DeployOnBuild=true /p:PublishProfile=FolderProfile

$project = join-path $solutionDir "AspNetWebSite\AspNetWebSite.csproj"
Write-Host "Deploying $project"
& $msbuild "$project" /p:DeployOnBuild=true /p:PublishProfile=FolderProfile

$project = join-path $solutionDir "IdentityServer\IdentityServer.csproj"
Write-Host "Deploying $project"
& $msbuild "$project" /p:DeployOnBuild=true /p:PublishProfile=FolderProfile

# create the certificates
$SourceStoreScope = 'LocalMachine'
$SourceStorename = 'My'
$friendlyName = "DNC2017 localhost testcertificate"

$SourceStore = New-Object  -TypeName System.Security.Cryptography.X509Certificates.X509Store  -ArgumentList $SourceStorename, $SourceStoreScope
$SourceStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)

$cert = $SourceStore.Certificates | Where-Object { $_.FriendlyName -like $friendlyName }

if ( -not $cert)
{
	Write-Host "Creating certificate with friendlyname '$friendlyName' in \LocalMachine\My"
    $cert = new-selfsignedcertificate -DnsName localhost -CertStoreLocation Cert:\LocalMachine\My -FriendlyName "$friendlyName"
}

$DestStoreScope = 'LocalMachine'
$DestStoreName = 'Root'

$DestStore = New-Object  -TypeName System.Security.Cryptography.X509Certificates.X509Store  -ArgumentList $DestStoreName, $DestStoreScope
$DestStore.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
$destCert = $DestStore.Certificates | Where-Object { $_.FriendlyName -like $friendlyName }
if ( -not $destCert )
{
	Write-Host "Copying certificate to in \LocalMachine\root"
    $DestStore.Add($cert)
}

$SourceStore.Close()
$DestStore.Close()

Write-Host "Add Certificate to https binding"
cd IIS:\SslBindings
$binding = Get-WebBinding $webSite
$binding.AddSslCertificate( $cert.GetCertHashString(), "my")
Pop-Location

