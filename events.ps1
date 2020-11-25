
$categoryName=@{}
$categoryDesc=@{}
Get-DiagnosticDataCategories |ForEach-Object {
    $categoryName.Add($_.Id,$_.Name)
    $categoryDesc.add($_.Id,$_.Description)
}

$allEvents=Get-DiagnosticData -starttime (get-date).AddDays(-1) |select-object Name,TimeStamp,isRequired |out-gridview  -Title "Events" -PassThru |foreach-object {

$payload=$_.payload
    write-host $payload 

}
