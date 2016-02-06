#TODO: Update Documentation

function Get-PagerDutyScheduleOverride {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param (
        
        #The ID of a Pager Duty schedule.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Id,
        
        #The start time of the date range you want to retrieve override for. The maximum date range queryable is 3 months.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [datetime]$Since,

        #The end time of the date range you want to retrieve override for.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [datetime]$Until,

        #When this parameter is present, only editable overrides will be returned. The result will only include the id the override if this parameter is present. Only future overrides are editable.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [bool]$Editable,

        <#
        Any on-call schedule entries that pass the date range bounds will be truncated at the bounds, unless the parameter overflow=true is passed. This parameter defaults to false.
        For instance, if your schedule is a rotation that changes daily at midnight UTC, and your date range is from 2011-06-01T10:00:00Z to 2011-06-01T14:00:00Z:
         -If you don't pass the overflow=true parameter, you will get one schedule entry returned with a start of 2011-06-01T10:00:00Z and end of 2011-06-01T14:00:00Z.
         -If you do pass the overflow=true parameter, you will get one schedule entry returned with a start of 2011-06-01T00:00:00Z and end of 2011-06-02T00:00:00Z.
        #>
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [bool]$Overflow
    )

    $Uri = "schedules/$Id/overrides"

    $Body = @{
        since = $PagerDutyCore.ConvertDateTime($Since)
        until = $PagerDutyCore.ConvertDateTime($Until)
    }

    if ($Editable) {
        $Body['editable'] = $PagerDutyCore.ConvertBoolean($Editable)
    }

    if ($Overflow) {
        $Body['overflow'] = $PagerDutyCore.ConvertBoolean($Overflow)
    }
    
    if ($PsCmdlet.ShouldProcess("get schedule overrides")) {
        $Result = $PagerDutyCore.ApiGet($Uri, $Body)
        $Result.overrides | Foreach-Object {$_.pstypenames.Insert(0,'PagerDuty.ScheduleOverride')}
        return $Result.overrides
    }
}

function New-PagerDutyScheduleOverride {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param (
        #The ID of a Pager Duty schedule.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Id,
        
        #The start date and time for the override.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [datetime]$Start,

        #The end date and time for the override.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [datetime]$End,

        #The ID of the user who will be on call for the duration of the override.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$UserId
    )

    $Uri = "schedules/$Id/overrides"

    $Body = @{
        start = $PagerDutyCore.ConvertDateTime($Start)
        end = $PagerDutyCore.ConvertDateTime($End)
        user_id = $UserId
    }

    if ($PsCmdlet.ShouldProcess("new schedule override")) {
        $Result = $PagerDutyCore.ApiPost($Uri, $Body)
        $Result.override.pstypenames.Insert(0,'PagerDuty.ScheduleOverride')
        return $Result.override
    }

}

function Remove-PagerDutyScheduleOverride {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param (
        #The ID of a Pager Duty schedule.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$ScheduleId,

        #The ID of the Pager Duty override to delete.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Id
    )

    $Uri = "schedules/$ScheduleId/overrides/$Id"

    if ($PsCmdlet.ShouldProcess("remove schedule override")) {
        $Result = $PagerDutyCore.ApiDelete($Uri)
        return $Result
    }
}

Export-ModuleMember Get-PagerDutyScheduleOverride
Export-ModuleMember New-PagerDutyScheduleOverride
Export-ModuleMember Remove-PagerDutyScheduleOverride