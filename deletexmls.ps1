for($1=1; $1 -le 5; $1++){

$OrderImportOutput = $currentExecutingPath +$l +"\OrderImportOutput\*"
$OrderImport = $currentExecutingPath+$l + "\OrderImport\*"
$InputXML = $currentExecutingPath+$l + "\InputXML\*"
$OutPutXML = $currentExecutingPath+$l + "\OutPutXML\*"
$OrderXMLToPost = $currentExecutingPath+$l + "\OrderXMLToPost\*"

Remove-Item $OrderImportOutput
Remove-Item $OrderImport
Remove-Item $InputXML
Remove-Item $OutPutXML
Remove-Item $OrderXMLToPost
}