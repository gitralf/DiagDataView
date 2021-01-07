Param(
    [parameter(mandatory=$false)][string]$inputfile
)

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


write-host "importing CSV file"
$ddv=Import-Csv -Path $inputfile -UseCulture

$outfile="c:\temp\report-ddv.html"

$maxevents=1000

$endtime=$ddv[0].Timestamp
$totalevents=$ddv.length-1
if ($totalevents -gt $maxevents){
    write-host "too much events ($totalevents). Limiting to $maxevents..."
    $totalevents=$maxevents
}
$starttime=$ddv[$totalevents].Timestamp

# "von {0} bis {1}" -f $starttime,$endtime

$intro="<h1>DDV-Events at $env:COMPUTERNAME from $starttime to $endtime</h1>"


# $categoryTable="<h1>Diagnostic Data Categories</h1>`n<table>`n<tr><th width=`"5%`">ID</th><th width=`"30%`">Name</th><th width=`"65%`">Description</th></tr>`n"
# Get-DiagnosticDataCategories |ForEach-Object {
#     $categoryTable+="<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>`n" -f $_.Id,$_.Name,$_.Description
# }
# $categoryTable+="</table>"

# PDT_BrowsingHistory                                 0x0000000000000002u
# PDT_DeviceConnectivityAndConfiguration              0x0000000000000800u
# PDT_InkingTypingAndSpeechUtterance                  0x0000000000020000u
# PDT_ProductAndServicePerformance                    0x0000000001000000u
# PDT_ProductAndServiceUsage                          0x0000000002000000u
# PDT_SoftwareSetupAndInventory                       0x0000000080000000u

# PS C:\WINDOWS\system32> Get-DiagnosticDataCategories | fl *


# Id          : -1
# Name        : Incorrect Data Category
# Description : Event is incorrectly categorized.  Microsoft is working on fixing such events

# Id          : 1
# Name        : Browsing History
# Description : Records of the web browsing history when using the capabilities of the application or cloud service,
#               stored in either the service or the application.

# Id          : 11
# Name        : Device Connectivity and Configuration
# Description : Data that describes the connections and configuration of the devices connected to the service and the
#               network, including device identifiers (e.g. IP addresses) configuration, setting and performance.

# Id          : 17
# Name        : Inking Typing and Speech Utterance
# Description : Record of the input data provided by the end user through an interaction method or action such as
#               inking, typing, speech utterance or gesture.

# Id          : 24
# Name        : Product and Service Performance
# Description : Data collected about the measurement, performance and operation of the capabilities of the product or
#               service.  This data represents information about the capability and its use, with a focus on providing
#               the capabilities of the product or service.

# Id          : 25
# Name        : Product and Service Usage
# Description : Data provided or captured about the end user’s interaction with the service or products by the cloud
#               service provider.  Captured data includes the records of the end user’s preferences and settings for
#               capabilities, the capabilities used and commands provided to the capabilities.

# Id          : 31
# Name        : Software Setup and Inventory
# Description : Data that describes the installation, setup and update of software.

$eventAppearance=@{}
# $categoryAppearance=@{}

$events = get-content -Path "./events.json" |convertfrom-json 
$details="<h1>Event-Details</h1>`n"

$counter=0

$startsec=(Get-date).Timeofday.Totalseconds

foreach ($event in $ddv){
    
    $counter++
    $eventName=$event.FullName
    $eventTime=$event.Timestamp
    
    $completed=100*$counter/$totalevents
    
    if (($counter % 100) -eq 0 ){
        $elapsedsec=(Get-date).Timeofday.Totalseconds - $startsec
        $estimatedsec = (100 * $elapsedsec/$completed)
        $temp=[timespan]::fromseconds($estimatedsec+$startsec)
        $estimatedEnd="{0:hh\:mm\:ss}" -f $temp
        
    }

    Write-Progress -Activity "analyzing $totalevents between $endtime and $starttime" -Status "estimated end time $estimatedEnd" -CurrentOperation "extracting event $counter from $eventtime" -PercentComplete $completed
    
    # This does not show up in DDV, but DDV knows about the category. Why?
    # foreach ($temp in $_.DiagnosticDataCategories){
    #     $categoryAppearance[$temp]+="/"+$counter
    # }
    
    $eventAppearance[$eventName]+="/"+$counter

    $payload=$event.json | ConvertFrom-Json
      
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
    if ($counter -ge $maxevents){
        break
    }
}
        
# build EventSummaryTable
$summaryTable="<h1>Summary of $counter events</h1>`n<table>`n<tr><th width=`"5%`">events</th><th width=`"30%`">Event</th><th width=`"65%`">Description</th></tr>`n"
$eventAppearance.keys | sort-object | foreach-object{
    $number=$eventAppearance[$_].split("/").count -1
    $summaryTable+="<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>`n" -f $number,$_,$events.$_.eventdescription
}

$summaryTable+="</table>"

$out="$header $intro $summaryTable $details"

$out | Out-File -FilePath $outfile