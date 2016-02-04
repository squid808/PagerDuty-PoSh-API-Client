#TODO: Update Documentation

function Get-PagerDutyIncident {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(

        #The ID or incident number of an existing Pager Duty incident.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='Id')]
        [string]$Id,

        #Use this if you are simply looking for the count of incidents that match a given query. This should be used if you don't need access to the actual incident details.
        [Parameter(Mandatory=$true, ParameterSetName='Count')]
        [string]$CountOnly,

        #When set to all, the since and until parameters and defaults are ignored. Use this to get all incidents since the account was created.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='List')]
        [switch]$All,

        #The start of the date range over which you want to search.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='List')]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='Count')]
        [System.DateTime]$Since,

        #The end of the date range over which you want to search.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='List')]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='Count')]
        [System.DateTime]$Until,

        #When set to 'all', the since and until parameters and defaults are ignored. Use this to get all incidents since the account was created.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='List')]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='Count')]
        [string]$DateRange,

        #Used to restrict the properties of each incident returned to a set of pre-defined fields. If omitted, returned incidents have the majority of fields present. 
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='List')]
        [string]$Fields,

        #Returns only the incidents currently in the passed status(es). Valid status options are triggered, acknowledged, and resolved. More status codes may be introduced in the future. Separate multiple statuses with a comma.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='List')]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='Count')]
        [PagerDuty.IncidentStatusTypes]$Status,

        #Returns only the incidents with the passed de-duplication key. See the PagerDuty Integration API docs for further details.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='List')]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='Count')]
        [string]$IncidentKey,

        #Returns only the incidents associated with the passed service(s). This expects one or more service IDs. Separate multiple ids with a comma.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='List')]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='Count')]
        [string]$Service,

        #A comma-separated list of team IDs, specifying teams whose maintenance windows will be returned.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='List')]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='Count')]
        [string]$Teams,

        #Returns only the incidents currently assigned to the passed user(s). This expects one or more user IDs. Please see below for more info on how to find your users' IDs. Separate multiple ids with a comma. Note: When using the assigned_to_user filter, you will only receive incidents with statuses of triggered or acknowledged. This is because resolved incidents are not assigned to any user. 
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='List')]
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='Count')]
        [string]$AssignedToUser,

        #Comma-separated list of the urgencies of the incidents to be returned. Defaults to high,low.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='List')]
        [string]$Urgency,

        #Time zone in which dates in the result will be rendered. Defaults to UTC.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='List')]
        [PagerDuty.TimeZones]$TimeZone,

        <#
        Used to specify both the field you wish to sort the results on of the results.
        - incident_number The number of the incident.
        - created_on The date/time the incident was triggered.
        - resolved_on The date/time the incident was resolved.
        - urgency The urgency of the incident. (Low-urgency incidents are ordered before high-urgency incidents.)
        #>
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='List')]
        [PagerDuty.IncidentSortBy]$SortBy,

        #When pulling multiple results, the maximum number of results you'd like returned.
        [Parameter(ParameterSetName='List')]
        [int]$MaxResults
    )

    $Uri = "incidents"

    if ($PsCmdlet.ParameterSetName -eq "Id") {

        $Uri += "/$Id"

        if ($PsCmdlet.ShouldProcess("get incident")) {
            $Result = $PagerDutyCore.ApiGet($Uri)
            $Result.pstypenames.Insert(0,'PagerDuty.Incident')
            return $Result
        }
    
    } else {

        $Body = @{}

        if ($DateRange) {
            $Body["date_range"] = $DateRange
        } else {
           
            if ($Since) {
                $Body["since"]=$PagerDutyCore.ConvertDateTime($Since)
            }

            if ($Until) {
                $Body["until"]=$PagerDutyCore.ConvertDateTime($Until)
            }
        }

        if ($Status) {
            $Body["status"]=$Status.ToString().Replace(" ","")
        }

        if ($IncidentKey) {
            $Body["incident_key"]=$IncidentKey
        }

        if ($Service) {
            $Body["service"]=$Service
        }

        if ($Teams) {
            $Body["teams"]=$Teams
        }

        if ($AssignedToUser) {
            $Body["assigned_to_user"]=$AssignedToUser
        }

        if ($PsCmdlet.ParameterSetName -eq "Count") {

            $Uri += "/count"

            if ($PsCmdlet.ShouldProcess("get incident coun")) {
                $Result = $PagerDutyCore.ApiGet($Uri)
                return $Result
            }

        } else {

            if ($Fields) {
                $Body["fields"]=$Fields
            }

            if ($Urgency) {
                $Body["urgency"]=$Urgency
            }

            if ($TimeZone) {
                $Body["time_zone"]=$PagerDutyCore.ConvertTimeZone($TimeZone)
            }

            if ($SortBy) {
                $SortBy = $SortBy.ToString().Replace(" ","")
                $Uri += "?sort_by=$SortBy"
            }

            $Results = New-Object System.Collections.ArrayList

            if ($PsCmdlet.ShouldProcess("get incidents")) {
                $PagerDutyCore.ApiGet($Uri, $Body, $MaxResults) `
                    | ForEach-Object {$Results.AddRange($_.incidents)}
                $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.Incident')}
                return $Results
            }
        }
    }
}

function Set-PagerDutyIncident {
[CmdletBinding(DefaultParameterSetName="update", SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(
        #One or more incidents, including the parameters to update.
        [Parameter(Mandatory=$true, ParameterSetName="update")]
        $Incidents,

        #The user id of the user making the request. This user's name will be added to the incident log entry. (This is only needed if using token-based authentication.)
        [Parameter(ValueFromPipelineByPropertyName=$true, Mandatory=$true, ParameterSetName="snooze")]
        [string]$IdToSnooze,

        <#
        The number of seconds to snooze the incident for. After this number of seconds has elapsed, the incident will return to the "triggered" state.
        NOTE: Other actions may change the state of the incident after calling this endpoint, preventing the incident from returning to the "triggered" state after the provided timeout. (i.e.: if the incident is resolved before its snooze timeout has elapsed, the incident will not re-enter the "triggered" state when it reaches its timeout.)
        #>
        [Parameter(ValueFromPipelineByPropertyName=$true, Mandatory=$true, ParameterSetName="snooze")]
        [int]$Duration,

        #The user id of the user making the request. This will be added to the incident log entry. This is only needed if you are using token based authentication.
        [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName="update")]
        [Parameter(ValueFromPipelineByPropertyName=$true,ParameterSetName="snooze")]
        [string]$RequesterId
    )

    $Uri = "incidents"

    if ($PsCmdlet.ParameterSetName -eq "Update"){

        if ($Incidents -isnot [System.Collections.ICollection]){
            $Incidents = @($Incidents)
        }

        #TODO: Decide if this needs to be type checked? Would prevent custom objects and hashtables.
            $EscalationRules | Foreach-Object {$PagerDutyCore.VerifyTypeMatch($_, 'PagerDuty.Incident')}

        $Body = @{
            incidents = $Incidents | ConvertTo-Json -Depth 5 -Compress
        }

        if ($RequesterId) {
            $Body["requester_id"] = $RequesterId
        }

        if ($PsCmdlet.ShouldProcess("update incident")) {
        
            $Result = $PagerDutyCore.ApiPut($Uri, $Body)
        
            if ($Result.incidents -ne $null) {

                $Result.incidents | ForEach-Object $_.pstypenames.Insert(0,'PagerDuty.Incident')
                
                return $Result.incidents
        
            } else {
                return $Result
            }
        }
    } else {

        $Uri += "/$IdToSnooze/snooze"

        $Body = @{
            duration = $Duration
        }

        if ($RequesterId) {
            $Body["requester_id"] = $RequesterId
        }

        if ($PsCmdlet.ShouldProcess("update incident")) {
            $Result = $PagerDutyCore.ApiPut($Uri, $Body)
            return $Result
        }
    }
}

function New-PagerDutyIncidentObject {
    Param(
        #The id of the incident to update.
        [Parameter(Mandatory=$true)]
        [string]$Id,

        #The new status of the incident. Possible values are resolved and acknowledged.
        [string]$Status,

        #Escalate incident to this level in the escalation policy.
        [int]$EscalationLevel,

        #Comma separated list of user IDs to assign this incident to.
        [string]$AssignedToUser,

        #Delegate this incident to the specified escalation policy id. This restarts the incident's escalation following the new policy.
        [string]$EscalationPolicyId
    )

    $Body = @{}

    if ($Status) {
        $Body['status'] = $Status
    }

    if ($EscalationLevel) {
        $Body['escalation_level'] = $EscalationLevel
    }
    
    if ($AssignedToUser) {
        $Body['assigned_to_user'] = $AssignedToUser
    }
    
    if ($EscalationPolicyId) {
        $Body['escalation_policy'] = $EscalationPolicyId
    }
    
    if ($Body.Count -eq 0) { 
        throw [System.ArgumentNullException] "Must provide one value to add to the incident object."
    }

    $Body['id'] = $Id

    $Body.pstypenames.Insert(0,'PagerDuty.Incident')

    return $Body
}

function Remove-PagerDutyIncident {

}