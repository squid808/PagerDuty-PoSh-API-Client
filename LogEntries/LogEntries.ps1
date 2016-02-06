#TODO: Update Documentation

function Get-PagerDutyLogEntry {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(
        #The Id of an existing Pager Duty log entry.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [string]$Id,

        #List only incident log entries that describe interactions with this specific user.
        [Parameter(Mandatory=$true, ParameterSetName='User', ValueFromPipelineByPropertyName=$true)]
        [string]$UserId,

        #List only incident log entries that describe interactions with this specific incident.
        [Parameter(Mandatory=$true, ParameterSetName='Incident', ValueFromPipelineByPropertyName=$true)]
        [string]$IncidentId,

        #List all log entries
        [Parameter(Mandatory=$true, ParameterSetName='All', ValueFromPipelineByPropertyName=$true)]
        [switch]$All,

        #Time zone in which dates in the result will be rendered. Defaults to UTC
        [Parameter(ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='All', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='User', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Incident', ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.TimeZones]$TimeZone,
        
        #The start of the date range over which you want to search.
        [Parameter(ParameterSetName='All', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='User', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Incident', ValueFromPipelineByPropertyName=$true)]
        [System.DateTime]$Since,

        #The end of the date range over which you want to search.
        [Parameter(ParameterSetName='All', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='User', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Incident', ValueFromPipelineByPropertyName=$true)]
        [System.DateTime]$Until,

        #If true, will only return log entries of type trigger, acknowledge, or resolve. Defaults to false.
        [Parameter(ParameterSetName='All', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='User', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Incident', ValueFromPipelineByPropertyName=$true)]
        [bool]$IsOverview,

        #Array of additional details to include. This API accepts channel, incident, and service. If channel is not included, a summary will be returned
        [Parameter(ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='All', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='User', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Incident', ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.LogEntryIncludes]$Include,

        #When pulling multiple results, the maximum number of results you'd like returned.
        [Parameter(ParameterSetName='All', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='User', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Incident', ValueFromPipelineByPropertyName=$true)]
        [int]$MaxResults
    )

    $Additions = ""

    if ($Include){
        switch ($Include.value__) {
            1 {$Additions = "?include[]=channel"}
            2 {$Additions = "?include[]=incident"}
            3 {$Additions = "?include[]=channel&include[]=incident"}
            4 {$Additions = "?include[]=service"}
            5 {$Additions = "?include[]=channel&include[]=service"}
            6 {$Additions = "?include[]=incident&include[]=service"}
            7 {$Additions = "?include[]=channel&include[]=incident&include[]=service"}
        }
    }

    switch ($PsCdlet.ParameterSetName) {
        "Id" {$Uri = "log_entries/$Id"}
        "All" {$Uri = "log_entries$Additions"}
        "User" {$Uri = "users/$UserId/log_entries$Additions"}
        "Incident" {$Uri = "incidents/$IncidentId/log_entries$Additions"}
    }

    $Uri +=$Additions

    $Body = @{}

    if ($TimeZone) {
        $Body["time_zone"] = $PagerDutyCore.ConvertTimeZone($TimeZone)
    }

    if ($Since){
        $Body['since'] = $PagerDutyCore.ConvertDateTime($Since)
    }

    if ($Until){
        $Body['until'] = $PagerDutyCore.ConvertDateTime($Until)
    }

    if ($IsOverview) { 
        $Body['is_overview'] = $IsOverview 
    }

    $Results = New-Object System.Collections.ArrayList

    if ($PsCmdlet.ShouldProcess("get log entries")) {
        $PagerDutyCore.ApiGet($Uri, $Body, $MaxResults) `
            | ForEach-Object {$Results.AddRange($_.log_entries)}
        $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.LogEntry')}
        return $Results
    }
}

Export-ModuleMember Get-PagerDutyLogEntry