
$categoryName=@{}
$categoryDesc=@{}
Get-DiagnosticDataCategories |ForEach-Object {
    $categoryName.Add($_.Id,$_.Name)
    $categoryDesc.add($_.Id,$_.Description)
}

$events = get-content -Path "./events.json" |convertfrom-json 

Get-DiagnosticData -starttime (get-date).AddDays(-1) -RequiredTelemetryOnly |out-gridview  -Title "Events (required)" -PassThru |foreach-object {

    $payload=$_.payload | ConvertFrom-Json
    write-output "<table>"
    "Version: {0}" -f $payload.ver 
    "Eventname: {0}" -f $payload.Name
    "Beschreibung des Events: {0}" -f $events.($payload.Name).description

    foreach ($field in ($payload.data | get-member -MemberType NoteProperty | select-object -ExpandProperty Name)){
        "  {0} hat den Wert {1} und beschreibt {2}" -f $field,$payload.data.$field,$events.($payload.Name).$field

    }
    # $data=$payload.data
    # $data 

}

