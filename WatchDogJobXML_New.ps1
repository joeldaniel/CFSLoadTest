$FileSystemWatcher  = New-Object  System.IO.FileSystemWatcher  
$FileSystemWatcher.Path= "\\tvmonbroker\hagenoa\transfer\ToPlanner\Processed"  
 
  Register-ObjectEvent -InputObject $FileSystemWatcher  -EventName Created  -Action {
  
  $name = $Event.SourceEventArgs.Name
  $changeType = $Event.SourceEventArgs.ChangeType
  $timeStamp = $Event.TimeGenerated
  Write-Host "The file '$name' was $changeType at $timeStamp"
  
  
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
  echo($name)
echo($path)
#------------------------------------------------------(EXTRACT THE VALUE FROM THE XML)--------------------------------------------------------------------------------------

$FileName = '\\tvmonbroker\hagenoa\transfer\ToPlanner\Processed\'+$name
$path = $FileName



#To load the order import xml
$xml = [xml](get-content $path)
echo("-------------------------------------------------------------")


#To find the length of the shipping orders
#$Records1 = $xml.SubJobNumberRequest.SubJobNumber.prographUniqueIdentifier

$AllShippingOrders = $xml.SubJobNumberRequest.SubJobNumber|foreach {$_.prographUniqueIdentifier}
$RecordsNew = $xml.SubJobNumberRequest.SubJobNumber.prographUniqueIdentifier.Length
$Records1 = @($AllShippingOrders)

for($i=0; $i -lt $RecordsNew;$i++)
{
	$Val = $Records1[$i]
if($Val -ne $null)
{
	
	$conn = ConnectMySQL $user $pass $MySQLHost $database
	# Read all the records from table
	$query = "INSERT INTO plannermailing.summarywatchdogPlannerJobXML(
	FileName,
	UniqueIdentifier,
	CreatedTime
	)
	VALUES ('$name','$Val','$timeStamp')"

	$Rows = WriteMySQLQuery $conn $query
	Write-Host $Rows " inserted into summarywatchdogPlannerJobXML Table"   

	echo($Records1)
}
}
} 