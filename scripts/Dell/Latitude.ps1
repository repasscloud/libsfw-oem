<# PRELOAD - DO NOT EDIT #>
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
[System.String]$RootDir = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$ErrorActionPreference = 'Stop'

<# LOAD FUNCTIONS #>
. $RootDir\scripts\Tools\Complete-UrlVTScan.ps1

<# WINDOWS 10 DELL LATITUDE DRIVERS #>
$adr = (Invoke-WebRequest -Uri 'https://www.dell.com/support/kbdoc/en-au/000109893/dell-command-deploy-driver-packs-for-latitude-models' -UserAgent $userAgent -UseBasicParsing).Links
$url_list = ($adr | Where-Object -FilterScript {$_.href -match '^.*10-driver-pack'}).outerHTML -replace '.*(http.*-driver-pack).*','$1'

<# MAIN LATITUDE DRIVERS LOOP #>
foreach ($url in $url_list)
{
    <# DETERMINE URI #>
    try
    {
        (Invoke-WebRequest -Uri "${url}" -UserAgent $userAgent -UseBasicParsing).Links | Out-Null
    }
    catch
    {
        $url = $_.Exception.Response.Headers.Location.AbsoluteUri
    }
    
    $iwrObject = Invoke-WebRequest -Uri $url -UserAgent $userAgent -UseBasicParsing

    [System.String]$cabfile = ((($iwrObject.Links | Where-Object -FilterScript {$_ -match '.*Download Now.*'}).outerHTML | Select-Object -First 1) -replace '^.*href="','') -replace '".*',''
    [System.String]$outfile = "${RootDir}\Dell\Latitude\${directory}\win10\$(Split-Path -Path $cabfile.Replace('%20',' ') -Leaf)"
    #[System.String]$DriverVersion = ($cabfile -replace '^http.*\/.*-*([A-Za-z]+)10-','') -replace '-.*',''
    [System.String]$DriverVersion = $cabfile.Split('-')[$cabfile.Split('-').Length-1]
    if (Test-Path -Path $PSScriptRoot\web-text.txt){Remove-Item -Path $PSScriptRoot\web-text.txt -Confirm:$false -Force}
    ($iwrObject | Select-Object -Property Content).content | Out-File $PSScriptRoot\web-text.txt
    foreach($line in [System.IO.File]::ReadLines("${PSScriptRoot}\web-text.txt"))
    {
        if ($line -cmatch '<title>Latitude.*')
        {
            $model = ($line -replace '<title>','') -replace ' Windows 10.*',''
        }
    }




    $cabfile
    $outfile
    $DriverVersion
    $model
}


# <# MAIN LATITUDE DRIVERS LOOP #>
# foreach ($uri in $url_list)
# {    
#     <# CREATE DIRECTORY FOR DOWNLOAD #>
#     [System.String]$dp = ($uri -replace '^.*[0-9]{5}/','')
#     [System.String]$directory = $dp -replace '-windows-10.*$',''
#     New-Item -Path "${RootDir}\Dell\Latitude\win10" -ItemType Directory -Name $directory -Force -Confirm:$false | Out-Null

#     <# DETERMINE URI #>
#     try
#     {
#         (Invoke-WebRequest -Uri "${uri}" -UserAgent $userAgent -UseBasicParsing).Links | Out-Null
#     }
#     catch
#     {
#         $uri = $_.Exception.Response.Headers.Location.AbsoluteUri
#     }

#     [System.String]$cabfile = ((Invoke-WebRequest -Uri "${uri}" -UserAgent $userAgent -UseBasicParsing).Links | Where-Object -FilterScript {$_.href -match '^http.*-win10-.*\.CAB'} | Select-Object -First 1 | Select-Object -ExpandProperty outerHTML) -replace '.*(http.*\.CAB).*','$1'
#     [System.String]$outFile = "${RootDir}\Dell\Latitude\win10\${directory}\$(Split-Path -Path $cabfile.Replace('%20',' ') -Leaf)"
    
#     [System.String]$DriverVersion = ($cabfile -replace '^http.*\/.*-*([A-Za-z]+)10-','') -replace '-.*',''

#     $cabfile

#     [System.String]$DriverVersion = ($cabfile -replace '^http.*\/.*-*([A-Za-z]+)10-','') -replace '-.*',''
#     [System.String]$SupportedModel = ($cabfile -replace 'http.*/','')

#     <# PERFORM SECURITY SCAN #>
#     # [System.String[]]$scanResults = Complete-UrlVTScan -Uri $cabfile -ApiKey $env:API_KEY
#     # $UriScanId = $scanResults[0]
#     # $suspiciousCount = $scanResults[1]
#     # $undetectedCount = $scanResults[2]
#     # $timeoutCount = $scanResults[3]
#     # $harmlessCount = $scanResults[4]
#     # $maliciousCount = $scanResults[5]

#     # <# DOWNLOAD FILE #>
#     # try
#     # {
#     #     Invoke-WebRequest -Uri $cabfile -UseBasicParsing -UserAgent $userAgent -ContentType 'application/zip' -OutFile $outFile -ErrorAction Stop
        
#     #     <# VERIFY DOWNLOAD #>
#     #     if (Test-Path -Path $outFile)
#     #     {
#     #         Remove-Item -Path $outFile -Confirm:$false -Force
#     #     }
#     # }
#     # catch
#     # {
#     #     Write-Output "Unable to download file: ${uri}"
#     # }

#     # <# VT API RATE LIMIT #>
#     # Start-Sleep -Seconds 25
# }


