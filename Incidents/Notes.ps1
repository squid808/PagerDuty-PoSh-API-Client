#TODO: Update Documentation

function Get-PagerDutyIncidentNote {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(
        #The ID of an existing Pager Duty incident.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$IncidentId
    )

    $Uri = "incidents/$IncidentId/notes"

    $Results = New-Object System.Collections.ArrayList

    if ($PsCmdlet.ShouldProcess("Get incident notes")) {
        $PagerDutyCore.ApiGet($Uri) `
            | ForEach-Object {$Results.AddRange($_.notes)}
        $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.IncidentNote')}
        return $Results
    }
}


function New-PagerDutyIncidentNote {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param(
        #The ID of an existing Pager Duty incident.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$IncidentId,

        #The note content.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Note,

        #The user id of the user making the request. This is only needed if you are using token based authentication.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$RequesterId
    )

    $Uri = "incidents/$IncidentId/notes"

    $Body = @{
        note = @{content = $Note}
    }

    if ($RequesterId) {
        $Body['requester_id'] = $RequesterId
    }

    if ($PsCmdlet.ShouldProcess("New incident note")) {
        $Result = $PagerDutyCore.ApiPost($Uri, $Body)
        $Result.note.pstypenames.Insert(0,'PagerDuty.IncidentNote')
        return $Result.note
    }
}

Export-ModuleMember Get-PagerDutyIncidentNote
Export-ModuleMember New-PagerDutyIncidentNote