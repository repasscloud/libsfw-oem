<# PRELOAD - DO NOT EDIT #>
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
[System.String]$RootDir = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$ErrorActionPreference = 'Stop'

<# LOAD FUNCTIONS #>
#. $RootDir\scripts\Tools\Complete-UrlVTScan.ps1

<# WINDOWS 10 DELL LATITUDE DRIVERS #>
$adr = (Invoke-WebRequest -Uri 'https://www.dell.com/support/kbdoc/en-au/000109893/dell-command-deploy-driver-packs-for-latitude-models' -UserAgent $userAgent -UseBasicParsing).Links
$url_list = ($adr | Where-Object -FilterScript {$_.href -match '^.*10-driver-pack'}).outerHTML -replace '.*(http.*-driver-pack).*','$1'

foreach ($url in $url_list)
{
    $cabfile = ((((Invoke-WebRequest -Uri $url -UserAgent $userAgent -UseBasicParsing).Links | Where-Object -FilterScript {$_ -match '.*Download Now.*'}).outerHTML | Select-Object -First 1) -replace '^.*href="','') -replace '".*',''
    $cabfile
}



$uri = 'https://www.dell.com/support/kbdoc/en-us/000182132/latitude-5520-windows-10-driver-pack'
try
{
    (Invoke-WebRequest -Uri 'https://www.dell.com/support/kbdoc/en-us/000182132/latitude-5520-windows-10-driver-pack' -UserAgent $userAgent -UseBasicParsing).Links | Out-Null
}
catch
{
    $uri = $_.Exception.Response.Headers.Location.AbsoluteUri
}
$uri

Invoke-WebRequest -Uri 