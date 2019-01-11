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

#----------------------------------------------(SELECT FILENAME FROM shippingalternatenoticexml)-----------------------------------------------------------------------


		$conn = ConnectMySQL $user $pass $MySQLHost $database
		# Read all the records from table
		$query = "Select FileName from shippingalternatenoticexml where ResponseFlag='False' Limit 1"
		#$query = "Call RespFlagUpdate" 
		echo("------I am Running------")
		$Value1 = WriteMySQLQuery $conn $query
		if($Value1 -ne $null)
		{
		

		echo("----------------------")
		
		echo("Value "+$Value1)

		#---------------------------------------------(UPDATE THE VALUE OF FLAG IN shippingalternatenoticexml)-----------------------------------------------------------------------
		 
		$conn = ConnectMySQL $user $pass $MySQLHost $database
		 
		# Read all the records from table
		$query = "Update plannermailing.shippingalternatenoticexml set ResponseFlag = 'True' where  FileName = '$Value1'"

		$Rows = WriteMySQLQuerySetTrue $conn $query
		Write-Host $Rows "Updated value as True in Database in shippingalternatenoticexml Table" 
		$Postage=1
		$args= $Value1,$Postage
		Start-Job -FilePath D:\CFS_PowerShell_LoadServer\GenerateShippingResponse.ps1 -ArgumentList $args
		}
}