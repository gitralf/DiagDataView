
$categoryName=@{}
$categoryDesc=@{}
Get-DiagnosticDataCategories |ForEach-Object {
    $categoryName.Add($_.Id,$_.Name)
    $categoryDesc.add($_.Id,$_.Description)
}

$events = get-content -Path "./events.json" |convertfrom-json 

Get-DiagnosticData -starttime (get-date -hour 0 -minute 0 -second 0).AddDays(-1) -endtime (get-date -hour 0 -minute 0 -second 0) -RequiredTelemetryOnly | foreach-object {
# Get-DiagnosticData -starttime (get-date -hour 0 -minute 0 -second 0).AddDays(-1) -endtime (get-date -hour 0 -minute 0 -second 0) -RequiredTelemetryOnly |out-gridview  -Title "Events (required)" -PassThru |foreach-object {

    $payload=$_.payload | ConvertFrom-Json
    write-output "<table>"
    # "Version: {0}" -f $payload.ver 
    "Eventname: {0}" -f $payload.Name
    "Beschreibung des Events: {0}" -f $events.($payload.Name).eventdescription
    "<table>"

    foreach ($field in ($payload.data | get-member -MemberType NoteProperty | select-object -ExpandProperty Name)){
        "<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>" -f $field,$payload.data.$field,$events.($payload.Name).$field

    }
    # $data=$payload.data
    # $data 

}

