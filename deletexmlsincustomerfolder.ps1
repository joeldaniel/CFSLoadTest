for($i=1; $i -le 172; $i++){
$currentExecutingPath='E:\CFS_PowerShell_LoadServer\Customer'
$OrderImportOutput = $currentExecutingPath +$i +'\OrderImportOutput\*'
$OrderImport = $currentExecutingPath+$i + '\OrderImport\*'
$InputXML = $currentExecutingPath+$i + '\InputXML\*'
$OutPutXML = $currentExecutingPath+$i + '\OutPutXML\*'
$OrderXMLInput = $currentExecutingPath+$i+'\OrderXMLSInput\*'
$OrderXMLToPost = $currentExecutingPath+$i + '\OrderXMLToPost\*'

Remove-Item $OrderImportOutput
Remove-Item $OrderImport
Remove-Item $InputXML
Remove-Item $OutPutXML
Remove-Item $OrderXMLInput
Remove-Item $OrderXMLToPost
}
