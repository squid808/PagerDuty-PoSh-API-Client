$PagerDutyEnums = "
namespace PagerDuty
{
    public enum ServiceType
    { generic_email, generic_events_api, integration, keynote, nagios, pingdom, sql_monitor }

    public enum ServiceSeverityFilter
    { critical, critical_or_warning, on_any, on_high, on_medium_high }

    [System.FlagsAttribute]
    public enum ServiceSortBy
    { name, id }

    [System.FlagsAttribute]
    public enum ServiceIncludes
    { escalation_policy=1, email_filters=2, teams=4 }

    public enum ScheduleRestrictionType
    { daily, weekly }

    public enum ReportRollupType
    { daily, weekly, monthly }

    public enum ReportType
    { alerts_per_time, incidents_per_time }

    public enum MaintenanceWindowFilters
    { past, future, ongoing }

    [System.FlagsAttribute]
    public enum UserIncludes
    { contact_methods=1, notification_rules=2 }

    [System.FlagsAttribute]
    public enum LogEntryIncludes
    { channel=1, incident=2, service=4 }

    [System.FlagsAttribute]
    public enum IncidentSortBy
    { incident_number=1, created_on=2, resolved_on=4, urgency=8 }

    [System.FlagsAttribute]
    public enum IncidentStatusTypes
    { triggered=1, acknowledged=2, resolved=4 }

    public enum RoleTypes
    { admin, user, limited_user }

    public enum ContactMethodsTypes
    { SMS, email, phone }

    public enum AlertFilterTypes
    { SMS, Email, Phone, Push }

    public enum EscalationRuleTargetType
    { schedule, user }

    /*
    Define the time zones as an enum with all special characters removed so they
    can be called as an argument in Cmdlets where the user can choose from a
    list generated from autocomplete. Then put the enum in to the dictionary to
    get the actual string required for the API with special characters.
    */
    public enum TimeZones
    {
        Abu_Dhabi,Adelaide,Alaska,Almaty,American_Samoa,Amsterdam,Arizona,Astana,Athens,Atlantic_Time_Canada,Auckland,Azores,
        Baghdad,Baku,Bangkok,Beijing,Belgrade,Berlin,Bern,Bogota,Brasilia,Bratislava,Brisbane,Brussels,Bucharest,Budapest,
        Buenos_Aires,Cairo,Canberra,Cape_Verde_Is,Caracas,Casablanca,Central_America,Central_Time_US_and_Canada,Chennai,
        Chihuahua,Chongqing,Copenhagen,Cuiaba,Darwin,Dhaka,Dublin,Eastern_Time_US_and_Canada,Edinburgh,Ekaterinburg,Fiji,
        Georgetown,Greenland,Guadalajara,Guam,Hanoi,Harare,Hawaii,Helsinki,Hobart,Hong_Kong,Indiana_East,
        International_Date_Line_West,Irkutsk,Islamabad,Istanbul,Jakarta,Jerusalem,Kabul,Kamchatka,Karachi,Kathmandu,Kolkata,
        Krasnoyarsk,Kuala_Lumpur,Kuwait,Kyiv,La_Paz,Lima,Lisbon,Ljubljana,London,Madrid,Magadan,Marshall_Is,Mazatlan,Melbourne,
        Mexico_City,Mid_Atlantic,Midway_Island,Minsk,Monrovia,Monterrey,Moscow,Mountain_Time_US_and_Canada,Mumbai,Muscat,
        Nairobi,New_Caledonia,New_Delhi,Newfoundland,Novosibirsk,Nuku_alofa,Osaka,Pacific_Time_US_and_Canada,Paris,Perth,
        Port_Moresby,Prague,Pretoria,Quito,Rangoon,Riga,Riyadh,Rome,Samoa,Santiago,Sapporo,Sarajevo,Saskatchewan,Seoul,
        Singapore,Skopje,Sofia,Solomon_Is,Sri_Jayawardenepura,St_Petersburg,Stockholm,Sydney,Taipei,Tallinn,Tashkent,Tbilisi,
        Tehran,Tijuana,Tokelau_Is,Tokyo,UTC,Ulaan_Bataar,Urumqi,Vienna,Vilnius,Vladivostok,Volgograd,Warsaw,Wellington,
        West_Central_Africa,Yakutsk,Yerevan,Zagreb
    }

}
"

Add-Type -TypeDefinition $PagerDutyEnums -Language CSharpVersion3

Remove-Variable PagerDutyEnums


$PagerDutyTimeZoneDict = New-Object 'System.Collections.Generic.Dictionary[[PagerDuty.TimeZones],[System.String]]'

$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Abu_Dhabi,"Abu Dhabi")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Adelaide,"Adelaide")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Alaska,"Alaska")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Almaty,"Almaty")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::American_Samoa,"American Samoa")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Amsterdam,"Amsterdam")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Arizona,"Arizona")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Astana,"Astana")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Athens,"Athens")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Atlantic_Time_Canada,"Atlantic Time (Canada)")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Auckland,"Auckland")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Azores,"Azores")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Baghdad,"Baghdad")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Baku,"Baku")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Bangkok,"Bangkok")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Beijing,"Beijing")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Belgrade,"Belgrade")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Berlin,"Berlin")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Bern,"Bern")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Bogota,"Bogota")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Brasilia,"Brasilia")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Bratislava,"Bratislava")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Brisbane,"Brisbane")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Brussels,"Brussels")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Bucharest,"Bucharest")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Budapest,"Budapest")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Buenos_Aires,"Buenos Aires")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Cairo,"Cairo")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Canberra,"Canberra")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Cape_Verde_Is,"Cape Verde Is.")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Caracas,"Caracas")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Casablanca,"Casablanca")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Central_America,"Central America")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Central_Time_US_and_Canada,"Central Time (US & Canada)")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Chennai,"Chennai")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Chihuahua,"Chihuahua")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Chongqing,"Chongqing")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Copenhagen,"Copenhagen")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Cuiaba,"Cuiaba")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Darwin,"Darwin")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Dhaka,"Dhaka")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Dublin,"Dublin")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Eastern_Time_US_and_Canada,"Eastern Time (US & Canada)")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Edinburgh,"Edinburgh")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Ekaterinburg,"Ekaterinburg")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Fiji,"Fiji")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Georgetown,"Georgetown")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Greenland,"Greenland")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Guadalajara,"Guadalajara")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Guam,"Guam")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Hanoi,"Hanoi")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Harare,"Harare")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Hawaii,"Hawaii")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Helsinki,"Helsinki")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Hobart,"Hobart")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Hong_Kong,"Hong Kong")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Indiana_East,"Indiana (East)")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::International_Date_Line_West,"International Date Line West")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Irkutsk,"Irkutsk")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Islamabad,"Islamabad")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Istanbul,"Istanbul")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Jakarta,"Jakarta")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Jerusalem,"Jerusalem")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Kabul,"Kabul")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Kamchatka,"Kamchatka")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Karachi,"Karachi")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Kathmandu,"Kathmandu")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Kolkata,"Kolkata")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Krasnoyarsk,"Krasnoyarsk")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Kuala_Lumpur,"Kuala Lumpur")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Kuwait,"Kuwait")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Kyiv,"Kyiv")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::La_Paz,"La Paz")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Lima,"Lima")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Lisbon,"Lisbon")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Ljubljana,"Ljubljana")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::London,"London")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Madrid,"Madrid")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Magadan,"Magadan")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Marshall_Is,"Marshall Is.")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Mazatlan,"Mazatlan")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Melbourne,"Melbourne")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Mexico_City,"Mexico City")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Mid_Atlantic,"Mid-Atlantic")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Midway_Island,"Midway Island")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Minsk,"Minsk")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Monrovia,"Monrovia")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Monterrey,"Monterrey")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Moscow,"Moscow")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Mountain_Time_US_and_Canada,"Mountain Time (US & Canada)")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Mumbai,"Mumbai")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Muscat,"Muscat")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Nairobi,"Nairobi")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::New_Caledonia,"New Caledonia")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::New_Delhi,"New Delhi")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Newfoundland,"Newfoundland")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Novosibirsk,"Novosibirsk")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Nuku_alofa,"Nuku'alofa")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Osaka,"Osaka")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Pacific_Time_US_and_Canada,"Pacific Time (US & Canada)")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Paris,"Paris")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Perth,"Perth")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Port_Moresby,"Port Moresby")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Prague,"Prague")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Pretoria,"Pretoria")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Quito,"Quito")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Rangoon,"Rangoon")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Riga,"Riga")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Riyadh,"Riyadh")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Rome,"Rome")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Samoa,"Samoa")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Santiago,"Santiago")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Sapporo,"Sapporo")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Sarajevo,"Sarajevo")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Saskatchewan,"Saskatchewan")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Seoul,"Seoul")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Singapore,"Singapore")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Skopje,"Skopje")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Sofia,"Sofia")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Solomon_Is,"Solomon Is.")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Sri_Jayawardenepura,"Sri Jayawardenepura")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::St_Petersburg,"St. Petersburg")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Stockholm,"Stockholm")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Sydney,"Sydney")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Taipei,"Taipei")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Tallinn,"Tallinn")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Tashkent,"Tashkent")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Tbilisi,"Tbilisi")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Tehran,"Tehran")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Tijuana,"Tijuana")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Tokelau_Is,"Tokelau Is.")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Tokyo,"Tokyo")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::UTC,"UTC")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Ulaan_Bataar,"Ulaan Bataar")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Urumqi,"Urumqi")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Vienna,"Vienna")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Vilnius,"Vilnius")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Vladivostok,"Vladivostok")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Volgograd,"Volgograd")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Warsaw,"Warsaw")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Wellington,"Wellington")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::West_Central_Africa,"West Central Africa")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Yakutsk,"Yakutsk")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Yerevan,"Yerevan")
$PagerDutyTimeZoneDict.Add([PagerDuty.TimeZones]::Zagreb,"Zagreb")