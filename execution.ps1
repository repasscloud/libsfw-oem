<# PRELOAD - DO NOT EDIT #>
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
[System.String]$RootDir = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$ErrorActionPreference = 'Stop'

<# LOAD FUNCTIONS #>
#. $RootDir\scripts\Tools\Complete-UrlVTScan.ps1

<# WINDOWS 10 DELL LATITUDE DRIVERS #>
# $adr = (Invoke-WebRequest -Uri 'https://www.dell.com/support/kbdoc/en-au/000109893/dell-command-deploy-driver-packs-for-latitude-models' -UserAgent $userAgent -UseBasicParsing).Links
# $url_list = ($adr | Where-Object -FilterScript {$_.href -match '^.*10-driver-pack'}).outerHTML -replace '.*(http.*-driver-pack).*','$1'

# foreach ($url in $url_list)
# {
#     $cabfile = ((((Invoke-WebRequest -Uri $url -UserAgent $userAgent -UseBasicParsing).Links | Where-Object -FilterScript {$_ -match '.*Download Now.*'}).outerHTML | Select-Object -First 1) -replace '^.*href="','') -replace '".*',''
#     $cabfile
# }

#(Invoke-WebRequest -Uri 'https://www.dell.com/support/kbdoc/000130131/latitude-5480-windows-10-driver-pack' -UserAgent $userAgent -UseBasicParsing).Content | Where-Object -FilterScript {$_ -match '.*Latitude.*'}

# $r = Invoke-WebRequest -Uri 'https://www.dell.com/support/kbdoc/000130131/latitude-5480-windows-10-driver-pack' -UserAgent $userAgent -UseBasicParsing

Remove-Item -Path /Users/danijel-rpc/Projects/libsfw-oem/web.txt

(Invoke-WebRequest -Uri 'https://www.dell.com/support/kbdoc/000130131/latitude-5480-windows-10-driver-pack' -UserAgent $userAgent -UseBasicParsing | Select-Object -Property Content).content | Out-File /Users/danijel-rpc/Projects/libsfw-oem/web.txt

foreach($line in [System.IO.File]::ReadLines("/Users/danijel-rpc/Projects/libsfw-oem/web.txt"))
{
    # if ($line -cmatch '<title>Latitude.*')
    # {
    #     ($line -replace '<title>','') -replace ' Windows 10.*',''
    # }
    if ($line -cmatch '<td align="center" colspan="1" rowspan="1">Latitude')
    {
        ($line -replace '.*<td align="center" colspan="1" rowspan="1">','') -replace '<.*',''
    }
}

# foreach ($line in (Get-Content -Path /Users/danijel-rpc/Projects/libsfw-oem/web.txt))
# {
#     if ($line -match '<title>Latitude')
#     {
#         $line -replace '<title>Latitude.*<\/title>',''
#     }
# }





