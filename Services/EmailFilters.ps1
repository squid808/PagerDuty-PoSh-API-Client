#TODO: Update Documentation
#TODO: write-in conditional logic for each regex parameter

function Set-PagerDutyEmailFilter {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param (
        #The ID of an existing Pager Duty service.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$ServiceId,

        #The ID of an existing Pager Duty email filter.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Id,

        #One of always, match, no-match, which, respectively, means to not filter the email trigger by subject, filter it if the email subject matches the given regex, or filter if it doesn't match the given regex. Defaults to always.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.EmailFilterMatchType]$SubjectMode,

        #The regex to be used when subject_mode is match or no-match. It is a required parameter on such cases.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$SubjectRegex,

        #One of always, match, no-match, which, respectively, means to not filter the email trigger by body, filter it if the body email matches the given regex, or filter if it doesn't match the given regex. Defaults to always.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.EmailFilterMatchType]$BodyMode,

        #The regex to be used when body_mode is match or no-match. It is a required parameter on such cases.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$BodyRegex,

        #One of always, match, no-match, which, respectively, means to not filter the email trigger by its from address, filter it if the email from address matches the given regex, or filter if it doesn't match the given regex. Defaults to always.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.EmailFilterMatchType]$FromEmailMode,

        #The regex to be used when from_email_mode is match or no-match. It is a required parameter on such cases.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$FromEmailRegex
    )

    $Uri = "services/$ServiceId/email_filters/$Id"

    $Body = @{}

    if ($SubjectMode) { $Body['subject_mode'] = $SubjectMode.ToString() }

    if ($SubjectRegex) { $Body['subject_mode'] = $SubjectRegex }

    if ($BodyMode) { $Body['subject_mode'] = $BodyMode.ToString() }

    if ($BodyRegex) { $Body['subject_mode'] = $BodyRegex }

    if ($FromEmailMode) { $Body['subject_mode'] = $FromEmailMode.ToString() }

    if ($FromEmailRegex) { $Body['subject_mode'] = $FromEmailRegex }

    if ($Body.Count -eq 0) { throw [System.ArgumentNullException] "Must provide one value to update for the user." }

    if ($PsCmdlet.ShouldProcess("set email filter")) {
        $Result = $PagerDutyCore.ApiPut($Uri, $Body)
        $Result.email_filter.pstypenames.Insert(0,'PagerDuty.EmailFilter')
        return $Result.email_filter
    }
}

function New-PagerDutyEmailFilter {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param (
        #The ID of an existing Pager Duty service.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$ServiceId,

        #One of always, match, no-match, which, respectively, means to not filter the email trigger by subject, filter it if the email subject matches the given regex, or filter if it doesn't match the given regex. Defaults to always.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.EmailFilterMatchType]$SubjectMode,

        #The regex to be used when subject_mode is match or no-match. It is a required parameter on such cases.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$SubjectRegex,

        #One of always, match, no-match, which, respectively, means to not filter the email trigger by body, filter it if the body email matches the given regex, or filter if it doesn't match the given regex. Defaults to always.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.EmailFilterMatchType]$BodyMode,

        #The regex to be used when body_mode is match or no-match. It is a required parameter on such cases.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$BodyRegex,

        #One of always, match, no-match, which, respectively, means to not filter the email trigger by its from address, filter it if the email from address matches the given regex, or filter if it doesn't match the given regex. Defaults to always.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.EmailFilterMatchType]$FromEmailMode,

        #The regex to be used when from_email_mode is match or no-match. It is a required parameter on such cases.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$FromEmailRegex
    )

    $Uri = "services/$ServiceId/email_filters"

    $Body = @{}

    if ($SubjectMode) { $Body['subject_mode'] = $SubjectMode.ToString() }

    if ($SubjectRegex) { $Body['subject_mode'] = $SubjectRegex }

    if ($BodyMode) { $Body['subject_mode'] = $BodyMode.ToString() }

    if ($BodyRegex) { $Body['subject_mode'] = $BodyRegex }

    if ($FromEmailMode) { $Body['subject_mode'] = $FromEmailMode.ToString() }

    if ($FromEmailRegex) { $Body['subject_mode'] = $FromEmailRegex }

    if ($PsCmdlet.ShouldProcess("new email filter")) {
        $Result = $PagerDutyCore.ApiPost($Uri, $Body)
        $Result.email_filter.pstypenames.Insert(0,'PagerDuty.EmailFilter')
        return $Result.email_filter
    }
}

function Remove-PagerDutyEmailFilter {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param (
        #The ID of an existing Pager Duty service.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$ServiceId,

        #The ID of an existing Pager Duty email filter.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Id
    )

    $Uri = "services/$ServiceId/email_filters/$Id"

    if ($PsCmdlet.ShouldProcess("remove email filter")) {
        $Result = $PagerDutyCore.ApiDelete($Uri)
        return $Result
    }
}