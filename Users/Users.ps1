function Get-PagerDutyUser {
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
    
        [Parameter(ParameterSetName='One')]
        [string]$Id,

        [Parameter(ParameterSetName='OneObj')]
        $PagerDutyUser,

        [Parameter(ParameterSetName='All')]
        [string]$QueryFilter,
    
        [Parameter(ParameterSetName='All')]
        [int]$MaxResults,

        [Parameter(ParameterSetName='One')]
        [Parameter(ParameterSetName='OneObj')]
        [Parameter(ParameterSetName='All')]
        [switch]$IncludeNotificationRules,

        [Parameter(ParameterSetName='One')]
        [Parameter(ParameterSetName='OneObj')]
        [Parameter(ParameterSetName='All')]
        [switch]$IncludeContactMethods
    )

    $PDC = Get-PagerDutyCore

    $Additions = ""

    if ($IncludeNotificationRules -AND $IncludeContactMethods){
        $Additions = "?include[]=contact_methods&include[]=notification_rules"
    } elseif ($IncludeNotificationRules) {
        $Additions = "?include[]=notification_rules"
    } elseif ($IncludeContactMethods) {
        $Additions = "?include[]=contact_methods"
    }

    if ($PsCmdlet.ParameterSetName -eq "All") {

        $Result = New-Object System.Collections.ArrayList

        $PDC.ApiGet("users" + $Additions, @{query=$QueryFilter}, $MaxResults) | ForEach-Object {$Result.AddRange($_.users)}

        $Result | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.User')}

        return $Result
        
    } else {

        if ($PsCmdlet.ParameterSetName -eq "OneObj"){
            $PDC.VerifyTypeMatch($PagerDutyUser, "PagerDuty.User")
            $Id = $PagerDutyUser.id
            $PDC.VerifyNotNull($Id)
        }

        if ($Id -ne $null){
            $Result = $PDC.ApiGet("users/$id" + $Additions)
            $Result.user.pstypenames.Insert(0,'PagerDuty.User')
            return $result.user
        }
    }
}

$PagerDutyUserClass = New-Object psobject -Property @{
    role = $null
    name = $null
    email = $null
    job_title = $null
    time_zone = $null
    requester_id = $null
}

$PagerDutyUserClass.pstypenames.Insert(0,'PagerDuty.User')