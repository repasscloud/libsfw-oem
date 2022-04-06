<# PRELOAD - DO NOT EDIT #>
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
[System.String]$RootDir = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$ErrorActionPreference = 'Stop'

<# LOAD FUNCTIONS #>
. $RootDir\scripts\Tools\Complete-UrlVTScan.ps1

<# WINDOWS 10 DELL LATITUDE DRIVERS #>
$adr = (Invoke-WebRequest -Uri 'https://www.dell.com/support/kbdoc/en-au/000109893/dell-command-deploy-driver-packs-for-latitude-models' -UserAgent $userAgent -UseBasicParsing).Links
$url_list = ((($adr | Where-Object -FilterScript {$_.href -match '^.*https://www.dell.com/support/kbdoc/.*latitude-.*-windows-10-driver-pack.*$'}).outerHtml -replace '.*(https://www.dell.com/support/kbdoc/*./latitude-*.windows-10-driver-pack).*','$1') -replace '<a href="','') -replace '" target="_blank">Click Here</a>',''

<# MAIN LATITUDE DRIVERS LOOP #>
foreach ($uri in $url_list)
{    
    <# CREATE DIRECTORY FOR DOWNLOAD #>
    [System.String]$dp = ($uri -replace '^.*[0-9]{5}/','')
    [System.String]$directory = $dp -replace '-windows-10.*$',''
    New-Item -Path "${RootDir}\Dell\Latitude\win10" -ItemType Directory -Name $directory -Force -Confirm:$false | Out-Null

    <# DETERMINE URI #>
    try
    {
        (Invoke-WebRequest -Uri "${uri}" -UserAgent $userAgent -UseBasicParsing).Links | Out-Null
    }
    catch
    {
        $uri = $_.Exception.Response.Headers.Location.AbsoluteUri
    }

    [System.String]$cabfile = ((Invoke-WebRequest -Uri "${uri}" -UserAgent $userAgent -UseBasicParsing).Links | Where-Object -FilterScript {$_.href -match '^http.*-win10-.*\.CAB'} | Select-Object -First 1 | Select-Object -ExpandProperty outerHTML) -replace '.*(http.*\.CAB).*','$1'
    [System.String]$outFile = "${RootDir}\Dell\Latitude\win10\${directory}\$(Split-Path -Path $cabfile.Replace('%20',' ') -Leaf)"
    
    <# PERFORM SECURITY SCAN #>
    [System.String[]]$scanResults = Complete-UrlVTScan -Uri $cabfile -ApiKey $env:API_KEY
    $scanResults[0]
    $scanResults[1]
    $scanResults[2]
    $scanResults[3]
    $scanResults[4]

    <# DOWNLOAD FILE #>
    try
    {
        Invoke-WebRequest -Uri $cabfile -UseBasicParsing -UserAgent $userAgent -ContentType 'application/zip' -OutFile $outFile -ErrorAction Stop
        
        <# VERIFY DOWNLOAD #>
        if (Test-Path -Path $outFile)
        {
            Remove-Item -Path $outFile -Confirm:$false -Force
        }
    }
    catch
    {
        Write-Output "Unable to download file: ${uri}"
    }

    <# VT API RATE LIMIT #>
    Start-Sleep -Seconds 25
}

