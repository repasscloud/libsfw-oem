# <# PRELOAD - DO NOT EDIT #>
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
# $userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer
# [System.String]$RootDir = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
# $ErrorActionPreference = 'Stop'

# <# LOAD FUNCTIONS #>
# . $RootDir\scripts\Tools\Complete-UrlVTScan.ps1

# <# WINDOWS 10 DELL LATITUDE DRIVERS #>
# $adr = (Invoke-WebRequest -Uri 'https://www.dell.com/support/kbdoc/en-au/000109893/dell-command-deploy-driver-packs-for-latitude-models' -UserAgent $userAgent -UseBasicParsing).Links
# $url_list = ($adr | Where-Object -FilterScript {$_.href -match '^.*10-driver-pack'}).outerHTML -replace '.*(http.*-driver-pack).*','$1'

# <# MAIN LATITUDE DRIVERS LOOP #>
# foreach ($url in $url_list)
# {
#     <# DETERMINE URI #>
#     try
#     {
#         (Invoke-WebRequest -Uri "${url}" -UserAgent $userAgent -UseBasicParsing).Links | Out-Null
#     }
#     catch
#     {
#         $url = $_.Exception.Response.Headers.Location.AbsoluteUri
#     }
    
#     [System.String]$cabfile = ((((Invoke-WebRequest -Uri $url -UserAgent $userAgent -UseBasicParsing).Links | Where-Object -FilterScript {$_ -match '.*Download Now.*'}).outerHTML | Select-Object -First 1) -replace '^.*href="','') -replace '".*',''
#     [System.String]$outfile = "${RootDir}\Dell\Latitude\${directory}\win10\$(Split-Path -Path $cabfile.Replace('%20',' ') -Leaf)"
#     #[System.String]$DriverVersion = ($cabfile -replace '^http.*\/.*-*([A-Za-z]+)10-','') -replace '-.*',''
#     [System.String]$DriverVersion = $cabfile.Split('-')[$cabfile.Split('-').Length-1]
#     $url
#     $cabfile
#     $outfile
#     $DriverVersion
# }


# # <# MAIN LATITUDE DRIVERS LOOP #>
# # foreach ($uri in $url_list)
# # {    
# #     <# CREATE DIRECTORY FOR DOWNLOAD #>
# #     [System.String]$dp = ($uri -replace '^.*[0-9]{5}/','')
# #     [System.String]$directory = $dp -replace '-windows-10.*$',''
# #     New-Item -Path "${RootDir}\Dell\Latitude\win10" -ItemType Directory -Name $directory -Force -Confirm:$false | Out-Null

# #     <# DETERMINE URI #>
# #     try
# #     {
# #         (Invoke-WebRequest -Uri "${uri}" -UserAgent $userAgent -UseBasicParsing).Links | Out-Null
# #     }
# #     catch
# #     {
# #         $uri = $_.Exception.Response.Headers.Location.AbsoluteUri
# #     }

# #     [System.String]$cabfile = ((Invoke-WebRequest -Uri "${uri}" -UserAgent $userAgent -UseBasicParsing).Links | Where-Object -FilterScript {$_.href -match '^http.*-win10-.*\.CAB'} | Select-Object -First 1 | Select-Object -ExpandProperty outerHTML) -replace '.*(http.*\.CAB).*','$1'
# #     [System.String]$outFile = "${RootDir}\Dell\Latitude\win10\${directory}\$(Split-Path -Path $cabfile.Replace('%20',' ') -Leaf)"
    
# #     [System.String]$DriverVersion = ($cabfile -replace '^http.*\/.*-*([A-Za-z]+)10-','') -replace '-.*',''

# #     $cabfile

# #     [System.String]$DriverVersion = ($cabfile -replace '^http.*\/.*-*([A-Za-z]+)10-','') -replace '-.*',''
# #     [System.String]$SupportedModel = ($cabfile -replace 'http.*/','')

# #     <# PERFORM SECURITY SCAN #>
# #     # [System.String[]]$scanResults = Complete-UrlVTScan -Uri $cabfile -ApiKey $env:API_KEY
# #     # $UriScanId = $scanResults[0]
# #     # $suspiciousCount = $scanResults[1]
# #     # $undetectedCount = $scanResults[2]
# #     # $timeoutCount = $scanResults[3]
# #     # $harmlessCount = $scanResults[4]
# #     # $maliciousCount = $scanResults[5]

# #     # <# DOWNLOAD FILE #>
# #     # try
# #     # {
# #     #     Invoke-WebRequest -Uri $cabfile -UseBasicParsing -UserAgent $userAgent -ContentType 'application/zip' -OutFile $outFile -ErrorAction Stop
        
# #     #     <# VERIFY DOWNLOAD #>
# #     #     if (Test-Path -Path $outFile)
# #     #     {
# #     #         Remove-Item -Path $outFile -Confirm:$false -Force
# #     #     }
# #     # }
# #     # catch
# #     # {
# #     #     Write-Output "Unable to download file: ${uri}"
# #     # }

# #     # <# VT API RATE LIMIT #>
# #     # Start-Sleep -Seconds 25
# # }














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

function Get-WebRequestTable()
{
    param(
        [Parameter(Mandatory = $true)]
        [Microsoft.PowerShell.Commands.HtmlWebResponseObject] $WebRequest,
    
        [Parameter(Mandatory = $true)]
        [int] $TableNumber
    )

    ## Extract the tables out of the web request
    $tables = @($WebRequest.ParsedHtml.getElementsByTagName("TABLE"))
    $table = $tables[$TableNumber]
    $titles = @()
    $rows = @($table.Rows)

    ## Go through all of the rows in the table
    foreach($row in $rows)
    {
        $cells = @($row.Cells)
    
        ## If we've found a table header, remember its titles
        if($cells[0].tagName -eq "TH")
        {
            $titles = @($cells | % { ("" + $_.InnerText).Trim() })
            continue
        }

        ## If we haven't found any table headers, make up names "P1", "P2", etc.
        if(-not $titles)
        {
            $titles = @(1..($cells.Count + 2) | % { "P$_" })
        }

        ## Now go through the cells in the the row. For each, try to find the
        ## title that represents that column and create a hashtable mapping those
        ## titles to content
        $resultObject = [Ordered] @{}
        for($counter = 0; $counter -lt $cells.Count; $counter++)
        {
            $title = $titles[$counter]
            if(-not $title) { continue }  

            $resultObject[$title] = ("" + $cells[$counter].InnerText).Trim()
        }

        ## And finally cast that hashtable to a PSCustomObject
        [PSCustomObject] $resultObject
    }
}




$r = Invoke-WebRequest -Uri 'https://www.dell.com/support/kbdoc/000130131/latitude-5480-windows-10-driver-pack' -UserAgent $userAgent -UseBasicParsing

Get-WebRequestTable $r -TableNumber 0 | Format-Table Auto