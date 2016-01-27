function Get-PagerDutyUsers(){
    $PDC = Get-PagerDutyCore

    $Result = New-Object System.Collections.ArrayList

    $PDC.ApiGet("users") | ForEach-Object {$Result.AddRange($_.users)}

    return $Result
}