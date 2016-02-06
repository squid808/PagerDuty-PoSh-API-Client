#TODO: Update Documentation

function Get-PagerDutySchedule {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param (
        #The ID for an existing Pager Duty schedule.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="User")]
        [string]$Id,

        #List existing on-call schedules.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="All")]
        [switch]$All,

        #List schedule entries that are active for a given time range for a specified on-call schedule.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Entry")]
        [switch]$GetEntries,

        #List all the users on-call in a given schedule for a given time range.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="User")]
        [switch]$GetUsers,

        #The start of the date range over which you want to search. The time element is optional.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="User")]
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Entry")]
        [System.DateTime]$Since,

        #The end of the date range over which you want to search. This should be in the same format as since. The size of the date range must be less than 3 months.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="User")]
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Entry")]
        [System.DateTime]$Until,

        #Filters the result, showing only the schedules whose name matches the query.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="All")]
        [string]$Query,

        #The user id of the user making the request. This will be used to generate the calendar private urls. This is only needed if you are using token based authentication.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="All")]
        [string]$RequesterId,

        #Time zone in which dates in the result will be rendered. Defaults to account time zone.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="Entry")]
        [PagerDuty.TimeZones]$TimeZone,

        #The ID of an existing Pager Duty schedule.
        [string]$ScheduleId,

        <#
        Any on-call schedule entries that pass the date range bounds will be truncated at the bounds, unless the parameter overflow=true is passed. This parameter defaults to false.
        For instance, if your schedule is a rotation that changes daily at midnight UTC, and your date range is from 2011-06-01T10:00:00Z to 2011-06-01T14:00:00Z:
         -If you don't pass the overflow=true parameter, you will get one schedule entry returned with a start of 2011-06-01T10:00:00Z and end of 2011-06-01T14:00:00Z.
         -If you do pass the overflow=true parameter, you will get one schedule entry returned with a start of 2011-06-01T00:00:00Z and end of 2011-06-02T00:00:00Z.
        #>
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="Entry")]
        [bool]$Overflow,

        #To filter the returned on-call schedule entries by a specific user, you can optionally add the user_id parameter to the query.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="Entry")]
        [string]$UserId,

        #When pulling multiple results, the maximum number of results you'd like returned.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="All")]
        [int]$MaxResults

    )

    $Body = @{}

    if ($PsCmdlet.ParameterSetName -eq "Id") {
        $Uri = "schedules/$Id"

        if ($Since) {
            $Body['since'] = $PagerDutyCore.ConvertDateTime($Since)
        }

        if ($Until) {
            $Body['until'] = $PagerDutyCore.ConvertDateTime($Until)
        }

        if ($TimeZone) {
            $Body['time_zone'] = $PagerDutyCore.ConvertTimeZone($TimeZone)
        }

        if ($PsCmdlet.ShouldProcess("get schedule")) {
            $Result = $PagerDutyCore.ApiGet($Uri, $Body)
            $Result.schedule.pstypenames.Insert(0,'PagerDuty.Schedule')
            return $Result.schedule
        }
    } elseif ($PsCmdlet.ParameterSetName -eq "User"){
        
        $Uri = "schedules/$Id/users"

        if ($Since) {
            $Body['since'] = $PagerDutyCore.ConvertDateTime($Since)
        }

        if ($Until) {
            $Body['until'] = $PagerDutyCore.ConvertDateTime($Until)
        }

        if ($PsCmdlet.ShouldProcess("get schedule users")) {
            $Result = $PagerDutyCore.ApiGet($Uri, $Body)
            $Result.users | Foreach-Object {$_.pstypenames.Insert(0,'PagerDuty.ScheduleUser')}
            return $Result.users
        }

    } elseif ($PsCmdlet.ParameterSetName -eq "Entry"){

        $Uri = "schedules/$Id/entries"

        $Body['since'] = $PagerDutyCore.ConvertDateTime($Since)
        $Body['until'] = $PagerDutyCore.ConvertDateTime($Until)

        if ($Overflow) {
            $Body['overflow'] = $PagerDutyCore.ConvertBoolean($Overflow)
        }

        if ($TimeZone) {
            $Body['time_zone'] = $PagerDutyCore.ConvertTimeZone($TimeZone)
        }

        if ($UserId) {
            $Body['user_id'] = $UserId
        }

        if ($PsCmdlet.ShouldProcess("get schedule users")) {
            $Result = $PagerDutyCore.ApiGet($Uri, $Body)
            $Result.entries | Foreach-Object {$_.pstypenames.Insert(0,'PagerDuty.ScheduleEntry')}
            return $Result.entries
        }

    } else {

        $Uri = "schedules"

        if ($Query) {
            $Body['query'] = $Query
        }

        if ($Query) {
            $Body['requester_id'] = $RequesterId
        }

        $Results = New-Object System.Collections.ArrayList

        if ($PsCmdlet.ShouldProcess("get schedules")) {
            $PagerDutyCore.ApiGet($Uri, $Body, $MaxResults) `
                | ForEach-Object {$Results.AddRange($_.schedules)}
            $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.Schedule')}
            return $Results
        }
    }
}

function Set-PagerDutySchedule {
[CmdletBinding(DefaultParameterSetName="Schedule", SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param (

        #The ID for an existing Pager Duty schedule.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Schedule")]
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Overflow")]
        [string]$Id,
    
        <#
        Any on-call schedule entries that pass the date range bounds will be truncated at the bounds, unless the parameter overflow=true is passed. This parameter defaults to false.
        For instance, if your schedule is a rotation that changes daily at midnight UTC, and your date range is from 2011-06-01T10:00:00Z to 2011-06-01T14:00:00Z:
         -If you don't pass the overflow=true parameter, you will get one schedule entry returned with a start of 2011-06-01T10:00:00Z and end of 2011-06-01T14:00:00Z.
         -If you do pass the overflow=true parameter, you will get one schedule entry returned with a start of 2011-06-01T00:00:00Z and end of 2011-06-02T00:00:00Z.
        #>
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Overflow")]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="Schedule")]
        [bool]$Overflow,

        #A list of schedule layers.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Schedule")]
        $ScheduleLayers,

        #The time zone of the schedule.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="Schedule")]
        [PagerDuty.TimeZones]$TimeZone   
    )

    $Uri = "schedules/$Id"

    $Body = @{}

    if ($Overflow) {
        $Body['overflow'] = $PagerDutyCore.ConvertBoolean($Overflow)
    }

    if ($PsCmdlet.ParameterSetName -eq "Schedule"){
        
        if ($ScheduleLayers -isnot [System.Collections.ICollection]){
            $ScheduleLayers = @($ScheduleLayers)
        }

        $Schedule = @{
            schedule_layers = $ScheduleLayers | ConvertTo-Json -Depth 5 -Compress
            time_zone = $PagerDutyCore.ConvertTimeZone($TimeZone)
        }

        $Body['schedule'] = $Schedule
    }

    if ($PsCmdlet.ShouldProcess("set schedule")) {
        $Result = $PagerDutyCore.ApiPut($Uri, $Body)
        $Result.schedule.pstypenames.Insert(0,'PagerDuty.Schedule')
        return $Result.schedule
    }
}

function New-PagerDutySchedule {
[CmdletBinding(DefaultParameterSetName="New", SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param (
        #Preview what a schedule would look like without saving it. This work the same as the update or create actions, except that the result is not persisted. Preview optionally takes two additional arguments, since and until, deliminating the span of the preview.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Preview")]
        [switch]$Preview,

        #The start of the date range over which you want to return on-call schedule entries and on-call schedule layers. If not specified, since defaults to the current time
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="Preview")]
        [System.DateTime]$Since,

        #The end of the date range over which you want to return schedule entries and on-call schedule layers. If not specificed, until defaults to one week from the current time.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="Preview")]
        [System.DateTime]$Until,
    
        <#
        Any on-call schedule entries that pass the date range bounds will be truncated at the bounds, unless the parameter overflow=true is passed. This parameter defaults to false.
        For instance, if your schedule is a rotation that changes daily at midnight UTC, and your date range is from 2011-06-01T10:00:00Z to 2011-06-01T14:00:00Z:
         -If you don't pass the overflow=true parameter, you will get one schedule entry returned with a start of 2011-06-01T10:00:00Z and end of 2011-06-01T14:00:00Z.
         -If you do pass the overflow=true parameter, you will get one schedule entry returned with a start of 2011-06-01T00:00:00Z and end of 2011-06-02T00:00:00Z.
        #>
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="New")]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="Preview")]
        [bool]$Overflow,

        #A list of schedule layers.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="New")]
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Preview")]
        $ScheduleLayers,

        #The name of the schedule
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="New")]
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Preview")]
        [string]$Name,

        #The time zone of the schedule.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="New")]
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Preview")]
        [PagerDuty.TimeZones]$TimeZone   
    )

    $Uri = "schedules"

    $Body = @{}

    if ($PsCmdlet.ParameterSetName -eq "Preview"){
        $Uri += "/preview"

        if ($Since) {
            $Body['since'] = $PagerDutyCore.ConvertDateTime($Since)
        }

        if ($Until) {
            $Body['until'] = $PagerDutyCore.ConvertDateTime($Until)
        }
    }

    if ($Overflow) {
        $Body['overflow'] = $PagerDutyCore.ConvertBoolean($Overflow)
    }

    if ($ScheduleLayers -isnot [System.Collections.ICollection]){
        $ScheduleLayers = @($ScheduleLayers)
    }

    $Schedule = @{
        schedule_layers = $ScheduleLayers | ConvertTo-Json -Depth 5 -Compress
        time_zone = $PagerDutyCore.ConvertTimeZone($TimeZone)
        name = $Name
    }

    $Body['schedule'] = $Schedule

    if ($PsCmdlet.ShouldProcess("create new schedule")) {
        $Result = $PagerDutyCore.ApiPost($Uri, $Body)
        $Result.schedule.pstypenames.Insert(0,'PagerDuty.Schedule')
        return $Result.schedule
    }
}

function Remove-PagerDutySchedule {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param (
        #The ID of an existing Pager Duty schedule.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Id
    )

    $Uri = "schedules/$Id"

    if ($PsCmdlet.ShouldProcess("remove schedule")) {
        $Result = $PagerDutyCore.ApiDelete("users/$Id")
		return $Result.user
    }
}

function New-PagerDutyScheduleLayerObject {
    Param (
        #The unique identifier of the schedule layer to update. Omit this if creating a new schedule layer.
        [string]$Id,

        #The name of the schedule layer. Mandatory for updating a schedule.
        [string]$Name,

        #The start time of this layer.
        [Parameter(Mandatory=$true)]
        [datetime]$Start,

        #The end time of this layer. If null, the layer does not end.
        [datetime]$End,

        #The ordered list of users on this layer. Use the member order to indicate their order.
        [Parameter(Mandatory=$true)]
        $Users,

        #Can either be Daily or Weekly. Specifies the type of restriction.
        [PagerDuty.ScheduleRestrictionType]$RestrictionType,

        #Restrictions for the layer. A restriction is a limit on which period of the day or week the schedule layer can accept events.
        $Restrictions,

        #The effective start time of the layer. This can be before the start time of the schedule.
        [Parameter(Mandatory=$true)]
        [datetime]$RotationVirtualStart,

        #The priority of the layer. Layers with higher priority will override layers with a lower priority.
        [Parameter(Mandatory=$true)]
        [int]$Priority,

        #The duration of each on-call shift in seconds.
        [Parameter(Mandatory=$true)]
        [int]$RotationTurnLengthSeconds
    )

    if ($Users -isnot [System.Collections.ICollection]){
        $Users = @($Users)
    }

    $Body = @{
        start = $PagerDutyCore.ConvertDateTime($Start)
        users = $Users | ConvertTo-Json -Depth 5 -Compress
        rotation_virtual_start = $PagerDutyCore.ConvertDateTime($RotationVirtualStart)
        priority = $Priority
        rotation_turn_length_seconds = $RotationTurnLengthSeconds
    }

    if ($Id) {
        $Body['id'] = $Id    }

    if ($Name) {
        $Body['name'] = $Name
    }

    if ($End) {
        $Body['end'] = $PagerDutyCore.ConvertDateTime($End)
    }

    if ($RestrictionType) {
        $Body['restriction_type'] = $RestrictionType.ToString()
    }

    if ($Restrictions) {
        if ($Restrictions -isnot [System.Collections.ICollection]){
            $Restrictions = @($Restrictions)
        }

        $Body['restrictions'] = $Restrictions | ConvertTo-Json -Depth 5 -Compress
    }

    $Body.pstypenames.Insert(0,'PagerDuty.ScheduleLayer')

    return $Body
}

function New-PagerDutyScheduleUserEntryObject {
    Param(
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Id,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [int]$MemberOrder
    )

    $Body = @{
        user = @{id = $Id}
        member_order = $MemberOrder
    }

    $Body.pstypenames.Insert(0,'PagerDuty.ScheduleUserEntryObject')

    return $Body
}

function New-PagerDutyScheduleRestrictionObject {
    Param (
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [int]$DurationInSeconds,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$StartTimeOfDay    
    )

    $Body = @{
        duration_seconds = $DurationInSeconds
        start_time_of_day = $StartTimeOfDay
    }

    $Body.pstypenames.Insert(0,'PagerDuty.ScheduleRestriction')

    return $Body
}

Export-ModuleMember Get-PagerDutySchedule
Export-ModuleMember Set-PagerDutySchedule
Export-ModuleMember New-PagerDutySchedule
Export-ModuleMember Remove-PagerDutySchedule
Export-ModuleMember New-PagerDutyScheduleLayerObject
Export-ModuleMember New-PagerDutyScheduleUserEntryObject
Export-ModuleMember New-PagerDutyScheduleRestrictionObject