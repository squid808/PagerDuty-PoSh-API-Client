#TODO: Update Documentation

function Get-PagerDutyAlert {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(
        #The start of the date range over which you want to search. The time element is optional.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [System.DateTime]$Since,

        #The end of the date range over which you want to search. This should be in the same format as since. The size of the date range must be less than 3 months.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [System.DateTime]$Until,

        #Returns only the alerts of the said types. Can be one of SMS, Email, Phone, or Push.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.AlertFilterTypes]$FilterType,

        #Time zone in which dates in the result will be rendered. Defaults to account time zone.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.TimeZones]$TimeZone,

        #When pulling multiple results, the maximum number of results you'd like returned.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$MaxResults
    )

    $Uri = "alerts"

    $Body = @{
        since=$PagerDutyCore.ConvertDateTime($Since)
        until=$PagerDutyCore.ConvertDateTime($Until)
    }

    if ($FilterType) {
        $Body["filter[type]"] = $FilterType.ToString()
    }

    if ($FilterType) {
        $Body["time_zone"] = $PagerDutyCore.ConvertTimeZone($TimeZone)
    }

    $Results = New-Object System.Collections.ArrayList

    if ($PsCmdlet.ShouldProcess("get alerts")) {
        $PagerDutyCore.ApiGet($Uri, $Body, $MaxResults) `
            | ForEach-Object {$Results.AddRange($_.alerts)}
        $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.Alert')}
        return $Results
    }
}