
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

$runFlag = $true

while($runFlag)
{

#----------------------------------------------------(GET THE QUEUE ID)-----------------------------------------------------------------------

$conn = ConnectMySQL $user $pass $MySQLHost $database
# Read all the records from table
$query = "Select QueueID from importfiledtlscfs where queueIdFlag = 'false' Limit 1"

$QueueID = WriteMySQLQuery $conn $query

#$Value = Write-Host $Rows " Select query ran"
echo("----------------------")
echo("QueueID : "+$QueueID)

if($QueueID -eq $null)
{
	break
}

#---------------------------------------------------(Update the flag value for GUID)--------------------------------------------------------

 
$conn = ConnectMySQL $user $pass $MySQLHost $database
 
# Read all the records from table
$query = "Update plannermailing.importfiledtlscfs set queueIdFlag = 'True' where  QueueID = '$QueueID'"

$Rows = WriteMySQLQuerySetTrue $conn $query
Write-Host $Rows "Updated value as True in Database in importfiledtlscfs Table" 

#----------------------------------------------------(GET THE GUID)-----------------------------------------------------------------------

$conn = ConnectMySQL $user $pass $MySQLHost $database
# Read all the records from table
$query = "Select GUID from importfiledtlscfs where QueueID = '$QueueID'"

$GUID = WriteMySQLQuery $conn $query

#$Value = Write-Host $Rows " Select query ran"
echo("----------------------")
echo("QueueID : "+$GUID)

#----------------------------------------------------(GET THE Customer)-----------------------------------------------------------------------

$conn = ConnectMySQL $user $pass $MySQLHost $database
# Read all the records from table
$query = "Select Customer_Name from importfiledtlscfs where QueueID = '$QueueID'"

$Customer_Name = WriteMySQLQuery $conn $query

#$Value = Write-Host $Rows " Select query ran"
echo("----------------------")
echo("Customer_Name :  "+$Customer_Name)

#----------------------------------------------(Get the Time Taken for Pre-Invoice)-----------------------------------------------------


$SQLServer = "TVDB\MSSQLSERVERNEW" #use Server\Instance for named SQL instances! 
$SQLDBName = "TAYLORCFS"
#$SqlQuery = "select id,instance_id from msg_data WHERE instance_id = '1762'"
#$SqlQuery = "Select instance_id from msg_Data where id = '$QueueID'" 
$SqlQuery = "Select Top 1 DATEDIFF(ss,START_DATETIME,End_DateTIme) from msg_Data where request_Type = 12 and text_Data in (Select INSTANCE_ID from msg_Data where id = '$QueueID')"
 
 
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
#$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName; Integrated Security = True"
$SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName;Integrated Security = False;User ID= TAYLORCFS; Password= TAYLORCFS" 
 
 
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
 
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
 
$DataSet = New-Object System.Data.DataSet
$SqlAdapter.Fill($DataSet)
 
$SqlConnection.Close()
 
echo("-----------------CHECK---------------------------")
# echo($DataSet.Tables[0])
foreach ($row in $DataSet.Tables[0].Rows)

{

$TimeTakenForPreInvoice = $row[0].ToString().Trim()
echo("TimeTakenForInvoice"+$TimeTakenForPreInvoice)

}

	
#---------------------------------------------(PRE-INVOICE TIMINGS INSERTION INTO DB)-------------------------------------------------------------------------------------------------

$fl = $false
$conn = ConnectMySQL $user $pass $MySQLHost $database
	
$query = "INSERT INTO plannermailing.PreInvoiceload(
QueueID,
GUID,
PreInvoiceTime,
Customer_Name
)
VALUES ('$QueueID','$GUID','$TimeTakenForPreInvoice','$Customer_Name')"

$Rows = WriteMySQLQuery $conn $query
Write-Host $Rows " inserted into PreInvoice" 

#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

}