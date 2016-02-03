#TODO: Update Documentation

function Get-PagerDutyEscalationRule {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(
        #The ID of the escalation policy.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$EscalationPolicyId,

        #The ID of the escalation rule.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$EscalationRuleId
    )

    $Uri = "escalation_policies/$EscalationPolicyId/escalation_rules"

    if ($EscalationRuleId -ne $null) {
        $Uri += "/$EscalationRuleId"
    }

    if ($PsCmdlet.ShouldProcess("Get Escalation Rule")) {
        $Result = $PagerDutyCore.ApiGet($Uri)

        if ($Result.escalation_rule -ne $Null) {
            $Result.escalation_rule.Insert(0,'PagerDuty.EscalationRule')
            return $Result.escalation_rule
        } else {
            $Results = New-Object System.Collections.ArrayList
            $Results.AddRange($Result.escalation_rules)
            $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.EscalationRule')}
            return $Results
        }
    }
}

function Set-PagerDutyEscalationRule {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param(
        #The ID of an existing escalation policy.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='Id')]
        [Parameter(Mandatory=$true, ParameterSetName='All')]
        [string]$EscalationPolicyId,

        #The ID of an existing escalation rule.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='Id')]
        [string]$EscalationRuleId,

        #The escalation timeout in minutes. If an incident is not acknowledged within this timeout then it will escalate onto the next escalation rule.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='Id')]
        [int]$EscalationDelayInMinutes,

        #The target or the array of the targets an incident should be assigned to upon reaching this rule. Parameters detailed below.
        [Parameter(ValueFromPipelineByPropertyName=$true, ParameterSetName='Id')]
        $Targets,

        [Parameter(Mandatory=$true, ParameterSetName='All')]
        #An ordered array of the entire collection of escalation rules for an existing escalation policy.
        $EscalationRules
    )

    $Uri = "escalation_policies/$EscalationPolicyId/escalation_rules"

    if ($PsCmdlet.ParameterSetName -eq "All") {
        
        if ($EscalationRules -isnot [System.Collections.ICollection]){
            $EscalationRules = @($EscalationRules)
        }

        $Body = @{
            escalation_rules = $AllEscalationRules | ConvertTo-Json -Depth 5 -Compress
        }

        if ($PsCmdlet.ShouldProcess("Set Multi Escalation Rule")) {
            $Result = $PagerDutyCore.ApiPut($Uri)
            $Result.escalation_rules | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.EscalationRule')}
            return $Result.escalation_rules
        }

    } else {
        $Uri += "/$EscalationRuleId"

        $Body = @{}

        if ($EscalationDelayInMinutes -ne $null) {
            $Body["escalation_delay_in_minutes"] = $EscalationDelayInMinutes.ToString()
        }

        if ($Targets -ne $null) {
            if ($Targets -isnot [System.Collections.ICollection]){
                $Targets = @($Targets)
            }

            #TODO: Decide if this needs to be type checked? Would prevent custom objects and hashtables.
            $Targets | Foreach-Object {$PagerDutyCore.VerifyTypeMatch($_, 'PagerDuty.EscalationRuleTarget')}

            $Body["targets"] = $Targets | ConvertTo-Json -Depth 5 -Compress
        }

        if ($Body.Count -eq 0) { throw [System.ArgumentNullException] "Must provide one value to update for the escalation rule." }

        if ($PsCmdlet.ShouldProcess("Set Escalation Rule")) {
            $Result = $PagerDutyCore.ApiPut($Uri)
            $Result.escalation_rule.pstypenames.Insert(0,'PagerDuty.EscalationRule')
            return $Result.escalation_rule
        }
    }
}

function New-PagerDutyEscalationRule {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param(
        #The ID of an existing escalation policy.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$EscalationPolicyId,

        #The escalation timeout in minutes. Must be at least 5 if the rule has multiple targets, and at least 1 if not. If an incident is not acknowledged within this timeout then it will escalate onto the next escalation rule.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [int]$EscalationDelayInMinutes,

        #The target or the array of the targets an incident should be assigned to upon reaching this rule. Parameters detailed below.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        $Targets
    )

    $Uri = "escalation_policies/$EscalationPolicyId/escalation_rules"

    if ($Targets -isnot [System.Collections.ICollection]){
        $Targets = @($Targets)
    }

    #TODO: Decide if this needs to be type checked? Would prevent custom objects and hashtables.
    $Targets | Foreach-Object {$PagerDutyCore.VerifyTypeMatch($_, 'PagerDuty.EscalationRuleTarget')}

    $Body = @{
        escalation_delay_in_minutes = $EscalationDelayInMinutes.ToString()
        targets = $Targets | ConvertTo-Json -Depth 5 -Compress
    }

    if ($PsCmdlet.ShouldProcess("New Escalation Rule")) {
        $Result = $PagerDutyCore.ApiPost($Uri)
        $Result.escalation_rule.pstypenames.Insert(0,'PagerDuty.EscalationRule')
        return $Result.escalation_rule
    }
}

function New-PagerDutyEscalationRuleObject {
    Param(
        #The escalation timeout in minutes. If an incident is not acknowledged within this timeout then it will escalate onto the next escalation rule.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [int]$EscalationDelayInMinutes,

        #The target or the array of the targets an incident should be assigned to upon reaching this rule. Parameters detailed below.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        $Targets,

        #The optional ID of an existing escalation rule.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$Id
    )

    if ($Targets -isnot [System.Collections.ICollection]){
        $Targets = @($Targets)
    }

    #TODO: Decide if this needs to be type checked? Would prevent custom objects and hashtables.
    $Targets | Foreach-Object {$PagerDutyCore.VerifyTypeMatch($_, 'PagerDuty.EscalationRuleTarget')}

    if ($Id -ne $Null) {
        $Result = New-Object psobject -Property @{
            Id = $Id
            escalation_delay_in_minutes = $EscalationDelayInMinutes.ToString()
            targets = $Targets
        }
    } else {
        $Result = New-Object psobject -Property @{
            escalation_delay_in_minutes = $EscalationDelayInMinutes.ToString()
            targets = $Targets
        }
    }

    $Result.pstypenames.Insert(0,'PagerDuty.EscalationRule')

    return $Result
}

New-Alias -Name New-PDERO -Value New-PagerDutyEscalationRuleObject

function New-PagerDutyEscalationRuleTargetObject {
    Param(
        #A string of either schedule or user.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.EscalationRuleTargetType]$Type,

        #The id of the schedule or user assigned to this rule.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Id
    )

    $Result = New-Object psobject -Property @{
        type = $Type.ToString()
        id = $Id
    }

    $Result.pstypenames.Insert(0,'PagerDuty.EscalationRuleTarget')

    return $Result
}

New-Alias -Name New-PDERTO -Value New-PagerDutyEscalationRuleTargetObject

function Remove-PagerDutyEscalationRule {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param(
        #The ID of an existing escalation policy.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='Id')]
        [Parameter(Mandatory=$true, ParameterSetName='All')]
        [string]$EscalationPolicyId,

        #The ID of an existing escalation rule.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, ParameterSetName='Id')]
        [string]$EscalationRuleId,

        #A PagerDuty object representing an escalation rule to delete.
        [Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName='All')]
        $PagerDutyEscalationRule
    )

    if ($PsCmdlet.ParameterSetName -eq "Obj"){
        $PagerDutyCore.VerifyTypeMatch($PagerDutyEscalationRule, "PagerDuty.EscalationRule")
        $EscalationRuleId = $PagerDutyEscalationRule.id
    }

    $PagerDutyCore.VerifyNotNull($EscalationRuleId)

    $Uri = "escalation_policies/$EscalationPolicyId/escalation_rules/$EscalationRuleId"

    if ($PsCmdlet.ShouldProcess("Remove Escalation Rule")) {
        $Result = $PagerDutyCore.ApiDelete($Uri)
        if ($Result -ne $null) {
            return $Result
        }
    }
}