for($i=1; $i -lt 344;$i++)
{

$OrderXMLInput = "E:\CFS_PowerShell_LoadServer\Customer"+$i+"\OrderXMLSInput\*"
$OrderXMLToPost = "E:\CFS_PowerShell_LoadServer\Customer"+$i+"\OrderXMLToPost\*"

Remove-Item $OrderXMLInput
Remove-Item $OrderXMLToPost

}