$FileSystemWatcher  = New-Object  System.IO.FileSystemWatcher  
$FileSystemWatcher.Path= "\\TVMONBROKER\XMLInbox\ShipmentNotice\Alternate\"

 
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
  $conn = ConnectMySQL $user $pass $MySQLHost $database
# Read all the records from table
$query = "INSERT INTO plannermailing.shippingalternatenoticexml(
FileName,
AlternateNoticeXMLcreatedTime
)
VALUES ('$name','$timeStamp')"

$Rows = WriteMySQLQuery $conn $query
Write-Host $Rows " inserted into shippingalternatenoticexml"   

} 