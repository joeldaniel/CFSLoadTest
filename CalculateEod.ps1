
$SQLServer = "TVDB\MSSQLSERVERNEW" #use Server\Instance for named SQL instances! 
$SQLDBName = "TAYLORCFS"
#$SqlQuery = "select id,instance_id from msg_data WHERE instance_id = '1762'"
$SqlQuery = "SELECT COUNT(*) FROM SHIPPING S JOIN DESTIN D ON D.ISSUEID = S.ISSUEID AND D.DESTID = S.DESTID WHERE S.PlantId = 1 
		AND S.OrderThirdPartyStatusCode = 6 AND ((S.ShipByDate IS NOT NULL) OR (S.ShipByDate <= GETDATE()))AND (COALESCE(IS_DEACTIVATED, 'N') = 'N');" 
 

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
 
 
# echo($DataSet.Tables[0])
foreach ($row in $DataSet.Tables[0].Rows)

{

$TotalEodRecords = $row[0].ToString().Trim()
echo("TotalEodRecords: "+$TotalEodRecords)

}

if($TotalEodRecords -eq 0)
{
$SQLServer = "TVDB\MSSQLSERVERNEW" #use Server\Instance for named SQL instances! 
$SQLDBName = "TAYLORCFS"
#$SqlQuery = "select id,instance_id from msg_data WHERE instance_id = '1762'"
$SqlQuery = "Select Top 1 DATEDIFF(ss,START_DATETIME,End_DateTIme) AS Time_Taken_For_EOD,RECIEVED_DATETIME from msg_Data where REQUEST_TYPE = 10 and TEXT_DATA like '<Request PlantId=""1""%' order by 2 desc;" 
 

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
 
 
# echo($DataSet.Tables[0])
foreach ($row in $DataSet.Tables[0].Rows)

{

$Time_Taken_For_EOD = $row[0].ToString().Trim()
$ReceivedDateTime = $row[1].ToString().Trim()
echo("Time_Taken_For_EOD : "+$Time_Taken_For_EOD)
echo("ReceivedDateTime : "+$ReceivedDateTime)


}
}

#---------------------------------------------------------------------------------------------------------------------------------------



#--------------------------------------------------(INSERT ALL THE DETAILS INTO LOCAL DB)------------------------------------------------------------------------------

if($TotalEodRecords -eq 0)
{

$MySQLHost= "localhost" 
$user= "root" 
$pass= "" 
$database= "plannermailing" 


function ConnectMySQL([string]$user,[string]$pass,[string]$MySQLHost,[string]$database) {

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
  $RowsInserted = $command.ExecuteNonQuery()
  $command.Dispose()
  if ($RowsInserted) {
    return $RowInserted
  } else {
    return $false
  }
}
  
$flag = $false
$conn = ConnectMySQL $user $pass $MySQLHost $database
# Read all the records from table
$query = "INSERT INTO plannermailing.Eod_Dtls(
Time_Taken_For_EOD,
Total_Records
)
VALUES ('$Time_Taken_For_EOD','$TotalEodRecords')"

$Rows = WriteMySQLQuery $conn $query
Write-Host $Rows " inserted into summarywatchdogReturnXML"   
 
	

}
