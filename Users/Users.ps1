<#
.SYNOPSIS
    Get one or more users from PagerDuty.

.DESCRIPTION
    Get information about an existing user, get a user object with that user's current on-call status (If the on-call object is an empty array, the user is never on-call) or list users of your PagerDuty account, optionally filtered by a search query. Can include additional info for notication rules and contact info, and limit maximum number of results.

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
    https://developer.pagerduty.com/documentation/rest/users/list
    https://developer.pagerduty.com/documentation/rest/users/show
    https://developer.pagerduty.com/documentation/rest/users/show_on_call
    https://github.com/robcerda60/PagerDuty-PoSh-API-Client
#>
function Get-PagerDutyUser {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(
        #The PagerDuty ID of the user you would like to retrieve.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [string]$Id,

        #A PagerDuty object representing a user.
        [Parameter(Mandatory=$true, ParameterSetName='Obj', ValueFromPipeline=$true)]
        $PagerDutyUser,

        #Retrieve all users in the domain.
        [Parameter(ParameterSetName='All')]
        [switch]$All,

        #Filters the result, showing only the users whose names or email addresses match the query. Does not support wildcards
        [Parameter(ParameterSetName='All')]
        [string]$QueryFilter,
    
        #When pulling multiple results, the maximum number of results you'd like returned.
        [Parameter(ParameterSetName='All')]
        [int]$MaxResults,

        #Include the user's current on-call status. If the on-call object is an empty array, the user is never on-call. If the start and end of an on-call object are null, then the user is always on-call for an escalation policy level.
        [Parameter(ParameterSetName='Id')]
        [Parameter(ParameterSetName='Obj')]
        [switch]$OnCallStatus,

        #Only retrieve the on-call users, along with the on-call information.
        [Parameter(ParameterSetName='All')]
        [switch]$OnCallOnly,

        #Include additional data in results regarding notication rules.
        [Parameter(ParameterSetName='Id')]
        [Parameter(ParameterSetName='Obj')]
        [Parameter(ParameterSetName='All')]
        [switch]$IncludeNotificationRules,

        #Include additional data in results regarding contact methods.
        [Parameter(ParameterSetName='Id')]
        [Parameter(ParameterSetName='Obj')]
        [Parameter(ParameterSetName='All')]
        [switch]$IncludeContactMethods
    )

    $Additions = ""

    if ($IncludeNotificationRules -AND $IncludeContactMethods){
        $Additions = "?include[]=contact_methods&include[]=notification_rules"
    } elseif ($IncludeNotificationRules) {
        $Additions = "?include[]=notification_rules"
    } elseif ($IncludeContactMethods) {
        $Additions = "?include[]=contact_methods"
    }

    if ($PsCmdlet.ParameterSetName -eq "All") {

        $Uri = "users"

        $Results = New-Object System.Collections.ArrayList

        if ($OnCallOnly){
            $Uri += "/on_call"
        }

        $Uri += $Additions

        if ($PsCmdlet.ShouldProcess("users")) {
            $PagerDutyCore.ApiGet($Uri, @{query=$QueryFilter}, $MaxResults) `
                | ForEach-Object {$Results.AddRange($_.users)}
            $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.User')}
            return $Result
        }
        
    } else {

        if ($PsCmdlet.ParameterSetName -eq "Obj"){
            $PagerDutyCore.VerifyTypeMatch($PagerDutyUser, "PagerDuty.User")
            $Id = $PagerDutyUser.id
        }
            
        $PagerDutyCore.VerifyNotNull($Id)

        if ($OnCallStatus) {
            $URI = "users/$id/on_call" + $Additions
        } else {
            $URI = "users/$id" + $Additions
        }

        if ($PsCmdlet.ShouldProcess($Id)) {
            $Result = $PagerDutyCore.ApiGet($URI)
            $Result.user.pstypenames.Insert(0,'PagerDuty.User')
            return $result.user
        }
    }
}

<#
.SYNOPSIS
    Update an existing user.

.DESCRIPTION
    Update an existing user.

.EXAMPLE
    Set-PagerDutyUser -Id "ABCDEF1" -Email "SomeNewEmail@domain.com"

    RESULTS

    time_zone         : Eastern Time (US & Canada)
    color             : brown
    email             : SomeNewEmail@domain.com
    avatar_url        : https://secure.gravatar.com/avatar/<someID1>.png?d=mm&r=PG
    user_url          : /users/ABCDEF1
    invitation_sent   : False    
    role              : user
    name              : Tommy Twotone
    id                : ABCDEF1
    job_title         : Singer

    DESCRIPTION

    In this example we update the email address of the user with an Id of "ABCDEF1"

.EXAMPLE
    Get-PagerDutyUser -QueryFilter tom | Foreach-Object {Set-PagerDutyUser -JobTitle "Songwriter"}

    RESULTS

    time_zone         : Eastern Time (US & Canada)
    color             : brown
    email             : t2tone@domain.com
    avatar_url        : https://secure.gravatar.com/avatar/<someID1>.png?d=mm&r=PG
    user_url          : /users/ABCDEF1
    invitation_sent   : False    
    role              : user
    name              : Tommy Twotone
    id                : ABCDEF1
    job_title         : Songwriter

    DESCRIPTION

    In this example we get one or more users and pipe the results such that each object gets an updated JobTitle.

.INPUTS
    PagerDuty.User

.OUTPUTS
    PagerDuty.User

.LINK
    https://developer.pagerduty.com/documentation/rest/users/update
    https://github.com/robcerda60/PagerDuty-PoSh-API-Client
#>
function Set-PagerDutyUser {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param(
        #The PagerDuty ID of the user you would like to retrieve.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [string]$Id,

        #A PagerDuty object representing a user.
        [Parameter(Mandatory=$true,ParameterSetName='Obj', ValueFromPipeline=$true)]
        $PagerDutyUser,

        #The user's role. This can either be admin, user, or limited_user.
        [Parameter(ParameterSetName='Id')]
        [Parameter(ParameterSetName='Obj')]
        [PagerDuty.RoleTypes]$Role,

        #The name of the user.
        [Parameter(ParameterSetName='Id')]
        [Parameter(ParameterSetName='Obj')]
        [string]$Name,

        #The email of the user.
        [Parameter(ParameterSetName='Id')]
        [Parameter(ParameterSetName='Obj')]
        [string]$Email,

        #The job title of the user.
        [Parameter(ParameterSetName='Id')]
        [Parameter(ParameterSetName='Obj')]
        [string]$JobTitle,

        #The time zone the user is in.
        [Parameter(ParameterSetName='Id')]
        [Parameter(ParameterSetName='Obj')]
        [PagerDuty.TimeZones]$TimeZone
    )
        
    if ($PsCmdlet.ParameterSetName -eq "Obj"){
        $PagerDutyCore.VerifyTypeMatch($PagerDutyUser, "PagerDuty.User")
        $Id = $PagerDutyUser.id
        

        $PagerDutyCore.VerifyNotNull($Id)
    }

    $Body = @{}

    if ($Role -ne $null){
        $Body["role"] = $Role.ToString()
    }

    if ($Name -ne $null){
        $Body["name"] = $Name
    }

    if ($Email -ne $null){
        $Body["email"] = $Email
    }

    if ($JobTitle -ne $null){
        $Body["job_title"] = $JobTitle
    }

    if ($TimeZone -ne $null){
        $Body["time_zone"] = $PagerDutyCore.ConvertTimeZone($TimeZone)
    }

    if ($Body.Count -eq 0) { throw [System.ArgumentNullException] "Must provide one value to update for the user." }

    if ($PsCmdlet.ShouldProcess($Id)) {
        $Result = $PagerDutyCore.ApiPut("users/" + $Id, $Body)
        $Result.user.pstypenames.Insert(0,'PagerDuty.User')
        return $Result.user
    }
}

<#
.SYNOPSIS
    Create a new user.

.DESCRIPTION
    Create a new user for your account. An invite email will be sent asking the user to choose a password.

.EXAMPLE
    New-PagerDutyUser -Name "Jimmy Dean" -Email "TheSahSage@domain.com"

    RESULTS

    time_zone         : Eastern Time (US & Canada)
    color             : brown
    email             : TheSahSage@domain.com
    avatar_url        : https://secure.gravatar.com/avatar/<someID1>.png?d=mm&r=PG
    user_url          : /users/ABCDEF5
    invitation_sent   : True    
    role              : user
    name              : Jimmy Dean
    id                : ABCDEF1
    job_title         : 

    DESCRIPTION

    In this example we create a new user with the email address of "TheSahSage@domain.com" and a name of "Jimmy Dean". The role and timezones are set to defaults and an email is sent out.

.INPUTS
    None

.OUTPUTS
    PagerDuty.User

.LINK
    https://developer.pagerduty.com/documentation/rest/users/create
    https://github.com/robcerda60/PagerDuty-PoSh-API-Client
#>
function New-PagerDutyUser {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param(
        #The user's role. This can either be admin, user, or limited_user and defaults to user if not specified.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.RoleTypes]$Role,

        #The name of the user.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Name,

        #The email of the user. The newly created user will receive an email asking to confirm the subscription.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Email,

        #The job title of the user.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$JobTitle,

        #The time zone the user is in. If not specified, the time zone of the account making the API call will be used.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.TimeZones]$TimeZone,

        #The user id of the user creating the user. This is only needed if you are using token based authentication.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$RequesterId
    )

    $Body = @{}
    $Body["name"] = $Name
    $Body["email"] = $Email

    if ($Role -ne $null){
        $Body["role"] = $Role.ToString()
    }

    if ($JobTitle -ne $null){
        $Body["job_title"] = $JobTitle
    }

    if ($TimeZone -ne $null){
        $Body["time_zone"] = $PagerDutyCore.ConvertTimeZone($TimeZone)
    }

    if ($RequesterId -ne $null){
        $Body["requester_id"] = $RequesterId
    }

    if ($PsCmdlet.ShouldProcess($Name)) {
        $Result = $PagerDutyCore.ApiPost("users/", $Body)
        $Result.user.pstypenames.Insert(0,'PagerDuty.User')
        return $Result.user
    }
}

<#
.SYNOPSIS
    Remove an existing user.

.DESCRIPTION
    Remove an existing user.

.EXAMPLE
    Get-PagerDutyUser -QueryFilter "@olddomain.com" | Foreach-Object { Remove-PagerDutyUser -Force }

    RESULTS

    DESCRIPTION

    In this example we remove any users with an email containing "olddomain.com". The lack of results means it was successful.

.EXAMPLE
    $Results = Remove-PagerDutyUser -Id 123456E -Force; $Results

    RESULTS

    error                                               
    -----                                               
    @{errors=System.Object[]; conflicts=System.Object[]}

    DESCRIPTION

    In this example we try to remove the user but there is a conflict error. We can explore the $Results object for more information on the conflict errors.

.INPUTS
    PagerDuty.User

.OUTPUTS
    None
    PagerDuty Conflict Errors

.LINK
    https://developer.pagerduty.com/documentation/rest/users/delete
    https://github.com/robcerda60/PagerDuty-PoSh-API-Client
#>
function Remove-PagerDutyUser {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param(
        #The PagerDuty ID of the user you would like to delete.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
        [string]$Id,

        #A PagerDuty object representing a user to delete.
        [Parameter(Mandatory=$true, ParameterSetName='Obj', ValueFromPipeline=$true)]
        $PagerDutyUser
    )
        
    if ($PsCmdlet.ParameterSetName -eq "Obj"){
        $PagerDutyCore.VerifyTypeMatch($PagerDutyUser, "PagerDuty.User")
        $Id = $PagerDutyUser.id
    }

    $PagerDutyCore.VerifyNotNull($Id)

    if ($PsCmdlet.ShouldProcess($Name)) {
        $Result = $PagerDutyCore.ApiDelete("users/$Id")
        
        if ($Result -ne $null) {
            $Result.Insert(0,'PagerDuty.Error')
            return $Result.user
        }
    }
}