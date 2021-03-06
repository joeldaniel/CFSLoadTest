
$MySQLHost= "localhost" 
$user= "root" 
$pass= "" 
$database= "plannermailing" 

function ConnectMySQL([string]$user,[string]$pass,[string]$MySQLHost,[string]$database)
{

  # Load MySQL .NET Connector Objects
  [void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")

  # Open Connection
  $connStr = "server=" + $MySQLHost + ";port=3306;uid=" + $user + ";pwd=" + $pass + ";database="+$database+";Pooling=FALSE"
  $conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr)
  $conn.Open()
  $cmd = New-Object MySql.Data.MySqlClient.MySqlCommand("USE $database", $conn)
  return $conn

}

function WriteMySQLQuery($conn, [string]$query) {

  $command = $conn.CreateCommand()
  $command.CommandText = $query
  $Reader = $Command.ExecuteReader()
    while ($Reader.Read()) {
         $val = $Reader.GetValue($1)
    }
	return $val
	$Reader.close()
}


function WriteMySQLQuerySetTrue($conn, [string]$query) {

  $command = $conn.CreateCommand()
  $command.CommandText = $query
  $RowsInserted = $command.ExecuteNonQuery()
  $command.Dispose()
  if ($RowsInserted) {
    return $RowInserted
  } else {
    return $false
  }
}


while($true)
{

#----------------------------------------------(SELECT FILENAME FROM SUMMARYWATCH DOG)-----------------------------------------------------------------------
#---------------------------------------------------------(GUID VALUE 1)-----------------------------------------------------------------------

$conn = ConnectMySQL $user $pass $MySQLHost $database
# Read all the records from table
$query = "Select FileName from summarywatchdog where ResponseFlag='False' Limit 1"
#$query = "Call RespFlagUpdate" 
echo("------I am Running------")
$Value1 = WriteMySQLQuery $conn $query
if($Value1 -ne $null)
{
$GUIDValue1 = $Value1 -replace ".summary.log", ""

echo("----------------------")
echo("GUID "+$GUIDValue1)
echo("Value "+$Value1)

#---------------------------------------------(UPDATE THE VALUE OF FLAG IN SUMMARY WATCH DOG)-----------------------------------------------------------------------
 
$conn = ConnectMySQL $user $pass $MySQLHost $database
 
# Read all the records from table
$query = "Update plannermailing.summarywatchdog set ResponseFlag = 'True' where  FileName = '$Value1'"

$Rows = WriteMySQLQuerySetTrue $conn $query
Write-Host $Rows "Updated value as True in Database in summarywatchdog Table" 

$args= $GUIDValue1,$Value1

Start-Job -FilePath E:\CFS_PowerShell_LoadServer\ImportSummaryValidation_Threads.ps1 -ArgumentList $args

#Start-Job -FilePath D:\CFS_PowerShell_LoadServer\ShippingAlternateNoticexml.ps1

#Start-Job -FilePath D:\CFS_PowerShell_LoadServer\ShippingNoticexml.ps1 
}
}
#---------------------------------------------------------(GUID VALUE 2)-----------------------------------------------------------------------

#$conn = ConnectMySQL $user $pass $MySQLHost $database
## Read all the records from table
#$query = "Select FileName from summarywatchdog where ResponseFlag='False' Limit 1"
##$query = "Call RespFlagUpdate" 
#echo("------I am Running------")
#$Value2 = WriteMySQLQuery $conn $query
#if($Value2 -ne $null)
#{
#$GUIDValue2 = $Value2 -replace ".summary.log", ""
#
##$Value = Write-Host $Rows " Select query ran"
#echo("----------------------")
#echo("GUID "+$GUIDValue2)
#
##---------------------------------------------(UPDATE THE VALUE OF FLAG IN SUMMARY WATCH DOG)-----------------------------------------------------------------------
# 
#$conn = ConnectMySQL $user $pass $MySQLHost $database
# 
## Read all the records from table
#$query = "Update plannermailing.summarywatchdog set ResponseFlag = 'True' where  FileName = '$Value2'"
#
#$Rows = WriteMySQLQuerySetTrue $conn $query
#Write-Host $Rows "Updated value as True in Database in summarywatchdog Table" 
#
#
#$args= $GUIDValue2,$Value2
#
#$J = start-job -filepath D:\CFS_PowerShell_LoadServer\ImportSummaryValidation_Threads.ps1 -ArgumentList $args
#
#Start-Job -FilePath D:\CFS_PowerShell_LoadServer\ShippingAlternateNoticexml.ps1
#Start-Job -FilePath D:\CFS_PowerShell_LoadServer\ShippingNoticexml.ps1 
#
#}
##---------------------------------------------------------(GUID VALUE 3)-----------------------------------------------------------------------
#
#$conn = ConnectMySQL $user $pass $MySQLHost $database
## Read all the records from table
#$query = "Select FileName from summarywatchdog where ResponseFlag='False' Limit 1"
##$query = "Call RespFlagUpdate" 
#echo("------I am Running------")
#$Value3 = WriteMySQLQuery $conn $query
#if($Value3 -ne $null)
#{
#$GUIDValue3 = $Value3 -replace ".summary.log", ""
#
##$Value = Write-Host $Rows " Select query ran"
#echo("----------------------")
#echo("GUID "+$GUIDValue3)
#
##---------------------------------------------(UPDATE THE VALUE OF FLAG IN SUMMARY WATCH DOG)-----------------------------------------------------------------------
# 
# $conn = ConnectMySQL $user $pass $MySQLHost $database
#
# 
## Read all the records from table
#$query = "Update plannermailing.summarywatchdog set ResponseFlag = 'True' where  FileName = '$Value3'"
#
#$Rows = WriteMySQLQuerySetTrue $conn $query
#Write-Host $Rows "Updated value as True in Database in summarywatchdog Table" 
#
#
#$args= $GUIDValue3,$Value3
#
#$J = start-job -filepath D:\CFS_PowerShell_LoadServer\ImportSummaryValidation_Threads.ps1 -ArgumentList $args
#
#Start-Job -FilePath D:\CFS_PowerShell_LoadServer\ShippingAlternateNoticexml.ps1
#Start-Job -FilePath D:\CFS_PowerShell_LoadServer\ShippingNoticexml.ps1 
#
#}
##---------------------------------------------------------(GUID VALUE 4)-----------------------------------------------------------------------
#
#$conn = ConnectMySQL $user $pass $MySQLHost $database
## Read all the records from table
#$query = "Select FileName from summarywatchdog where ResponseFlag='False' Limit 1"
##$query = "Call RespFlagUpdate" 
#echo("------I am Running------")
#$Value4 = WriteMySQLQuery $conn $query
#if($Value4 -ne $null)
#{
#$GUIDValue4 = $Value4 -replace ".summary.log", ""
#
##$Value = Write-Host $Rows " Select query ran"
#echo("----------------------")
#echo("GUID "+$GUIDValue4)
#
##---------------------------------------------(UPDATE THE VALUE OF FLAG IN SUMMARY WATCH DOG)-----------------------------------------------------------------------
# 
#$conn = ConnectMySQL $user $pass $MySQLHost $database
# 
## Read all the records from table
#$query = "Update plannermailing.summarywatchdog set ResponseFlag = 'True' where  FileName = '$Value4'"
#
#$Rows = WriteMySQLQuerySetTrue $conn $query
#Write-Host $Rows "Updated value as True in Database in summarywatchdog Table" 
#
#
#$args= $GUIDValue4,$Value4
#
#$J = start-job -filepath D:\CFS_PowerShell_LoadServer\ImportSummaryValidation_Threads.ps1 -ArgumentList $args
#
#Start-Job -FilePath D:\CFS_PowerShell_LoadServer\ShippingAlternateNoticexml.ps1
#Start-Job -FilePath D:\CFS_PowerShell_LoadServer\ShippingNoticexml.ps1 
#
#}
#
#Start-Sleep -s 30
#
#}