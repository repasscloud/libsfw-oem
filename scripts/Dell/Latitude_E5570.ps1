<# PRELOAD - DO NOT EDIT #>
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
[System.String]$RootDir = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$ErrorActionPreference = 'Stop'
[System.String]$BaseUri = $env:BASE_URI
[System.String]$oem = "Dell"
[System.String]$notes = "Latitude E5570 is created independantly of main Latitude script."
[System.String]$winver = "Windows_10"
[System.String]$biosVersion = [System.String]::Empty
[System.Int32]$productionYear = 1900

<# LOAD FUNCTIONS #>
. $RootDir\scripts\Tools\Complete-UrlVTScan.ps1

<# SET VARIABLES #>
[System.String]$manufacturer = "Dell"
[System.String]$make = "Latitude"
[System.String]$oeminstallclass = "Dell_cabfile"
[System.String]$cspversion = [System.String]::Empty
[System.String]$cspname = [System.String]::Empty

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
    Invoke-WebRequest -Uri $uri -UseBasicParsing -UserAgent $userAgent -ContentType 'application/zip' -OutFile $outfile
}

<# PERFORM SECURITY SCAN #>
[System.String[]]$scanResults = Complete-UrlVTScan -Uri $cabfile -ApiKey $env:API_KEY
$UriScanId = $scanResults[0]
$suspiciousCount = $scanResults[1]
$undetectedCount = $scanResults[2]
$timeoutCount = $scanResults[3]
$harmlessCount = $scanResults[4]
$maliciousCount = $scanResults[5]

<# VT API RATE LIMIT #>
Start-Sleep -Seconds 21

<# EXPAND CAB #>
$parentpath = Split-Path -Path $outfile -Parent
Push-Location
Set-Location -Path $parentpath
expand $outfile -F:* .

<# VERIFY DRIVER VERSIONS #>
[System.String[]]$cpuArch = @()
[System.Boolean]$x64 = $false
[System.Boolean]$x86 = $false
[System.Boolean]$arm64 = $false
[System.Boolean]$aarch32 = $false
if (Test-Path -Path .\E5570\win10\x64)
{
    [System.Boolean]$x64 = $true
    $cpuArch += "x64"
}
if (Test-Path -Path .\E5570\win10\x86)
{
    [System.Boolean]$x86 = $true
    $cpuArch += "x64"
}
if (Test-Path -Path .\E5570\win10\arm64)
{
    [System.Boolean]$arm64 = $true
    $cpuArch += "arm64"
}
if (Test-Path -Path .\E5570\win10\aarch32)
{
    [System.Boolean]$aarch32 = $true
    $cpuArch += "aarch32"
}


<# DATA PAYLOAD #>
# Write-Output "[UUID]:           $([System.Guid]::NewGuid().Guid)"
# Write-Output "[UID]:            ${manufacturer}::${make}::${model}::${arch}::${driverversion}"
# Write-Output "[MANUFACTURER]:   ${manufacturer}"
# Write-Output "[MAKE]:           ${make}"
# Write-Output "[MODEL]:          $($model.Replace('Latitude ',''))"
# Write-Output "[CSP VERSION]:    ${cspversion}"
# Write-Output "[CSP NAME]:       ${cspname}"
# Write-Output "[DRIVER VERSION]: ${driverversion}"
# Write-Output "[OEM INSTALLER]:  ${oeminstallclass}"
# Write-Output "[X64 SUPPORT]:    ${x64}"
# Write-Output "[X86 SUPPORT]:    ${x86}"
# Write-Output "[CAB FILE]:       ${cabfile}"
# Write-Output "[OUT FILE]:       ${outfile}"
# Write-Output "[LATEST]:         $($true)"
# Write-Output "[LAST UPDATE]:    $((Get-Date).ToString('yyyyMMdd'))"
# Write-Output "[SCAN ID]:        ${UriScanId}"
# Write-Output "[SUSPICIOUS]:     ${suspiciousCount}"
# Write-Output "[UNDETECTED]:     ${undetectedCount}"
# Write-Output "[TIMEOUT]:        ${timeoutCount}"
# Write-Output "[HARMLESS]:       ${harmlessCount}"
# Write-Output "[MALICIOUS]:      ${maliciousCount}"

<# POST DATA TO API #>
$Body = @{
    'id' = 0
    'uuid' = [System.Guid]::NewGuid().Guid.ToString()
    'uid' = "${manufacturer}::${make}::${model}::${arch}::${driverversion}"
    'originalEquipmentManufacturer' = "${oem}"
    'make' = "${make}"
    'model' = "$($model.Replace('Latitude ',''))"
    'cspVersion' = "${cspversion}"
    'cspName' = "${cspname}"
    'version' = "${driverversion}"
    'biosVersion' = "${biosVersion}"
    'productionYear' = $productionYear
    'cpuArch' = $cpuArch
    'oeminstallClass' = "${oeminstallclass}"
    'x64' = $x64
    'x86' = $x86
    'arm64' = $arm64
    'aarch32' = $aarch32
    'uri' = "${cabfile}"
    'outFile' = "$(Split-Path -Path $outfile -Leaf)"
    'latest' = $true
    'lastUpdate' = $((Get-Date).ToString('yyyyMMdd'))
    'driverWinVer' = $winver
    'urlVTScan' = $UriScanId
    'exploitReportId' = 1
    'notes' = "${notes}"
} | ConvertTo-Json
try {
    Invoke-RestMethod -Uri "https://engine.api.dev.optechx-data.com/v1/Drivers" -Method Post -UseBasicParsing -Body $Body -ContentType "application/json" -ErrorAction Stop
}
catch {
    $_.Exception.Message
}

<# CLEAN UP #>
Pop-Location
[System.GC]::Collect()
