$PagerDutyUserClass = New-Object psobject -Property @{
    role = $null
    name = $null
    email = $null
    job_title = $null
    time_zone = $null
    requester_id = $null
}
$PagerDutyUserClass.pstypenames.Insert(0,'PagerDuty.User')

<#
.SYNOPSIS
    Get one or more users from PagerDuty.

.DESCRIPTION
    Get one or more users from PagerDuty. Can include additional info for notication rules and contact info, and limit maximum number of results.

.EXAMPLE
    Get-PagerDutyUser -QueryFilter "Tom" -MaxResults 5

    RESULTS

    id                : ABCDEF1
    name              : Tommy Twotone
    email             : t2tone@domain.com
    time_zone         : Eastern Time (US & Canada)
    color             : brown
    role              : user
    avatar_url        : https://secure.gravatar.com/avatar/<someID1>.png?d=mm&r=PG
    billed            : True
    user_url          : /users/ABCDEF1
    invitation_sent   : False
    marketing_opt_out : True
    job_title         : Singer

    id                : ABCDEF2
    name              : Rob Tommas
    email             : mtchbx20@domain.com
    time_zone         : Eastern Time (US & Canada)
    color             : red
    role              : admin
    avatar_url        : https://secure.gravatar.com/avatar/<someID2>.png?d=mm&r=PG
    billed            : True
    user_url          : /users/ABCDEF2
    invitation_sent   : False
    marketing_opt_out : True
    job_title         : Musician

    DESCRIPTION

    In this example we search for any person with "Tom" in the username or email, to a maximum of 5.


.EXAMPLE
    Get-PagerDutyUser -Id "ABCDEF2" -IncludeNotificationRules -IncludeContactMethods

    RESULTS

    id                : ABCDEF2
    name              : Rob Tommas
    email             : mtchbx20@domain.com
    time_zone         : Eastern Time (US & Canada)
    color             : red
    role              : admin
    avatar_url        : https://secure.gravatar.com/avatar/<someID2>.png?d=mm&r=PG
    billed            : True
    user_url          : /users/ABCDEF2
    invitation_sent   : False
    marketing_opt_out : True
    contact_methods   : {@{id=ABCDEF4; label=Default; 
                        address=person@domain.com; type=email; user_id=ABCDEF4; 
                        email=otherperson@domain.com; send_short_email=False}}
    notification_rules: {@{id=ABCDEF3; start_delay_in_minutes=0; 
                        created_at=2013-01-11T11:00:00-07:00; contact_method=; 
                        urgency=high}...}
    job_title         : Musician

    DESCRIPTION

    In this example we get a single known user including their contact methods and notification rules.

.INPUTS
    PagerDuty.User

.OUTPUTS
    PagerDuty.User

.LINK
    https://developer.pagerduty.com/documentation/rest/users
    https://github.com/robcerda60/PagerDuty-PoSh-API-Client
#>
function Get-PagerDutyUser {
    [CmdletBinding(DefaultParameterSetName="All")]
    Param(
    
        #The PagerDuty ID of the user you would like to retrieve.
        [Parameter(ParameterSetName='One')]
        [string]$Id,

        #A PagerDuty object representing a user. Must have the id populated and accurate.
        [Parameter(ParameterSetName='OneObj')]
        $PagerDutyUser,

        #Filters the result, showing only the users whose names or email addresses match the query. Does not support wildcards
        [Parameter(ParameterSetName='All')]
        [string]$QueryFilter,
    
        #When pulling multiple results, the maximum number of results you'd like returned.
        [Parameter(ParameterSetName='All')]
        [int]$MaxResults,

        #Include additional data in results regarding notication rules.
        [Parameter(ParameterSetName='One')]
        [Parameter(ParameterSetName='OneObj')]
        [Parameter(ParameterSetName='All')]
        [switch]$IncludeNotificationRules,

        #Include additional data in results regarding contact methods.
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

function Set-PagerDutyUser {

}

function Add-PagerDutyUser {
    
}
