for($i=1; $i -lt 342;$i++)
{
#$DirToClean = "E:\CFS_PowerShell_LoadServer\Post\Customer"+$i+"\Day1\*"
$DirToClean="E:\CFS_PowerShell_LoadServer\Customer"+$i+"\OrderXMLSInput\*"


#$DirToClean = "c:\Folder"        

Get-ChildItem $DirToClean |    
Sort-Object CreationTime -Descending |    
Select-Object -Skip 7 |    
Remove-Item -exclude Newfolder,"*.png"    

#Read-Host -Prompt "The files have been deleted successfully"
}