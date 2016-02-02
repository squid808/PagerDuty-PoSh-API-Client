#TODO: Update Documentation
#TODO: Add Psuedo-types to nested result objects

function Get-PagerDutyEscalationPolicy {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(
        #The ID of the escalation policy.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [string]$Id,

        #A PagerDuty object representing an escalation policy.
        [Parameter(Mandatory=$true, ParameterSetName='Obj', ValueFromPipeline=$true)]
        $PagerDutyEscalationPolicy,

        #Retrieve all escalation policies.
        [Parameter(Mandatory=$true, ParameterSetName='All')]
        [switch]$All,

        #Filters the result, showing only the escalation policies whose names match the query.
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

    if ($PsCmdlet.ParameterSetName -eq "All") {

        if ($IncludeTeamsInResponse) {
            $Uri += "?include[]=teams"
        }

        $Body = @{}

        if ($Query -ne $Null) {
            $Body['query'] = $Query
        }

        if ($Teams -ne $Null) {
            $Body['teams'] = $Teams
        }

        $Results = New-Object System.Collections.ArrayList

        if ($PsCmdlet.ShouldProcess("escalation policies")) {
            $PagerDutyCore.ApiGet($Uri, $Body, $MaxResults) `
                | ForEach-Object {$Results.AddRange($_.escalation_policies)}
            $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.EscalationPolicy')}
            return $Result
        }
        
    } else {

        if ($PsCmdlet.ParameterSetName -eq "Obj"){
            $PagerDutyCore.VerifyTypeMatch($PagerDutyEscalationPolicy, "PagerDuty.EscalationPolicy")
            $Id = $PagerDutyEscalationPolicy.id
        }
            
        $PagerDutyCore.VerifyNotNull($Id)

        $Uri += "/$Id"

        if ($PsCmdlet.ShouldProcess($Id)) {
            $Result = $PagerDutyCore.ApiGet($Uri)
            $Result.escalation_policy.pstypenames.Insert(0,'PagerDuty.User')
            return $result.escalation_policy
        }
    }


}