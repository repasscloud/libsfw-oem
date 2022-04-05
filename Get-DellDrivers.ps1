<# PRELOAD - DO NOT EDIT #>
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$userAgent = [Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer

<# WINDOWS 10 DELL LATITUDE DRIVERS #>
$adr = (Invoke-WebRequest -Uri 'https://www.dell.com/support/kbdoc/en-au/000109893/dell-command-deploy-driver-packs-for-latitude-models' -UserAgent $userAgent -UseBasicParsing).Links
$url_list = ((($adr | Where-Object -FilterScript {$_.href -match '^.*https://www.dell.com/support/kbdoc/.*latitude-.*-windows-10-driver-pack.*$'}).outerHtml -replace '.*(https://www.dell.com/support/kbdoc/*./latitude-*.windows-10-driver-pack).*','$1') -replace '<a href="','') -replace '" target="_blank">Click Here</a>',''

<# MAIN LATITUDE DRIVERS LOOP #>
foreach ($uri in $url_list)
{
    $uri
    <# CREATE DIRECTORY FOR DOWNLOAD #>
    [System.String]$dp = ($uri -replace '^.*[0-9]{5}/','')
    [System.String]$directory = $dp -replace '-windows-10.*$',''
    #New-Item -Path $PSScriptRoot\Dell\Latitude\win10 -ItemType Directory -Name $directory -Force -Confirm:$false

    <# DOWNLOAD CAB FILE #>
    [System.String]$cabfile = ((Invoke-WebRequest -Uri "${uri}" -UserAgent $userAgent -UseBasicParsing).Links | Where-Object -FilterScript {$_.href -match '^http.*(downloads|dl).dell.com/.*-win10-.*\.CAB$'} | Select-Object -First 1 | Select-Object -ExpandProperty outerHTML) -replace '.*(http.*\.CAB).*','$1'
    $cabfile
    "${PSScriptRoot}\Dell\Latitude\win10\${directory}\$(Split-Path -Path $cabfile.Replace('%20',' ') -Leaf)"
    "====================================================================="
    #Invoke-WebRequest -Uri $cabfile -UseBasicParsing -UserAgent $userAgent -ContentType 'application/zip' -OutFile "${PSScriptRoot}\Dell\Latitude\win10\${directory}\$(Split-Path -Path $cabfile.Replace('%20',' ') -Leaf)"

    <# VERIFY DOWNLOAD #>
    #Test-Path -Path "${PSScriptRoot}\Dell\Latitude\win10\${directory}\$(Split-Path -Path $cabfile.Replace('%20',' ') -Leaf)"
    #Remove-Item -Path "${PSScriptRoot}\Dell\Latitude\win10\${directory}\$(Split-Path -Path $cabfile.Replace('%20',' ') -Leaf)" -Confirm:$false -Force
}



#(Invoke-WebRequest -Uri 'https://www.dell.com/support/kbdoc/000108641/latitude-e5570-windows-10-driver-pack' -UserAgent $userAgent -UseBasicParsing).Links