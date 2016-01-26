$PagerDutySubDomain = 'Netflix'
$Token = Get-Content C:\Admin\Pagerduty\Token.txt
$query = $null

$result = Invoke-RestMethod -Method GET -Uri ('https://' + $PagerDutySubDomain + '.pagerduty.com/api/v1/users' + $query) -ContentType "application/json" -Headers @{"Authorization"=("Token token=" + $Token)}


