#TODO: Update Documentation

function Get-PagerDutyMaintenanceWindow {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(
        #Filters the results, showing only the maintenance windows whose descriptions contain the query.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$Query,

        #An array of service IDs, specifying services whose maintenance windows will be returned.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        $ServiceIds,

        #A comma-separated list of team IDs, specifying teams whose maintenance windows will be returned.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        $Teams,

        #Only return maintenance windows that are of this type. Possible values are past, future, ongoing. If this parameter is omitted, all maintenance windows will be returned.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.MaintenanceWindowFilters]$Filter,

        #Include inline teams information in the response.
        [switch]$IncludeTeamsInResponse,

        #When pulling multiple results, the maximum number of results you'd like returned.
        [int]$MaxResults
    )

    $QueryAdditions = ""

    if ($ServiceIds) {
        if ($ServiceIds -isnot [System.Collections.ICollection]){
            $ServiceIds = @($ServiceIds)
        }

        $ServiceIds | ForEach-Object {$QueryAdditions += "&service_ids[]=$_"}

        if ($QueryAdditions.Length -ne 0) {
            $QueryAdditions = '?' + $QueryAdditions.TrimStart('&')
        }
    }

    $Uri = "maintenance_windows$QueryAdditions"

    $Body = @{}

    if ($Query) {
        $Body['query'] = $Query
    }

    if ($Teams) {
        if ($Teams -is [System.Collections.ICollection]){
            $Teams = $Teams -join ","
        }

        $Body['teams'] = $Teams.Replace(' ','')
    }

    if ($Filter) {
        $Body['filter'] = $Filter.ToString()
    }

    if ($IncludeTeamsInResponse) {
        $Body['include[]'] = 'teams'
    }

    $Results = New-Object System.Collections.ArrayList

    if ($PsCmdlet.ShouldProcess("get maintenance windows")) {
        $PagerDutyCore.ApiGet($Uri, $Body, $MaxResults) `
            | ForEach-Object {$Results.AddRange($_.maintenance_windows)}
        $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.MaintenanceWindow')}
        return $Results
    }
}

function Set-PagerDutyMaintenanceWindow {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param (
        #The ID of an existing Pager Duty maintenance window
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [System.DateTime]$Id,

        #The maintenance window's start time. Can only be updated on future maintenance windows. If the start_time is set to a date in the past, it will be updated to the current date.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [System.DateTime]$StartTime,

        #The maintenance window's end time. Can only be updated on ongoing and future maintenance windows, and cannot be set to a value before start_time.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [System.DateTime]$EndTime,

        #Description for this maintenance window. Can only be updated on ongoing and future maintenance windows.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$Description,

        #Services that are affected by this maintenance window. Can only be updated on future maintenance windows.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        $ServiceIds
    )

    $Uri = "maintenance_windows/$Id"

    $Body = @{}

    if ($StartTime) {
        $Body['start_time'] = $PagerDutyCore.ConvertDateTime($StartTime)
    }

    if ($EndTime) {
        $Body['end_time'] = $PagerDutyCore.ConvertDateTime($EndTime)
    }

    if ($Description) {
        $Body['description'] = $Description
    }

    if ($ServiceIds) {
        if ($ServiceIds -isnot [System.Collections.ICollection]){
            $ServiceIds = @($ServiceIds)
        }

        $Body['service_ids'] = $ServiceIds | ConvertTo-Json -Depth 5 -Compress
    }

    if ($Body.Count -eq 0) { throw [System.ArgumentNullException] "Must provide one value to update for the maintenance window." }

    if ($PsCmdlet.ShouldProcess("set maintenance window")) {
        $Result = $PagerDutyCore.ApiPut($Uri)
        $Result.maintenance_window.pstypenames.Insert(0,'PagerDuty.MaintenanceWindow')
        return $Result.maintenance_window
    }
}

function New-PagerDutyMaintenanceWindow {
[CmdletBinding(DefaultParameterSetName="update", SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param (
        #The user id of the user creating the maintenance window. This is only needed if you are using token based authentication.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [System.DateTime]$RequesterId,

        #This maintenance window's start time. This is when the services will stop creating incidents. If this date is in the past, it will be updated to be the current time.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [System.DateTime]$StartTime,

        #This maintenance window's end time. This is when the services will start creating incidents again. This date must be in the future and after the start_time.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [System.DateTime]$EndTime,

        #A description for this maintenance window.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$Description,

        #The ids of the services that are affected by this maintenance window.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        $ServiceIds
    )

    $Uri = "maintenance_windows"

    $Body = @{}

    if ($RequesterId) {
        $Body['requester_id'] = $RequesterId
    }

    $MWObject = @{
        start_time = $PagerDutyCore.ConvertDateTime($StartTime)
        end_time = $PagerDutyCore.ConvertDateTime($EndTime)
    }

    if ($Description) {
        $MWObject['description'] = $Description
    }

    if ($ServiceIds -isnot [System.Collections.ICollection]){
        $ServiceIds = @($ServiceIds)
    }

    $MWObject['service_ids'] = $ServiceIds | ConvertTo-Json -Depth 5 -Compress

    $Body['maintenance_window'] = $MWObject | ConvertTo-Json -Depth 5 -Compress

    if ($PsCmdlet.ShouldProcess("new maintenance window")) {
        $Result = $PagerDutyCore.ApiPost($Uri)
        $Result.maintenance_window.pstypenames.Insert(0,'PagerDuty.MaintenanceWindow')
        return $Result.maintenance_window
    }
}

function Remove-PagerDutyMaintenanceWindow {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param (
        #The ID of an existing Pager Duty maintenance window
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [System.DateTime]$Id
    )

    $Uri = "maintenance_windows/$Id"

    if ($PsCmdlet.ShouldProcess("remove maintenance window")) {
        $Result = $PagerDutyCore.ApiPost($Uri)
        return $Result
    }
}

Export-ModuleMember Get-PagerDutyMaintenanceWindow
Export-ModuleMember Set-PagerDutyMaintenanceWindow
Export-ModuleMember New-PagerDutyMaintenanceWindow
Export-ModuleMember Remove-PagerDutyMaintenanceWindow