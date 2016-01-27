$PagerDutyCore = New-Object psobject -Property @{
    apiKey = $null
    domain = $null
    authFolder = $env:USERPROFILE + "\Documents\WindowsPowerShell\Modules\PagerDutyAPI"
    authFileName = "authSettings.json"
}

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

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ApiPost" -Value {
    param([string]$apiPath, [int]$limit = 100)
    
    return $this.ApiCallBase($apiPath, [Microsoft.PowerShell.Commands.WebRequestMethod]::Post, $limit)
}

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ApiGet" -Value {
    param([string]$apiPath, [int]$limit = 100)

    return $this.ApiCallBase($apiPath, [Microsoft.PowerShell.Commands.WebRequestMethod]::Get, $limit)
}

$PagerDutyCore | Add-Member -MemberType ScriptMethod -Name "ApiCallBase" -Value {
    param( 
        [string]$apiPath,
        [Microsoft.PowerShell.Commands.WebRequestMethod]$Method,
        [int]$limit = 100
    )

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

    $results = Invoke-RestMethod -Method Get -Headers $headers -Uri $uri -Body $body

    if ($results.total -ne $null -OR 
        $results.limit -ne $null -OR 
        $results.offset -ne $null) {
        
        $collection = New-Object System.Collections.ArrayList

        $collection.Add($results) | Out-Null

        $pagesCount = [System.Math]::Ceiling($results.total/$limit)

        do {
            $nextPage = [System.Math]::Ceiling(($results.offset + $limit)/$limit)

            Write-Progress -Activity "Working with PagerDuty API" `
                -Status ("Pulling page {0}/{1}" -f $nextPage, $pagesCount) `
                -PercentComplete (($nextPage/$pagesCount)*100)

            $body = @{
                "limit"=$limit
                "offset"=$results.offset + $limit
            }

            $results = Invoke-RestMethod -Method Get -Headers $headers -Uri $Uri -Body $body

            $collection.Add($results) | Out-Null
            
        } while ($results.offset -lt $results.total - $limit)

        return $collection
    } else {
        return 
    }
}

function Get-PagerDutyCore{
 
    if(Get-Variable -Scope Global -Name 'PagerDutyCore' -EA SilentlyContinue){ 
        return (Get-Variable -Scope Global -Name 'PagerDutyCore').Value 
    }
 
    $Global:PagerDutyCore = $PagerDutyCore.psobject.copy()
         
    return $PagerDutyCore
}