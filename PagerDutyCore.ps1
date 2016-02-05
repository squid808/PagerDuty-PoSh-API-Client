#Requires -Version 3.0

#Load Supporting Types First
#TODO: Remove object variables -it was a silly idea.

. .\SupplementalTypes\PagerDutyTypes.ps1

Set-Variable -Scope Global -Name PagerDutyCore -Option ReadOnly -Value (New-Object psobject -Property @{
    apiKey = $null
    domain = $null
    authFolder = $env:USERPROFILE + "\Documents\WindowsPowerShell\Modules\PagerDutyAPI"
    authFileName = "authSettings.json"
    timeZoneDict = $PagerDutyTimeZoneDict
})

#AUTHENTICATION
$PagerDutyCore | Add-Member -MemberType ScriptProperty -Name "authFilePath" -Value {
    return [System.IO.Path]::Combine($this.authFolder, $this.authFileName)
}

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "LoadAuthDetails" -Value {
    if (Test-Path $this.authFilePath -PathType Leaf) {
        $json = Get-Content -Raw -Path $this.authFilePath | ConvertFrom-Json
        $this.apiKey = $json.apiKey
        $this.domain = $json.domain
    }
}

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "SaveAuthDetails" -Value {
    if (-not (Test-Path $this.authFolder)) {New-Item -Path $this.authFolder -ItemType Directory}    
    $this | select apiKey, domain | ConvertTo-Json | Out-File -FilePath $this.authFilePath
}

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "CheckForAuthDetails" -Value {
    if ($this.apiKey -eq $null -OR $this.domain -eq $null) {
        $this.LoadAuthDetails()
    }

    if ($this.apiKey -eq $null -OR $this.domain -eq $null) {

        if ($this.apiKey -eq $null) {
            $this.apiKey = Read-Host "Please enter your API Key. For more information, please see https://developer.pagerduty.com/documentation/rest/authentication"
        }

        if ($this.domain -eq $null) {
            $this.domain = Read-Host "Please enter your domain"
        }

        $this.SaveAuthDetails()
    }
}


#API CALLS
$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ApiDelete" -Value {
    param([string]$apiPath, [System.Collections.Hashtable]$body=$null)
    
    return $this.ApiCallBase($apiPath, [Microsoft.PowerShell.Commands.WebRequestMethod]::Delete, $body)
}

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ApiGet" -Value {
    param([string]$apiPath, [System.Collections.Hashtable]$body, [int]$maxResults = $null, [int]$limit = 100)

    return $this.ApiCallBase($apiPath, [Microsoft.PowerShell.Commands.WebRequestMethod]::Get, $body, $maxResults, $limit)
}

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ApiPost" -Value {
    param([string]$apiPath, [System.Collections.Hashtable]$body)
    
    return $this.ApiCallBase($apiPath, [Microsoft.PowerShell.Commands.WebRequestMethod]::Post, $body)
}

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ApiPut" -Value {
    param([string]$apiPath, [System.Collections.Hashtable]$body)
    
    return $this.ApiCallBase($apiPath, [Microsoft.PowerShell.Commands.WebRequestMethod]::Put, $body)
}

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

    $body = @{
        "limit"=$limit
        "offset"=0
    }

    if ($bodyAdditions -AND $bodyAdditions.Count -gt 0){
        $bodyAdditions.Keys | % {$body.Add($_, $bodyAdditions[$_])}
    }

    if ($maxResults -AND $maxResults -gt 0 -AND $maxResults -lt $limit){
        $body["limit"] = $maxResults
    }

    $results = Invoke-RestMethod -Method Get -Headers $headers -Uri $uri -Body $body

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

            Write-Progress -Activity "Working with PagerDuty API" `
                -Status ("Pulling page {0}/{1}" -f $nextPage, $pagesCount) `
                -PercentComplete (($nextPage/$pagesCount)*100)

            $body["offset"]=($results.offset + $limit)

            if ($maxResults -AND $maxResults -gt 0 -AND $maxResults -lt ($collection.Count + $limit)){
                $body["limit"] = ($maxResults - $collection.Count)
            }

            $results = Invoke-RestMethod -Method Get -Headers $headers -Uri $Uri -Body $body

            $collection.Add($results) | Out-Null
            
        } while ($results.offset -lt $results.total - $limit)

        return $collection
    } else {
        return $results
    }
}


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
}

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "VerifyNotNull" -Value {
    param( 
        $InputObject
    )

    if ($InputObject -eq $null){
        throw [System.NullReferenceException] "Parameter cannot be blank."
    }
}


#TYPE HELPERS
$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ConvertTimeZone" -Value {
    param( 
        [PagerDuty.TimeZones]$ZoneEnum
    )

    return $this.timeZoneDict[$ZoneEnum]
}

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ConvertDateTime" -Value {
    param( 
        [System.DateTime]$Date
    )
    
    #Make sure whatever local time coming in goes out in zulu time to standardize.
    return $Date.ToUniversalTime().ToString("yyyy-MM-ddTHH:mmZ")
}

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ConvertBoolean" -Value {
    param( 
        [System.Boolean]$Bool
    )
    
    return $Bool.ToString().ToLower()
}

$PagerDutyCore.pstypenames.Insert(0,'PagerDuty.Core')

. .\Users\Users.ps1
. .\Users\NotificationRules.ps1
. .\Users\ContactMethods.ps1
. .\Alerts\Alerts.ps1
. .\EscalationPolicies\EscalationPolicies.ps1
. .\EscalationPolicies\EscalationRules.ps1
. .\Incidents\Incidents.ps1
. .\Incidents\Notes.ps1
. .\LogEntries\LogEntries.ps1
. .\MaintenanceWindows\MaintenanceWindows.ps1


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