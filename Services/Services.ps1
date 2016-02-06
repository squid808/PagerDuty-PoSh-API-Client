#TODO: Update Documentation

function Get-PagerDutyService {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param (
        
        #The ID for an existing Pager Duty teams.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [string]$Id,

        #A comma-separated list of team IDs, specifying teams whose maintenance windows will be returned.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="All")]
        [string]$Teams,

        #Include extra information in the response. Possible values are escalation_policy (for inline Escalation Policies), email_filters (for inline Email Filters), and teams (for inline Teams).
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="All")]
        [PagerDuty.MaintenanceWindowFilters]$Include,

        #Time zone in which dates in the result will be rendered. Defaults to account default time zone.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="All")]
        [PagerDuty.TimeZones]$TimeZone,

        #Filters the result, showing only the services whose name or service_key matches the query.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="All")]
        [string]$Query,

        <#
        Used to specify both the field you wish to sort the results on. If not specified, this defaults to name.
        - name: The name of the service
        - id: The id of the service
        #>
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="All")]
        [PagerDuty.ServiceSortBy]$SortBy,

        #When pulling multiple results, the maximum number of results you'd like returned.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName="All")]
        [int]$MaxResults
    )
    if ($PsCmdlet.ParameterSetName -eq "Id") {

        $Uri = "services/$Id"

        if ($PsCmdlet.ShouldProcess("get service")) {
            $Result = $PagerDutyCore.ApiGet($Uri)
            $Result.service.pstypenames.Insert(0,'PagerDuty.Service')
            return $Result.service
        }

    } else {

        $Additions = ""

        if ($Include){
            switch ($Include.value__) {
                1 {$Additions = "?include[]=escalation_policy"}
                2 {$Additions = "?include[]=email_filters"}
                3 {$Additions = "?include[]=escalation_policy&include[]=email_filters"}
                4 {$Additions = "?include[]=teams"}
                5 {$Additions = "?include[]=escalation_policy&include[]=teams"}
                6 {$Additions = "?include[]=email_filters&include[]=teams"}
                7 {$Additions = "?include[]=escalation_policy&include[]=email_filters&include[]=teams"}
            }
        }

        $Uri = "services$Additions"

        if ($Teams) {
            $Body['teams'] = $Teams
        }

        if ($TimeZone) {
            $Body['time_zone'] = $TimeZone
        }

        if ($Query) {
            $Body['query'] = $Query
        }

        if ($SortBy) {
            $Body['sort_by'] = $SortBy
        }

        $Results = New-Object System.Collections.ArrayList

        if ($PsCmdlet.ShouldProcess("get schedules")) {
            $PagerDutyCore.ApiGet($Uri, $Body, $MaxResults) `
                | ForEach-Object {$Results.AddRange($_.services)}
            $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.Service')}
            return $Results
        }
    }
}

function Set-PagerDutyService {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param (
        #The ID of an existing Pager Duty service.
        [ParamBinding(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Disable")]
        [ParamBinding(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Enable")]
        [ParamBinding(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [string]$Id,

        #Disable a service. Once a service is disabled, it will not be able to create incidents until it is enabled again.
        [ParamBinding(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Disable")]
        [switch]$SetDisabled,

        #Enable a previously disabled service.
        [ParamBinding(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Enable")]
        [switch]$SetEnabled,

        #Regenerate a new service key for an existing service. Warning! The service's previous key will be invalidated, and existing monitoring integrations will need to be modified to use the new key!
        [ParamBinding(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="RegenerateKey")]
        [switch]$RegenerateKey,

        #The user id of the user creating the maintenance window. This is only needed if you are using token based authentication.
        [ParamBinding(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName="Disable")]
        [string]$RequesterId,

        #The name of the service.
        [ParamBinding(ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [string]$Name,

        #A description for the service. 1024 character maximum.
        [ParamBinding(ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [string]$Description,

        #The id of the escalation policy to be used by this service.
        [ParamBinding(ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [string]$EscalationPolicyId,

        #The duration in seconds before an incidents acknowledged in this service become triggered again.
        [ParamBinding(ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [int]$AcknowledgementTimeout,

        #The duration in seconds before a triggered incident auto-resolves itself.
        [ParamBinding(ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [int]$AutoResolveTimeout,

        <#
        Specifies what severity levels will create a new open incident. For Keynote it can be one of:
        - critical: Incidents are created when an alarm enters the Critical state
        - critical_or_warning: Incidents are created when an alarm enters the Critical OR Warning states
        For SQL Monitor it can be one of:
        - on_any: Incidents are created for alerts of any severity
        - on_high: Incidents are created for alerts with high severity
        - on_medium_high: Incidents are created for with high or medium severity
        #>
        [ParamBinding(ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [PagerDuty.ServiceSeverityFilter]$SeverityFilter,

        #Email specific setting. The service key for the service. Do not specify the domain. e.g. my-service rather than my-service@my-subdomain.pagerduty.com
        [ParamBinding(ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [string]$ServiceKey,

        #Email specific setting. One of only-if-no-open-incidents, on-new-email-subject or on-new-email. Defaults to on-new-email.
        [ParamBinding(ValueFromPipelineByPropertyName=$true, ParameterSetName="Id")]
        [string]$EmailIncidentCreation
    )

    $Uri = "services/$Id"

    if ($PsCmdlet.ParameterSetName -eq "RegenerateKey") {

        $Uri += "/regenerate_key"

        if ($PsCmdlet.ShouldProcess("regenerate service key")) {
            $Result = $PagerDutyCore.ApiPut($Uri)
            $Result.service.pstypenames.Insert(0,'PagerDuty.Service')
            return $Result.service
        }

    } elseif ($PsCmdlet.ParameterSetName -eq "Disable") {

        $Uri += "/disable"

        $Body = @{}

        if ($RequesterId) {
            $Body['requester_id'] = $RequesterId
        }

        if ($PsCmdlet.ShouldProcess("disable service")) {
            $Result = $PagerDutyCore.ApiPut($Uri, $Body)
            return $Result
        }

    } elseif ($PsCmdlet.ParameterSetName -eq "Enable") {

        $Uri += "/enable"

        if ($PsCmdlet.ShouldProcess("enable service")) {
            $Result = $PagerDutyCore.ApiPut($Uri)
            return $Result
        }

    } else {

        $Body = @{}

        if ($Name) {
            $Body['name'] = $Name
        }

        if ($Description) {
            $Body['description'] = $Description
        }

        if ($EscalationPolicyId) {
            $Body['escalation_policy_id'] = $EscalationPolicyId
        }

        if ($AcknowledgementTimeout) {
            $Body['acknowledgement_timeout'] = $AcknowledgementTimeout
        }

        if ($AutoResolveTimeout) {
            $Body['auto_resolve_timeout'] = $AutoResolveTimeout
        }

        if ($SeverityFilter) {
            $Body['severity_filter'] = $SeverityFilter.ToString()
        }

        if ($ServiceKey) {
            $Body['service_key'] = $ServiceKey
        }

        if ($EmailIncidentCreation) {
            $Body['email_incident_creation'] = $EmailIncidentCreation
        }

        if ($Body.Count -eq 0) { throw [System.ArgumentNullException] "Must provide one value to update for the service." }

        if ($PsCmdlet.ShouldProcess("update service")) {
            $Result = $PagerDutyCore.ApiPut($Uri, $Body)
            $Result.service.pstypenames.Insert(0,'PagerDuty.Service')
            return $Result.service
        }
    }
}

function New-PagerDutyService {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param (

        #The name of the service.
        [ParamBinding(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Name,

        #The id of the escalation policy to be used by this service.
        [ParamBinding(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$EscalationPolicyId,

        #The type of service to create. Can be one of generic_email, generic_events_api, integration, keynote, nagios, pingdom or sql_monitor.
        [ParamBinding(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.ServiceType]$Type,

        #PagerDuty's internal vendor identifier for this service. Will only be accepted if the service type is integration. For more information about a specific vendor, please contact PagerDuty Support.
        [ParamBinding(ValueFromPipelineByPropertyName=$true)]
        [string]$VendorId,

        #A description for the service. 1024 character maximum.
        [ParamBinding(ValueFromPipelineByPropertyName=$true)]
        [string]$Description,

        #The duration in seconds before an incidents acknowledged in this service become triggered again.
        [ParamBinding(ValueFromPipelineByPropertyName=$true)]
        [int]$AcknowledgementTimeout,

        #The duration in seconds before a triggered incident auto-resolves itself.
        [ParamBinding(ValueFromPipelineByPropertyName=$true)]
        [int]$AutoResolveTimeout,

        <#
        Specifies what severity levels will create a new open incident. For Keynote it can be one of:
        - critical: Incidents are created when an alarm enters the Critical state
        - critical_or_warning: Incidents are created when an alarm enters the Critical OR Warning states
        For SQL Monitor it can be one of:
        - on_any: Incidents are created for alerts of any severity
        - on_high: Incidents are created for alerts with high severity
        - on_medium_high: Incidents are created for with high or medium severity
        #>
        [ParamBinding(ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.ServiceSeverityFilter]$SeverityFilter,

        #Email specific setting. The service key for the service. Do not specify the domain. e.g. my-service rather than my-service@my-subdomain.pagerduty.com
        [ParamBinding(ValueFromPipelineByPropertyName=$true)]
        [string]$ServiceKey,

        #Email specific setting. One of only-if-no-open-incidents, on-new-email-subject or on-new-email. Defaults to on-new-email.
        [ParamBinding(ValueFromPipelineByPropertyName=$true)]
        [string]$EmailIncidentCreation
    )

    $Uri = "services"

    $Body = @{
        name = $Name
        escalation_policy_id = $EscalationPolicyId
        type = $Type.ToString()
    }

    if ($Type.ToString() -eq "generic_email") {
        if ([string]::IsNullOrEmpty($ServiceKey)){
            throw [System.ArgumentNullException] "Service key must be provided for email services."
        }
    }

    if ($VendorId) {
        $Body['vendor_id'] = $VendorId
    }

    if ($Description) {
        $Body['description'] = $Description
    }

    if ($AcknowledgementTimeout) {
        $Body['acknowledgement_timeout'] = $AcknowledgementTimeout
    }

    if ($AutoResolveTimeout) {
        $Body['auto_resolve_timeout'] = $AutoResolveTimeout
    }

    if ($SeverityFilter) {
        $Body['severity_filter'] = $SeverityFilter.ToString()
    }

    if ($ServiceKey) {
        $Body['service_key'] = $ServiceKey
    }

    if ($EmailIncidentCreation) {
        $Body['email_incident_creation'] = $EmailIncidentCreation
    }

    if ($PsCmdlet.ShouldProcess("create service")) {
        $Result = $PagerDutyCore.ApiPost($Uri, $Body)
        $Result.service.pstypenames.Insert(0,'PagerDuty.Service')
        return $Result.service
    }
}

function Remove-PagerDutyService {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param (
        #The ID of the Pager Duty service to delete.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Id
    )

    $Uri = "services/$Id"

    if ($PsCmdlet.ShouldProcess("remove service")) {
        $Result = $PagerDutyCore.ApiDelete($Uri)
        return $Result
    }
}

Export-ModuleMember Get-PagerDutyService
Export-ModuleMember Set-PagerDutyService
Export-ModuleMember New-PagerDutyService
Export-ModuleMember Remove-PagerDutyService