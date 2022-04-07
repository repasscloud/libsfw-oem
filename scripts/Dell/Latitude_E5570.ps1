<# PRELOAD - DO NOT EDIT #>
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
[System.String]$RootDir = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$ErrorActionPreference = 'Stop'

<# LOAD FUNCTIONS #>
. $RootDir\scripts\Tools\Complete-UrlVTScan.ps1

<# LATITUDE E5570 WINDOWS 10 DRIVERS #>
$iwrObject = Invoke-WebRequest -Uri 'https://www.dell.com/support/kbdoc/en-au/000108641/latitude-e5570-windows-10-driver-pack' -UserAgent $userAgent -UseBasicParsing

<# DEFINE CAB FILE #>
$cabfile = $iwrObject.Links | Where-Object -FilterScript {$_.href -match '.*\.cab'} | Select-Object -ExpandProperty href

<# IDENTIFY DRIVER VERSION #>
[System.String]$driverversion = $cabfile.Split('-')[$cabfile.Split('-').Length-2]
[System.String]$model = 'Latitude E5570'

<# CREATE DIRECTORY FOR DOWNLOAD #>
New-Item -Path "${RootDir}\Dell\Latitude\${model}\win10" -ItemType Directory -Name $model -Force -Confirm:$false | Out-Null

<# REMOVE HTML FORMATTING FROM DOWNLOAD FILE STRING #>
[System.String]$outfile = "${RootDir}\Dell\Latitude\${model}\win10\$(Split-Path -Path $cabfile.Replace('%20',' ') -Leaf)"

<# DOWNLOAD FILE #>
try
{
    Invoke-WebRequest -Uri $cabfile -UseBasicParsing -UserAgent $userAgent -ContentType 'application/zip' -OutFile $outfile -ErrorAction Stop
}
catch
{
    $uri = $_.Exception.Response.Headers.Location.AbsoluteUri
    $uri
    Invoke-WebRequest -Uri $uri -UseBasicParsing -UserAgent $userAgent -ContentType 'application/zip' -OutFile $outfile
}

<# PERFORM SECURITY SCAN #>
#[System.String[]]$scanResults = Complete-UrlVTScan -Uri $cabfile -ApiKey $env:API_KEY
# $UriScanId = $scanResults[0]
# $suspiciousCount = $scanResults[1]
# $undetectedCount = $scanResults[2]
# $timeoutCount = $scanResults[3]
# $harmlessCount = $scanResults[4]
# $maliciousCount = $scanResults[5]

<# VT API RATE LIMIT #>
Start-Sleep -Seconds 21

<# DATA PAYLOAD #>
Write-Output "[CAB FILE]:       ${cabfile}"
Write-Output "[OUT FILE]:       ${outfile}"
Write-Output "[DRIVER VERSION]: ${DriverVersion}"
Write-Output "[MODEL]:          ${model}"
Write-Output "[SCAN ID]:        ${UriScanId}"
Write-Output "[SUSPICIOUS]:     ${suspiciousCount}"
Write-Output "[UNDETECTED]:     ${undetectedCount}"
Write-Output "[TIMEOUT]:        ${timeoutCount}"
Write-Output "[HARMLESS]:       ${harmlessCount}"
Write-Output "[MALICIOUS]:      ${maliciousCount}"

<# EXPAND CAB #>
$parentpath = Split-Path -Path $outfile -Parent
Start-Process -FilePath expand -ArgumentList "${$outfile}","-F:*","${parentpath}" -Wait
Get-ChildItem -Path "${parentpath}\Latitude E5570"
Get-ChildItem -Path $parentpath -Depth 3