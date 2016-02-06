# PagerDuty API Client for PowerShell

This project will serve as a PowerShell wrapper of the [PagerDuty API](https://developer.pagerduty.com/).

Version 0.9 - This project is largly untested, use at your own risk. Documentation and in-line help to follow.

To download, click the 'Download ZIP' button on this main page, and extract your files to the modules folder. Then run PowerShell and run ```Import-Module PagerDuty```.

Or, run the following script in PowerShell which will do all of that for you and will unload the module in your user Modules folder:

```
Add-Type -assembly “system.io.compression.filesystem”
$Dest = $env:USERPROFILE + "\Documents\WindowsPowerShell\Modules\PagerDuty"
if (-not (test-path $Dest)) { New-Item -Path $Dest -ItemType Directory } | Out-Null
Invoke-WebRequest "https://github.com/robcerda60/PagerDuty-PoSh-API-Client/archive/master.zip" -OutFile "$Dest\GitSrc.zip"
[io.compression.zipfile]::ExtractToDirectory("$Dest\GitSrc.zip", $Dest)
gci -Path "$Dest\PagerDuty-PoSh-API-Client-master" -Recurse | Move-Item -Destination $Dest
Remove-Item ("$Dest\GitSrc.zip") -Force
Remove-Item ("$Dest\PagerDuty-PoSh-API-Client-master") -Force
```

The first time you run any cmdlet you will be asked to input your API key and your subdomain. This will be saved in a JSON file in the same folder as the rest of the PagerDuty module` files.

The following Cmdlets are accessible once you import the module:
----
Get-PagerDutyAlert
Get-PagerDutyContactMethod
Get-PagerDutyEscalationPolicy
Get-PagerDutyEscalationRule
Get-PagerDutyIncident
Get-PagerDutyIncidentNote
Get-PagerDutyLogEntry
Get-PagerDutyMaintenanceWindow
Get-PagerDutyNotificationRule
Get-PagerDutyReport
Get-PagerDutySchedule
Get-PagerDutyScheduleOverride
Get-PagerDutyService
Get-PagerDutyTeam
Get-PagerDutyUser

New-PagerDutyContactMethod
New-PagerDutyEmailFilter
New-PagerDutyEscalationPolicy
New-PagerDutyEscalationRule
New-PagerDutyEscalationRuleObject
New-PagerDutyEscalationRuleTargetObject
New-PagerDutyIncidentNote
New-PagerDutyIncidentObject
New-PagerDutyMaintenanceWindow
New-PagerDutyNotificationRule
New-PagerDutySchedule
New-PagerDutyScheduleLayerObject
New-PagerDutyScheduleOverride
New-PagerDutyScheduleRestrictionObject
New-PagerDutyScheduleUserEntryObject
New-PagerDutyService
New-PagerDutyTeam
New-PagerDutyUser

Remove-PagerDutyContactMethod
Remove-PagerDutyEmailFilter
Remove-PagerDutyEscalationPolicy
Remove-PagerDutyEscalationRule
Remove-PagerDutyMaintenanceWindow
Remove-PagerDutyNotificationRule
Remove-PagerDutySchedule
Remove-PagerDutyScheduleOverride
Remove-PagerDutyService
Remove-PagerDutyTeam
Remove-PagerDutyUser

Set-PagerDutyContactMethod
Set-PagerDutyEscalationPolicy
Set-PagerDutyEscalationRule
Set-PagerDutyIncident
Set-PagerDutyMaintenanceWindow
Set-PagerDutyNotificationRule
Set-PagerDutySchedule
Set-PagerDutyService
Set-PagerDutyTeam
Set-PagerDutyUser