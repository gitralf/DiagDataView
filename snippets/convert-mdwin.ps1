#convert the MD file from here:
# https://github.com/MicrosoftDocs/windows-docs-pr/blob/master/windows/privacy/required-windows-diagnostic-data-events-and-fields-2004.md

$mdfile=get-content -Path .\required.md

$lineMax=$mdfile.Length
write-host $lineMax
# $lineMax=400
write-host $lineMax
$lineNr=0

do {
    $lineNr++

    if ($mdfile[$lineNr] -match "^ms.author:\ (.*)$"){
        $json="{`n    `"info`": {`n"
        $json+="        `"author`": `""+$Matches[1]+"`""
    }
    if ($mdfile[$lineNr] -match "^ms.date:\ (.*)$"){
        $json+=",`n        `"filedate`": `""+$Matches[1]+"`""
    }

    if ($mdfile[$lineNr] -match "^### (.*)$"){
        write-host "Topic: ",$Matches[1]
        $json+="`n    },`n    `""+$Matches[1]+"`": {`n"
        $lineNr++
        $lineNr++
        $desctopic=$mdfile[$lineNr].replace('"',"'")
        $desctopic=$desctopic.replace("\","/")
        $json+="        `"eventdescription`": `""+$desctopic+"`""
    } 

    if ($mdfile[$lineNr] -match "^\- \*\*([^\*]+)\*\*\s+(\S.*$)"){
#   - **Beschreibung**  This is a demo line
        $desc=$Matches[2].replace('"',"'")
        $desc=$desc.replace("\","/")
        $json+=",`n        `""+$Matches[1]+"`": `""+$desc+"`""
    }
} while ($lineNr -lt $lineMax)

$json+="`n    }`n}"
$json | Out-File -filepath ".\events.json"