Set-Variable -Scope Global -Name PagerDutyCore -Option ReadOnly -Value (New-Object psobject -Property @{
    apiKey = $null
    domain = $null
    authFolder = $env:USERPROFILE + "\Documents\WindowsPowerShell\Modules\PagerDuty"
    authFileName = "authSettings.json"
    timeZoneDict = $PagerDutyTimeZoneDict
})

#AUTHENTICATION
$PagerDutyCore | Add-Member -MemberType ScriptProperty -Name "authFilePath" -Value {
    return [System.IO.Path]::Combine($this.authFolder, $this.authFileName)
} -Force

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "LoadAuthDetails" -Value {
    if (Test-Path $this.authFilePath -PathType Leaf) {
        $json = Get-Content -Raw -Path $this.authFilePath | ConvertFrom-Json
        $this.apiKey = $json.apiKey
        $this.domain = $json.domain
    }
} -Force

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "SaveAuthDetails" -Value {
    if (-not (Test-Path $this.authFolder)) {New-Item -Path $this.authFolder -ItemType Directory}    
    $this | select apiKey, domain | ConvertTo-Json | Out-File -FilePath $this.authFilePath
} -Force

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "CheckForAuthDetails" -Value {
    if ($this.apiKey -eq $null -OR $this.domain -eq $null) {
        $this.LoadAuthDetails()
    }

    if ($this.apiKey -eq $null -OR $this.domain -eq $null) {

        if ($this.apiKey -eq $null) {
            $this.apiKey = Read-Host "Please enter your API Key. For more information, please see https://developer.pagerduty.com/documentation/rest/authentication"
        }

        if ($this.domain -eq $null) {
            $this.domain = Read-Host "Please enter your PagerDuty domain, eg for mydomain.pagerduty.com enter mydomain"
        }

        if ($this.domain -contains ".pagerduty.com") {
            $this.domain = $this.domain.Replace(".pagerduty.com","")
        }

        if ($this.domain -contains ".com") {
            $this.domain = $this.domain.Replace(".com","")
        }

        $this.SaveAuthDetails()
    }
} -Force


#API CALLS
$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ApiDelete" -Value {
    param([string]$apiPath, [System.Collections.Hashtable]$body=$null)
    
    return $this.ApiCallBase($apiPath, [Microsoft.PowerShell.Commands.WebRequestMethod]::Delete, $body)
} -Force

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ApiGet" -Value {
    param([string]$apiPath, [System.Collections.Hashtable]$body, [int]$maxResults = $null, [int]$limit = 100)

    return $this.ApiCallBase($apiPath, [Microsoft.PowerShell.Commands.WebRequestMethod]::Get, $body, $maxResults, $limit)
} -Force

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ApiPost" -Value {
    param([string]$apiPath, [System.Collections.Hashtable]$body)
    
    return $this.ApiCallBase($apiPath, [Microsoft.PowerShell.Commands.WebRequestMethod]::Post, $body)
} -Force

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ApiPut" -Value {
    param([string]$apiPath, [System.Collections.Hashtable]$body)
    
    return $this.ApiCallBase($apiPath, [Microsoft.PowerShell.Commands.WebRequestMethod]::Put, $body)
} -Force

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ApiCallBase" -Value {
    param( 
        [string]$apiPath,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method,
        [System.Collections.Hashtable]$body=$null,
        [int]$maxResults = $null,
        [int]$limit = 100
    )

    $bodyAdditions = $body

    $this.CheckForAuthDetails()

    $uri = "https://{0}.pagerduty.com/api/v1/{1}" -f $this.domain, $apiPath

    $headers = @{
        "Content-type"="application/json"
        "Authorization"=("Token token="+$this.apiKey)
    }

    $body = @{}

    if ($bodyAdditions -AND $bodyAdditions.Count -gt 0){
        $bodyAdditions.Keys | % {$body.Add($_, $bodyAdditions[$_])}
    }
    
    if ($Method -ne [Microsoft.PowerShell.Commands.WebRequestMethod]::Get) {
        $bodycontents = ($body | ConvertTo-Json -Depth 10 -Compress)
        $bodycontents = [Regex]::Replace($bodycontents, "\\[Uu]([0-9A-Fa-f]{4})", {[char]::ToString([Convert]::ToInt32($args[0].Groups[1].Value, 16))} )
    } else {
        $body["limit"]=$limit
        $body["offset"]=0
        if ($maxResults -AND $maxResults -gt 0 -AND $maxResults -lt $limit){
            $body["limit"] = $maxResults
        }
        $bodycontents = $body
    }
    
    $results = Invoke-RestMethod -Method $Method -Headers $headers -Uri $uri -Body $bodycontents

    if ($results.total -ne $null -OR 
        $results.limit -ne $null -OR 
        $results.offset -ne $null) {
        
        $collection = New-Object System.Collections.ArrayList

        $collection.Add($results) | Out-Null

        $pagesCount = [System.Math]::Ceiling($results.total/$limit)

        do {

            if ($maxResults -AND $maxResults -gt 0){
                if (($results.offset + $results.limit) -ge $maxResults) {
                    break
                } else {
                    if (($results.offset + ($results.limit*2)) -ge $maxResults){
                        $body["limit"] = $maxResults - ($results.offset + $results.limit)
                    }
                }
            }
            
            $nextPage = [System.Math]::Ceiling(($results.offset + $limit)/$limit)

            if ($pagesCount -ne 0) {
                Write-Progress -Activity "Working with PagerDuty API" `
                    -Status ("Pulling page {0}/{1}" -f $nextPage, $pagesCount) `
                    -PercentComplete (($nextPage/$pagesCount)*100)
            }

            $body["offset"]=($results.offset + $limit)

            if ($maxResults -AND $maxResults -gt 0 -AND $maxResults -lt ($collection.Count + $limit)){
                $body["limit"] = ($maxResults - $collection.Count)
            }

            $results = Invoke-RestMethod -Method $Method -Headers $headers -Uri $Uri -Body $body

            $collection.Add($results) | Out-Null
            
        } while ($results.offset -lt $results.total - $limit)

        return $collection
    } else {
        return $results
    }
} -Force


#VERIFICATION AND ERRORS
$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "VerifyTypeMatch" -Value {
    param( 
        $InputObject,
        [string]$ExpectedType
    )

    $type = (Get-Member -InputObject $InputObject).TypeName[0]

    if ($type -ne $ExpectedType){
        throw "Parameter was expecting object of type $ExpectedType but encountered $type instead."
    }
} -Force

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "VerifyNotNull" -Value {
    param( 
        $InputObject
    )

    if ($InputObject -eq $null){
        throw [System.NullReferenceException] "Parameter cannot be blank."
    }
} -Force


#TYPE HELPERS
$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ConvertTimeZone" -Value {
    param( 
        [PagerDuty.TimeZones]$ZoneEnum
    )

    return $this.timeZoneDict[$ZoneEnum]
} -Force

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ConvertDateTime" -Value {
    param( 
        [System.DateTime]$Date
    )
    
    #Make sure whatever local time coming in goes out in zulu time to standardize.
    return $Date.ToUniversalTime().ToString("yyyy-MM-ddTHH:mmZ")
} -Force

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ConvertBoolean" -Value {
    param( 
        [System.Boolean]$Bool
    )
    
    return $Bool.ToString().ToLower()
} -Force

$PagerDutyCore.pstypenames.Insert(0,'PagerDuty.Core')

@"
Help Template, remove this when the project has been completed.
<#
.SYNOPSIS
    

.DESCRIPTION
    

.EXAMPLE
    <example here>

    RESULTS

    DESCRIPTION

.INPUTS


.OUTPUTS


.NOTES
    

.LINK
    https://github.com/robcerda60/PagerDuty-PoSh-API-Client

#>
"@