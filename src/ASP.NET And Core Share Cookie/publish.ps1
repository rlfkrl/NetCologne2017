#Requires -RunAsAdministrator
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
    $appPool = New-Item $idsAppPoolName 
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value ""
    Set-ItemProperty IIS:\AppPools\$idsAppPoolName -name processModel.identityType -value 1
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

Pop-Location

# create webSite
cd IIS:\Sites

if ( -not (Test-Path $webSite -PathType Container ) )
{
    New-Item $webSite -bindings @{protocol="https";bindingInformation=":443:" + $webSite} -physicalPath $directoryPath
}
Pop-Location

cd IIS:\SslBindings
$binding = Get-WebBinding $webSite
$cert = New-SelfSignedCertificate -DnsName "localhost" -CertStoreLocation Cert:\LocalMachine\My  
$cert | NetItem 0.0.0.0!443
Pop-Location

#navigate to the sites root
cd IIS:\Sites\$webSite

if (-not (Test-Path $idsAppName -pathType container))
{
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
 & $msbuild "$project" /p:DeployOnBuild=true /p:PublishProfile=FolderProfile

 $project = join-path $solutionDir "AspNetWebSite\AspNetWebSite.csproj"
 & $msbuild "$project" /p:DeployOnBuild=true /p:PublishProfile=FolderProfile

 $project = join-path $solutionDir "IdentityServer\IdentityServer.csproj"
 & $msbuild "$project" /p:DeployOnBuild=true /p:PublishProfile=FolderProfile


 # new-selfsignedcertificate -DnsName localhost -CertStoreLocation Cert:\LocalMachine\My
 # copy the new created certificate to "vertauenswürdige"...
 # bind cert to binding