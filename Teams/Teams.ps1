#TODO: Update Documentation

function Get-PagerDutyTeam {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(
        #The Id of an existing Pager Duty team.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [string]$Id,

        #Retrieve all teams.
        [Parameter(Mandatory=$true, ParameterSetName='All', ValueFromPipelineByPropertyName=$true)]
        [switch]$All,

        #Filters the result, showing only the teams whose names match the query.
        [Parameter(ParameterSetName='All', ValueFromPipelineByPropertyName=$true)]
        [string]$Query,

        #When pulling multiple results, the maximum number of results you'd like returned.
        [Parameter(ParameterSetName='All', ValueFromPipelineByPropertyName=$true)]
        [int]$MaxResults
    )
    
    if ($PsCmdlet.ParameterSetName -eq "Id") {

        $Uri = "teams/$Id"

        if ($PsCmdlet.ShouldProcess("get team")) {
            $Result = $PagerDutyCore.ApiGet($Uri)
            $Result.team.pstypenames.Insert(0,'PagerDuty.Team')
            return $Result.team
        }
    } else {
        
        $Uri = "teams"

        $Body = @{}

        if ($Query) {
            $Body['query'] = $Query
        }

        $Results = New-Object System.Collections.ArrayList

        if ($PsCmdlet.ShouldProcess("get teams")) {
            $PagerDutyCore.ApiGet($Uri, $Body, $MaxResults) `
                | ForEach-Object {$Results.AddRange($_.teams)}
            $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.Team')}
            return $Results
        }
    }
}

function Set-PagerDutyTeam {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param (

        #The Id of an existing Pager Duty team.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Id,

        #The name of the team.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$Name,

        #A description of the team.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$Description
    )

    $Uri = "teams/$Id"

    $Body = @{}

    if ($Name) {
        $Body['name'] = $Name
    }

    if ($Description) {
        $Body['description'] = $Description
    }

    if ($Body.Count -eq 0) { throw [System.ArgumentNullException] "Must provide one value to update for the team." }

    if ($PsCmdlet.ShouldProcess("set team")) {
        $Result = $PagerDutyCore.ApiPut($Uri, $Body)
        $Result.team.pstypenames.Insert(0,'PagerDuty.Team')
        return $Result.team
    }
}

function New-PagerDutyTeam {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param (

        #The name of the team.
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName=$true)]
        [string]$Name,

        #A description of the team.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$Description
    )

    $Uri = "teams"

    $Body = @{
        name = $Name
    }

    if ($Description) {
        $Body['description'] = $Description
    }

    if ($PsCmdlet.ShouldProcess("new team")) {
        $Result = $PagerDutyCore.ApiPost($Uri, $Body)
        $Result.team.pstypenames.Insert(0,'PagerDuty.Team')
        return $Result.team
    }
}

function Remove-PagerDutyTeam {
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param (
        #The Id of an existing Pager Duty team.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Id
    )

    $Uri = "teams/$Id"

    if ($PsCmdlet.ShouldProcess("remove team")) {
        $Result = $PagerDutyCore.ApiDelete($Uri)
        return $Result
    }
}