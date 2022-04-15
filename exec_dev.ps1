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

<# MAIN LATITUDE DRIVERS LOOP #>
foreach ($uri in $url_list)
{
    if ($uri -match 'latitude-e5570-windows-10-driver-pack')
    {
        <# DETERMINE URL FROM URI #>
        try
        {
            (Invoke-WebRequest -Uri "${uri}" -UserAgent $userAgent -UseBasicParsing).Links | Out-Null
            [System.String]$url = $uri
        }
        catch
        {
            $uri = $_.Exception.Response.Headers.Location.AbsoluteUri
            [System.String]$url = $uri
            Write-Output "URI DETERMINE ERROR"
            Write-Output "The URI is: ${uri}"
            Write-Output "The URL is: ${url}"
        }


        <# CREATE WEB REQUEST OBJECT #>
        $iwrObject = Invoke-WebRequest -Uri $url -UserAgent $userAgent -UseBasicParsing

        <# FIND CABFILE DOWNLOAD URI #>
        [System.String]$cabfile = ((($iwrObject.Links | Where-Object -FilterScript {$_ -match '.*Download Now.*'}).outerHTML | Select-Object -First 1) -replace '^.*href="','') -replace '".*',''
        Write-Output "var `$cabfile is: ${cabfile}"

        <# IDENTIFY DRIVER VERSION #>
        [System.String]$DriverVersion = $cabfile.Split('-')[$cabfile.Split('-').Length-2]
        Write-Output "var `$DriverVersion is: ${DriverVersion}"

        <# IDENTIFY MODEL BIOS NAME #>
        if (Test-Path -Path $PSScriptRoot\web-text.txt){Remove-Item -Path $PSScriptRoot\web-text.txt -Confirm:$false -Force}
        ($iwrObject | Select-Object -Property Content).content | Out-File $PSScriptRoot\web-text.txt
        foreach($line in [System.IO.File]::ReadLines("${PSScriptRoot}\web-text.txt"))
        {
            if ($line -cmatch '<td align="center" colspan="1" rowspan="1">Latitude')
            {
                $model = ($line -replace '.*<td align="center" colspan="1" rowspan="1">','') -replace '<.*',''
                Write-Output "var `$model is: ${model}"
            }
        }

        <# SPECIFY DIRECTORY TO DOWNLOAD TO #>
        $directory = $model.Substring(9)
        Write-Output "var `$directory is: ${directory}"

        <# CREATE DIRECTORY FOR DOWNLOAD #>
        New-Item -Path "${RootDir}\Dell\Latitude\${directory}\win10" -ItemType Directory -Name $directory -Force -Confirm:$false | Out-Null

        <# REMOVE HTML FORMATTING FROM DOWNLOAD FILE STRING #>
        [System.String]$outfile = "${RootDir}\Dell\Latitude\${directory}\win10\$(Split-Path -Path $cabfile.Replace('%20',' ') -Leaf)"
        Write-Output "var `$outfile is: ${outfile}"

        <# DOWNLOAD FILE #>
        try
        {
            Invoke-WebRequest -Uri $cabfile -UseBasicParsing -UserAgent $userAgent -ContentType 'application/zip' -OutFile $outfile -ErrorAction Stop
        }
        catch
        {
            $dl_error_uri = $(Invoke-WebRequest -Uri $cabfile -UseBasicParsing -UserAgent $userAgent -ContentType 'application/zip' -OutFile $outfile).Exception.Response.Headers.Location.AbsoluteUri
            Write-Output "Error in Download: ${dl_error_uri}"
        }

        Test-Path -Path $outfile
    }
}