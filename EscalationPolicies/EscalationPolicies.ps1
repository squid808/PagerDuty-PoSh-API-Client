#TODO: Update Documentation
#TODO: Add Psuedo-types to nested result objects

function Get-PagerDutyEscalationPolicy {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(
        #The ID of the escalation policy.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [string]$Id,

        #Retrieve all escalation policies.
        [Parameter(Mandatory=$true, ParameterSetName='All')]
        [switch]$All,

        #List all the existing escalation policies with currently on-call users.
        [Parameter(Mandatory=$true, ParameterSetName='OnCall')]
        [switch]$OnCallOnly,

        #A PagerDuty object representing an escalation policy.
        [Parameter(Mandatory=$true, ParameterSetName='Obj', ValueFromPipeline=$true)]
        $PagerDutyEscalationPolicy,

        #Filters the result, showing only the escalation policies whose names match the query.
        [Parameter(ParameterSetName='OnCall')]
        [Parameter(ParameterSetName='All')]
        [string]$Query,

        #A comma-separated list of team IDs, specifying teams whose maintenance windows will be returned.
        [Parameter(ParameterSetName='All')]
        [string]$Teams,

        #Include extra information in the response.
        [Parameter(ParameterSetName='All')]
        [switch]$IncludeTeamsInResponse,

        #When pulling multiple results, the maximum number of results you'd like returned.
        [Parameter(ParameterSetName='All')]
        [int]$MaxResults
    )

    $Uri = "escalation_policies"

    if ($PsCmdlet.ParameterSetName -eq "OnCall") {
        
        $Uri += "/on_call"

        $Body = @{}

        if ($Query) {
            $Body['query'] = $Query
        }
        
        if ($PsCmdlet.ShouldProcess("get on-call escalation policies")) {
            $PagerDutyCore.ApiGet($Uri, $Body, $MaxResults) `
                | ForEach-Object {$Results.AddRange($_.escalation_policies)}
            $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.EscalationPolicy')}
            return $Results
        }
        
    } elseif ($PsCmdlet.ParameterSetName -eq "All") {

        if ($IncludeTeamsInResponse) {
            $Uri += "?include[]=teams"
        }

        $Body = @{}

        if ($Query) {
            $Body['query'] = $Query
        }

        if ($Teams) {
            $Body['teams'] = $Teams
        }

        $Results = New-Object System.Collections.ArrayList

        if ($PsCmdlet.ShouldProcess("get escalation policies")) {
            $PagerDutyCore.ApiGet($Uri, $Body, $MaxResults) `
                | ForEach-Object {$Results.AddRange($_.escalation_policies)}
            $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.EscalationPolicy')}
            return $Results
        }
        
    } else {

        if ($PsCmdlet.ParameterSetName -eq "Obj"){
            $PagerDutyCore.VerifyTypeMatch($PagerDutyEscalationPolicy, "PagerDuty.EscalationPolicy")
            $Id = $PagerDutyEscalationPolicy.id
        }
            
        $PagerDutyCore.VerifyNotNull($Id)

        $Uri += "/$Id"

        if ($PsCmdlet.ShouldProcess("get escalation policies")) {
            $Result = $PagerDutyCore.ApiGet($Uri)
            $Result.escalation_policy.pstypenames.Insert(0,'PagerDuty.User')
            return $Result.escalation_policy
        }
    }
}

function Set-PagerDutyEscalationPolicy {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param(
        #The ID of the escalation policy.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [string]$Id,

        #A PagerDuty object representing a notification rule to delete.
        [Parameter(Mandatory=$true, ParameterSetName='Obj', ValueFromPipeline=$true)]
        $PagerDutyEscalationPolicy,

        #The name of the escalation policy.
        [Parameter(ParameterSetName='Id', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Obj')]
        [string]$Name,

        #Whether or not to allow this policy to repeat its escalation rules after the last rule is finished.
        [Parameter(ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Obj')]
        [bool]$RepeatEnabled,

        #The number of times to loop over the set of rules in this escalation policy.
        [Parameter(ParameterSetName='Id',ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Obj')]
        [int]$NumLoops,

        #The escalation rules for this policy. There must be at least one rule to create a new escalation policy.
        [Parameter(ParameterSetName='Id')]
        [Parameter(ParameterSetName='Obj')]
        $EscalationRules
    )

    if ($PsCmdlet.ParameterSetName -eq "Obj"){
        $PagerDutyCore.VerifyTypeMatch($PagerDutyEscalationPolicy, "PagerDuty.NotificationRule")
        $Id = $PagerDutyEscalationPolicy.id
        $Name = $PagerDutyEscalationPolicy.name
        $NumLoops = $PagerDutyEscalationPolicy.num_loops
        $EscalationRules = $PagerDutyEscalationPolicy.escalation_rules
    }

    $Body = @{}

    if ($Name) {
        $Body["name"] = $Name
    }

    if ($RepeatEnabled) {
        $Body["repeat_enabled"] = $PagerDutyCore.ConvertBoolean($RepeatEnabled)
    }

    if ($NumLoops) {
        $Body["num_loops"] = $NumLoops.ToString()
    }

    if ($EscalationRules) {
        if ($EscalationRules -isnot [System.Collections.ICollection]){
            $EscalationRules = @($EscalationRules)
        }

        #TODO: Decide if this needs to be type checked? Would prevent custom objects and hashtables.
        $EscalationRules | Foreach-Object {$PagerDutyCore.VerifyTypeMatch($_, 'PagerDuty.EscalationRule')}

        $Body["escalation_rules"] = $EscalationRules | ConvertTo-Json -Depth 5 -Compress
    }

    $Uri = "escalation_policies/"

    if ($PsCmdlet.ShouldProcess("New Escalation Policy")) {
        $Result = $PagerDutyCore.ApiPut($Uri, $Body)
        $Result.escalation_policy.Insert(0,'PagerDuty.EscalationPolicy')
        return $Result.escalation_policy
    }
}

function New-PagerDutyEscalationPolicy {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param(
        #The name of the escalation policy.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Name,

        #Whether or not to allow this policy to repeat its escalation rules after the last rule is finished. Defaults to false.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [bool]$RepeatEnabled,

        #The number of times to loop over the set of rules in this escalation policy.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$NumLoops,

        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        #The escalation rules for this policy. There must be at least one rule to create a new escalation policy.
        $EscalationRules
    )

    $Body = @{
        name = $Name
    }

    if ($EscalationRules -isnot [System.Collections.ICollection]){
        $EscalationRules = @($EscalationRules)
    }

    #TODO: Decide if this needs to be type checked? Would prevent custom objects and hashtables.
    $EscalationRules | Foreach-Object {$PagerDutyCore.VerifyTypeMatch($_, 'PagerDuty.EscalationRule')}

    $Body["escalation_rules"] = $EscalationRules | ConvertTo-Json -Depth 5 -Compress

    if ($RepeatEnabled) {
        $Body["repeat_enabled"] = $PagerDutyCore.ConvertBoolean($RepeatEnabled)
    }

    if ($NumLoops) {
        $Body["num_loops"] = $NumLoops.ToString()
    }

    if ($PsCmdlet.ShouldProcess("New Escalation Policy")) {
        $Result = $PagerDutyCore.ApiPost("escalation_policies", $Body)
        $Result.escalation_policy.Insert(0,'PagerDuty.EscalationPolicy')
        return $Result.escalation_policy
    }
}

function Remove-PagerDutyEscalationPolicy {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param(
        #The ID of the escalation policy.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [string]$Id,

        #A PagerDuty object representing an escalation policy to delete.
        [Parameter(Mandatory=$true, ParameterSetName='Obj', ValueFromPipeline=$true)]
        $PagerDutyEscalationPolicy
    )

    if ($PsCmdlet.ParameterSetName -eq "Obj"){
        $PagerDutyCore.VerifyTypeMatch($PagerDutyEscalationPolicy, "PagerDuty.EscalationPolicy")
        $Id = $PagerDutyEscalationPolicy.id
    }

    $PagerDutyCore.VerifyNotNull($Id)

    $Uri = "escalation_policies/$Id"

    if ($PsCmdlet.ShouldProcess("Remove Escalation Policy")) {
        $Result = $PagerDutyCore.ApiDelete($Uri)
        return $Result
    }
}