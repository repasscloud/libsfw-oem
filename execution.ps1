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


$outFile = "${PSScriptRoot}\test-download.dl"
[System.String]$cabfile = (((($iwrObject.Links | Where-Object -FilterScript {$_ -match '.*Download Now.*'}).outerHTML | Select-Object -First 1) -replace '^.*href="','') -replace '".*','') # -replace '%20',''
Invoke-WebRequest -Uri $cabfile -UseBasicParsing -UserAgent $userAgent -ContentType 'application/zip' -OutFile $outFile -ErrorAction Stop