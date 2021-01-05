#CSS
$header=@"
<html>
 <head>
  <title>Diagnostic Data</title>
  <style>
    h1 {
        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;
    }

    h2 {
        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;
    }
    
    table {
        width=100%;
		font-size: 12px;
		border: 0px; 
		font-family: Arial, Helvetica, sans-serif;
	} 
	
    td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}
	
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
	}

    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }
   </style>
  </head>
  <body>
"@

$starttime=(get-date -hour 0 -minute 0 -second 0).AddDays(-1)
$endtime = (get-date -hour 0 -minute 0 -second 0)

$intro="<h1>Events at $env:COMPUTERNAME from $starttime to $endtime</h1>"


$categoryTable="<h1>Diagnostic Data Categories</h1>`n<table>`n<tr><th width=`"5%`">ID</th><th width=`"30%`">Name</th><th width=`"65%`">Description</th></tr>`n"
Get-DiagnosticDataCategories |ForEach-Object {
    $categoryTable+="<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>`n" -f $_.Id,$_.Name,$_.Description
}
$categoryTable+="</table>"


$eventAppearance=@{}
$categoryAppearance=@{}

$events = get-content -Path "./events.json" |convertfrom-json 
$details="<h1>Event-Details</h1>`n"

$counter=0
Get-DiagnosticData -starttime $starttime -endtime $endtime -RequiredTelemetryOnly | foreach-object {
# Get-DiagnosticData -starttime (get-date -hour 0 -minute 0 -second 0).AddDays(-1) -endtime (get-date -hour 0 -minute 0 -second 0) -RequiredTelemetryOnly | foreach-object {
# Get-DiagnosticData -starttime (get-date -hour 0 -minute 0 -second 0).AddDays(-1) -endtime (get-date -hour 0 -minute 0 -second 0) -RequiredTelemetryOnly |out-gridview  -Title "Events (required)" -PassThru |foreach-object {
            
    $counter++
    $eventName=$_.Name
    $eventTime=$_.Timestamp

    foreach ($temp in $_.DiagnosticDataCategories){
        $categoryAppearance[$temp]+="/"+$counter
    }
    
    $eventAppearance[$eventName]+="/"+$counter

    $payload=$_.payload | ConvertFrom-Json
      
    # $details+="<tr style='background-color:#FF0000;color:#FFFFFF'><td><strong>Event {0}</strong></td><td><strong>{1}</strong></td><td colspan=2><strong>created: {2}</strong></td></tr>`n" -f $counter,$eventName,$eventTime
    $details+="<h2>Event {0}: {1} ({2})</h2>`n" -f $counter,$eventName,$eventTime
    $details+="<table width=`"100%`">`n"
    $details+="<tr><th width=`"20%`">Attribute</th><th width=`"40%`">Content</th><th width=`"40%`">Description</th></tr>`n"
    foreach ($field in ($payload.data | get-member -MemberType NoteProperty | select-object -ExpandProperty Name)){
        if ($payload.data.$field.tostring().length -lt 100){
            $eventrow=" <tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>`n" -f $field,$payload.data.$field,$events.($payload.Name).$field
        } else {
            $short="(truncated) "+$payload.data.$field.tostring().substring(0,100)
            $eventrow=" <tr><td>{0}</td><td onmouseover=`"this.innerHTML = '{1}'`" onmouseout=`"this.innerHTML='{2}'`">{2}</td><td>{3}</td></tr>`n" -f $field,$payload.data.$field,$short,$events.($payload.Name).$field
        }
        $details+=$eventrow
    }
    $details+="</table>`n"
}
        
# build EventSummaryTable
$summaryTable="<h1>Summary of $counter events</h1>`n<table>`n<tr><th width=`"5%`">events</th><th width=`"30%`">Event</th><th width=`"65%`">Description</th></tr>`n"
$eventAppearance.keys | sort-object | foreach-object{
    $number=$eventAppearance[$_].split("/").count -1
    $summaryTable+="<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>`n" -f $number,$_,$events.$_.eventdescription
}

$summaryTable+="</table>"

$out="$header $intro $categoryTable $summaryTable $details"

$out | Out-File -FilePath "c:\temp\report.html"