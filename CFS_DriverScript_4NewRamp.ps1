############  Get the directory details ###################
$date = Get-Date -format "yyyy-MM-dd HH:mm:ss"

$fullPathIncFileName = $MyInvocation.MyCommand.Definition
$currentScriptName = $MyInvocation.MyCommand.Name
$currentExecutingPath = $fullPathIncFileName.Replace($currentScriptName, "")
############  Get the directory details ###################
############  Get the XML Template Path ###################
$OutputFile = $currentExecutingPath + "XMLTemplates\PlaceExternalSystemOrderV1.xml"
####Clear folders ###############


####Clear folders ###############
############  Get the XML Template Path ###################

Get-Job -State "Completed" | Remove-Job
Get-Job | Stop-Job
Get-job | Remove-Job
############  Get the XML Template Path ###################
$CustomerFilesPath = $currentExecutingPath + "Customers\Customers.txt"
$src = Get-Content $CustomerFilesPath

$i=5
$TimetoExecute = 15
$TimetoExecuteImportSummaryValidation = 50

### Truncate the Table 
##====================
$server= "localhost" 
$username= "root" 
$password= "" 
$database= "plannermailing" 
## The path will need to match the mysql connector you downloaded  
[void][system.reflection.Assembly]::LoadWithPartialName("MySQL.Data")  
function global:Set-SqlConnection ( $server = $(Read-Host "SQL Server Name"), $username = $(Read-Host "Username"), $password = $(Read-Host "Password"), $database = $(Read-Host "Default Database") ) {  
     $SqlConnection.ConnectionString = "server=$server;user id=$username;password=$password;database=$database;pooling=false;Allow Zero Datetime=True;" 
}  

function global:Get-SqlDataTable( $Query = $(if (-not ($Query -gt $null)) {Read-Host "Query to run"}) ) {  

     if (-not ($SqlConnection.State -like "Open")) { $SqlConnection.Open() }  
     $SqlCmd = New-Object MySql.Data.MySqlClient.MySqlCommand $Query, $SqlConnection 
     $SqlAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter  
     $SqlAdapter.SelectCommand = $SqlCmd 
     $DataSet = New-Object System.Data.DataSet  
     $SqlAdapter.Fill($DataSet) | Out-Null 
     $SqlConnection.Close()  
     return $DataSet.Tables[0]  
 }  

Set-Variable SqlConnection (New-Object MySql.Data.MySqlClient.MySqlConnection) -Scope Global -Option AllScope -Description "Personal variable for Sql Query functions" 
Set-SqlConnection $server $username $password $database 
$mysqltest = Get-SqlDataTable 'SHOW STATUS' 
#$global:Query = "TRUNCATE TABLE cfsdetails" 
#$mysqlresults = Get-SqlDataTable $Query 
$global:Query = "TRUNCATE TABLE importfiledtlscfs" 
$mysqlresults = Get-SqlDataTable $Query
#$global:Query = "TRUNCATE TABLE importsummarydetails" 
#$mysqlresults = Get-SqlDataTable $Query
$global:Query = "TRUNCATE TABLE orderxml2ordersummary_validation" 
$mysqlresults = Get-SqlDataTable $Query
$global:Query = "TRUNCATE TABLE summarywatchdog" 
$mysqlresults = Get-SqlDataTable $Query
$global:Query = "TRUNCATE TABLE responsetimeofordersumm" 
$mysqlresults = Get-SqlDataTable $Query
$global:Query = "TRUNCATE TABLE planneriddtls" 
$mysqlresults = Get-SqlDataTable $Query
$global:Query = "TRUNCATE TABLE shippmentresponseflag" 
$mysqlresults = Get-SqlDataTable $Query
$global:Query = "TRUNCATE TABLE foundationxmldtls" 
$mysqlresults = Get-SqlDataTable $Query
$global:Query = "TRUNCATE TABLE summarywatchdogplannerjobxml" 
$mysqlresults = Get-SqlDataTable $Query
$global:Query = "TRUNCATE TABLE jobxmlresponsetime" 
$mysqlresults = Get-SqlDataTable $Query
$global:Query = "TRUNCATE TABLE returnxmlresponsetime" 
$mysqlresults = Get-SqlDataTable $Query
$global:Query = "TRUNCATE TABLE summarywatchdogresponsexml" 
$mysqlresults = Get-SqlDataTable $Query
$global:Query = "TRUNCATE TABLE summarywatchdogreturnxml" 
$mysqlresults = Get-SqlDataTable $Query



$TimeexeFinal = [System.DateTime]::Now
echo("Order Getting Placed")
echo($TimeexeFinal)
##====================
### Truncate the Table
foreach ($l in $src) {
 Write-Host $l
 $ts = (Get-Date -format yyyy-MM-dd_HH-mm-ss); 
 
 $args= $l,$TimetoExecute,$currentExecutingPath
 
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

 $J = start-job -filepath D:\CFS_PowerShell_LoadServer\UploadChunksBinaryNew4Ramp.ps1 -ArgumentList $args
 
 echo($l)
 echo("TimetoExecute : "+$TimetoExecute)
 	
} 
 #$J = start-job -filepath D:\CFS_PowerShell_LoadServer\WatchFolderDogScript.ps1 -ArgumentList $args
 #$J = start-job -filepath D:\CFS_PowerShell_LoadServer\ImportSummaryValidation_4.ps1 -ArgumentList $TimetoExecuteImportSummaryValidation
 echo("TimetoExecuteImportSummaryValidation : "+$TimetoExecuteImportSummaryValidation)
 
  $J = start-job -filepath D:\CFS_PowerShell_LoadServer\ThreadMainScript.ps1 

#$J = start-job -filepath D:\CFS_PowerShell_LoadServer\ImportSummaryValidation_1.ps1 -ArgumentList $TimetoExecuteImportSummaryValidation
#$J = start-job -filepath D:\CFS_PowerShell_LoadServer\ImportSummaryValidation_1.ps1 -ArgumentList $TimetoExecuteImportSummaryValidation
#$J = start-job -filepath D:\CFS_PowerShell_LoadServer\ImportSummaryValidation_1.ps1 -ArgumentList $TimetoExecuteImportSummaryValidation
#$J = start-job -filepath D:\CFS_PowerShell_LoadServer\ImportSummaryValidation_1.ps1 -ArgumentList $TimetoExecuteImportSummaryValidation

 $J = start-job -filepath D:\CFS_PowerShell_LoadServer\JobXmlResponseTime.ps1
 
 $J = start-job -filepath D:\CFS_PowerShell_LoadServer\ReturnXmlResponseTime.ps1