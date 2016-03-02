#TODO: Update Documentation

function Get-PagerDutyContactMethod {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param(
        #The PagerDuty ID of the user whose contact method you would like to retrieve.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [string]$UserId,

        #The PagerDuty ID of a specific contact method you would like to retrieve.
        [Parameter(ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [string]$ContactMethodId,

        #A PagerDuty object representing a contact method.
        [Parameter(Mandatory=$true, ParameterSetName='Obj', ValueFromPipeline=$true)]
        $PagerDutyContactMethod
    )

    if ($PsCmdlet.ParameterSetName -eq "Obj"){
        $PagerDutyCore.VerifyTypeMatch($PagerDutyContactMethod, "PagerDuty.ContactMethod")
        $UserId = $PagerDutyContactMethod.user_id
        $ContactMethodId = $PagerDutyContactMethod.id
        $PagerDutyCore.VerifyNotNull($ContactMethodId)
    }

    $PagerDutyCore.VerifyNotNull($UserId)

    $Uri = "users/$UserId/contact_methods"

    if ($ContactMethodId) {
        $Uri += "/$ContactMethodId"
    }

    if ($PsCmdlet.ShouldProcess($UserId)) {
        $Result = $PagerDutyCore.ApiGet($Uri)

        if ($Result.contact_method -ne $Null) {
            $Result.contact_method.pstypenames.Insert(0,'PagerDuty.ContactMethod')
            return $Result.contact_method
        } else {
            $Results = New-Object System.Collections.ArrayList
            $Results.AddRange($Result.contact_methods)
            $Results | ForEach-Object {$_.pstypenames.Insert(0,'PagerDuty.ContactMethod')}
            return $Results
        }
    }
}

function Set-PagerDutyContactMethod {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param(
        #The PagerDuty ID of the user whose contact method you would like to update.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [string]$UserId,

        #The PagerDuty ID of a specific contact method you would like to update.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [string]$ContactMethodId,

        #A PagerDuty object representing a contact method you would like to update.
        [Parameter(Mandatory=$true, ParameterSetName='Obj', ValueFromPipeline=$true)]
        $PagerDutyContactMethod,

        #The id of the contact method. For SMS and phone it is the number, and for email it is the email address.
        [Parameter(ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Obj')]
        [string]$Address,

        #The number code for your country. Not used for email. Defaults to 1.
        [Parameter(ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Obj')]
        [int]$CountryCode,

        #A human friendly label for the contact method. (ie: "Home Phone", "Work Email", etc.) Defaults to the type of the contact method and the address (with country code for phone numbers).
        [Parameter(ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Obj')]
        [string]$Label,

        #Send an abbreviated email message instead of the standard email output. Useful for email-to-SMS gateways and email based pagers. Only valid for email contact methods. Defaults to false.
        [Parameter(ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [Parameter(ParameterSetName='Obj')]
        [bool]$SendShortEmail
    )

    if ($PsCmdlet.ParameterSetName -eq "Obj"){
        $PagerDutyCore.VerifyTypeMatch($PagerDutyContactMethod, "PagerDuty.ContactMethod")
        $UserId = $PagerDutyContactMethod.user_id
        $ContactMethodId = $PagerDutyContactMethod.id
    }

    $PagerDutyCore.VerifyNotNull($UserId)
    $PagerDutyCore.VerifyNotNull($ContactMethodId)

    $Uri = "users/$UserId/contact_methods/$ContactMethodId"

    $Body = @{}

    if ($Address) {
        $Body["address"] = $Address
    }

    if ($CountryCode) {
        $Body["country_code"] = $CountryCode.ToString()
    }

    if ($Label) {
        $Body["label"] = $Label
    }

    if ($SendShortEmail) {
        $Body["send_short_email"] = $PagerDutyCore.ConvertBoolean($SendShortEmail)
    }

    if ($Body.Count -eq 0) { throw [System.ArgumentNullException] "Must provide one value to update for the contact method." }

    if ($PsCmdlet.ShouldProcess($UserId)) {
        $Result = $PagerDutyCore.ApiPut($Uri, $Body)
        $Result.contact_method.pstypenames.Insert(0,'PagerDuty.ContactMethod')
        return $Result.contact_method
    }
}

function New-PagerDutyContactMethod {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param(
        #The PagerDuty ID of the user for whom you would like to create a contact method.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$UserId,

        #The id of the contact method. For SMS and phone it is the number, and for email it is the email address.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [PagerDuty.ContactMethodsTypes]$Type,

        #The id of the contact method. For SMS and phone it is the number, and for email it is the email address.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [string]$Address,

        #The number code for your country. Not used for email. Defaults to 1.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$CountryCode,

        #A human friendly label for the contact method. (ie: "Home Phone", "Work Email", etc.) Defaults to the type of the contact method and the address (with country code for phone numbers).
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$Label,

        #Send an abbreviated email message instead of the standard email output. Useful for email-to-SMS gateways and email based pagers. Only valid for email contact methods. Defaults to false.
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [bool]$SendShortEmail
    )
    
    $Uri = "users/$UserId/contact_methods"

    $Body = @{
        type = $Type.ToString()
        address = $Address
    }

    if ($CountryCode) {
        $Body["country_code"] = $CountryCode.ToString()
    }

    if ($Label) {
        $Body["label"] = $Label
    }

    if ($SendShortEmail) {
        $Body["send_short_email"] = $PagerDutyCore.ConvertBoolean($SendShortEmail)
    }

    if ($PsCmdlet.ShouldProcess($UserId)) {
        $Result = $PagerDutyCore.ApiPost($Uri, $Body)
        $Result.contact_method.pstypenames.Insert(0,'PagerDuty.ContactMethod')
        return $Result.contact_method
    }
}

function Remove-PagerDutyContactMethod {
[CmdletBinding(DefaultParameterSetName="Id", SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param(
        #The PagerDuty ID of the user whose contact method you would like to delete.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [string]$UserId,

        #The PagerDuty ID of the contact method you would like to delete.
        [Parameter(Mandatory=$true, ParameterSetName='Id', ValueFromPipelineByPropertyName=$true)]
        [string]$ContactMethodId,

        #A PagerDuty object representing a contact method to delete.
        [Parameter(Mandatory=$true, ParameterSetName='Obj', ValueFromPipeline=$true)]
        $PagerDutyContactMethod
    )
        
    if ($PsCmdlet.ParameterSetName -eq "Obj"){
        $PagerDutyCore.VerifyTypeMatch($PagerDutyContactMethod, "PagerDuty.ContactMethod")
        $UserId = $PagerDutyContactMethod.user_id
        $ContactMethodId = $PagerDutyContactMethod.id
    }

    $PagerDutyCore.VerifyNotNull($UserId)
    $PagerDutyCore.VerifyNotNull($ContactMethodId)

    if ($PsCmdlet.ShouldProcess($UserId)) {
        $Result = $PagerDutyCore.ApiDelete("users/$UserId/contact_methods/$NotificationRuleId")
		return $Result.user
    }
}

Export-ModuleMember Get-PagerDutyContactMethod
Export-ModuleMember Set-PagerDutyContactMethod
Export-ModuleMember New-PagerDutyContactMethod
Export-ModuleMember Remove-PagerDutyContactMethod