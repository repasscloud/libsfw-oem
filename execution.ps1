<# PRELOAD - DO NOT EDIT #>
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
[System.String]$RootDir = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$ErrorActionPreference = 'Stop'

$uri = 'https://www.dell.com/support/kbdoc/000108641/latitude-e5570-windows-10-driver-pack'

try
{
    (Invoke-WebRequest -Uri "${uri}" -UserAgent $userAgent -UseBasicParsing).Links | Out-Null
    [System.String]$url = $uri
}
catch
{
    $uri = $_.Exception.Response.Headers.Location.AbsoluteUri
    [System.String]$url = $uri
}
$url

$iwrObject = Invoke-WebRequest -Uri $url -UserAgent $userAgent -UseBasicParsing



[System.String]$cabfile = (((($iwrObject.Links | Where-Object -FilterScript {$_ -match '.*Download Now.*'}).outerHTML | Select-Object -First 1) -replace '^.*href="','') -replace '".*','') # -replace '%20',''
$cabfile
#$cabfile -like 'https://downloads.dell.com/FOLDER08160654M/1/Latitude%207330%20Rugged%20Extreme-win10-A01-4259W.CAB'
#Invoke-WebRequest -Uri $cabfile -UseBasicParsing -UserAgent $userAgent -ContentType 'application/zip' -OutFile $outFile -ErrorAction Stop