#TODO: Update Documentation

function Get-PagerDutyReport {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(
        #The start of the date range over which you want to search. The time element is optional.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [System.DateTime]$Since,

        #The end of the date range over which you want to search. This should be in the same format as since. The size of the date range must be less than 3 months.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [System.DateTime]$Until,

        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.ReportRollupType]$Rollup,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.ReportType]$ReportType
    )

    switch ($ReportType.ToString()) {
        "alerts_per_time" {$Uri = "reports/alerts_per_time"}
        "incidents_per_time" {$Uri = "reports/incidents_per_time"}
    }

    $Body = @{
        since = $PagerDutyCore.ConvertDateTime($Since)
        until = $PagerDutyCore.ConvertDateTime($Until)
    }

    if ($Rollup) {
        $Body['rollup'] = $Rollup.ToString()
    }

    if ($PsCmdlet.ShouldProcess("alerts")) {

        $Result = $PagerDutyCore.ApiGet($Uri, $Body)

        if ($ReportType.ToString() -eq "alerts_per_time") {
            $Result.alerts | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.AlertReport')}
            return $Result.alerts
        } else { 
            $Result.incidents | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.IncidentRepor')}
            return $Result.incidents
        }
    }
}