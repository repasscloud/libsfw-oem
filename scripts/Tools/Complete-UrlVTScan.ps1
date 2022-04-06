function Complete-UrlVTScan {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
                   Position=0,
                   HelpMessage="Absolute URL to run security scans.")]
        [Alias("URI")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $URL,

        [Parameter(Mandatory=$true,
                   Position=1,
                   HelpMessage="VirusTotal API Key to action scans.")]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ApiKey
    )
    
    begin {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    }
    
    process {
        <# SUBMIT URL TO BE SCANNED #>
        $headers=@{}
        $headers.Add("Accept", "application/json")
        $headers.Add("x-apikey", "${ApiKey}")
        $headers.Add("Content-Type", "application/x-www-form-urlencoded")
        $response = Invoke-WebRequest -Uri 'https://www.virustotal.com/api/v3/urls' -Method POST -Headers $headers -ContentType 'application/x-www-form-urlencoded' -Body "url=${URL}"
        $output = $response.Content | ConvertFrom-Json
        $analysisId = $output.data.id   # return data captured

        <# ENCODE URL TO SCAN TO BASE64 #>
        $readableText = "${URL}"
        $encodedBytes = [System.Text.Encoding]::UTF8.GetBytes($readableText)
        $encodedText = ([System.Convert]::ToBase64String($encodedBytes)).Replace('=','')

        <# SUBMIT URL FOR REPORT OF URL #>
        $headers=@{}
        $headers.Add("Accept", "application/json")
        $headers.Add("x-apikey", "${ApiKey}")
        try {
            $response = Invoke-WebRequest -Uri "https://www.virustotal.com/api/v3/urls/${encodedText}" -Method GET -Headers $headers -ErrorAction Stop
            $output = $response.Content | ConvertFrom-Json -AsHashTable

            $suspiciousCount = $output.data.attributes.last_analysis_stats.suspicious
            $undetectedCount = $output.data.attributes.last_analysis_stats.undetected
            $timeoutCount    = $output.data.attributes.last_analysis_stats.timeout
            $harmlessCount   = $output.data.attributes.last_analysis_stats.harmless
            $maliciousCount  = $output.data.attributes.last_analysis_stats.malicious

            <# RETURN DATA #>
            return $analysisId,$suspiciousCount,$undetectedCount,$timeoutCount,$harmlessCount,$maliciousCount
        }
        catch {
            return $analysisId,0,0,0,0,0
        }
    }
    
    end {
        [System.GC]::Collect()
    }
}