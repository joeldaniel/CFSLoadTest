$timeExecute =30;

$Timeexe = [System.DateTime]::Now.AddMinutes($timeExecute);
do{
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



#----------------------------------------------(SELECT FILENAME FROM SUMMARYWATCH DOG)-----------------------------------------------------------------------
#---------------------------------------------------------(GUID VALUE)-----------------------------------------------------------------------

$conn = ConnectMySQL $user $pass $MySQLHost $database
# Read all the records from table
$query = "Select FileName from summarywatchdog where ResponseFlag='False' Limit 1"
#$query = "Call RespFlagUpdate"  
echo("------I am Running------")
$Value1 = WriteMySQLQuery $conn $query
if($Value1 -ne $null)
{
$GUIDValue = $Value1 -replace ".summary.log", ""

#$Value = Write-Host $Rows " Select query ran"
echo("----------------------")
echo("GUID "+$GUIDValue)

#---------------------------------------------(UPDATE THE VALUE OF FLAG IN SUMMARY WATCH DOG)-----------------------------------------------------------------------
 
$conn = ConnectMySQL $user $pass $MySQLHost $database
 
# Read all the records from table
$query = "Update plannermailing.summarywatchdog set ResponseFlag = 'True' where  FileName = '$Value1'"

$Rows = WriteMySQLQuerySetTrue $conn $query
Write-Host $Rows "Updated value as True in Database in summarywatchdog Table" 


 #---------------------------------------------(GET THE QUEUE ID)-----------------------------------------------------------------------

$conn = ConnectMySQL $user $pass $MySQLHost $database
# Read all the records from table
$query = "Select QueueID from importfiledtlscfs where GUID = '$GUIDValue'"

$QueueID = WriteMySQLQuery $conn $query

#$Value = Write-Host $Rows " Select query ran"
echo("----------------------")
echo("QueueID : "+$QueueID)

#-----------------------------------------------(Get the Customer Name)------------------------------------------
$conn = ConnectMySQL $user $pass $MySQLHost $database
# Read all the records from table
$query = "Select Customer_Name from importfiledtlscfs where GUID = '$GUIDValue'"

$CustomerName = WriteMySQLQuery $conn $query

#$Value = Write-Host $Rows " Select query ran"
echo("----------------------")
echo("Customer Name"+$CustomerName)
 #---------------------------------------------(GET THE FileName)-----------------------------------------------------------------------

$conn = ConnectMySQL $user $pass $MySQLHost $database
# Read all the records from table
$query = "Select FileName from importfiledtlscfs where QueueID = '$QueueID'"

$FileName = WriteMySQLQuery $conn $query

#$Value = Write-Host $Rows " Select query ran"
echo("----------------------")
echo("FileName :  "+$FileName)

#------------------------------(GET THE QUEUE ID Time Stamp = End Transaction Time in import file details)-----------------------------------------------------------------------


$conn = ConnectMySQL $user $pass $MySQLHost $database
# Read all the records from table
$query = "Select QueueIdReceivedTime from importfiledtlscfs where GUID = '$GUIDValue'"

$QueuIDTimeStamp = WriteMySQLQuery $conn $query

#$Value = Write-Host $Rows " Select query ran"
echo("----------------------")
echo("QueuIDTimeStamp : "+$QueuIDTimeStamp)

#-----------------------(Get the OrderSummFileTimeStamp Time Stamp = Created Time in Watch Folder Dog Script)-----------------------------------------------------------------------


$conn = ConnectMySQL $user $pass $MySQLHost $database
# Read all the records from table
$query = "Select CreatedTime from summarywatchdog where FileName = '$Value1'"

$OrderSummFileTimeStamp = WriteMySQLQuery $conn $query

#$Value = Write-Host $Rows " Select query ran"
echo("----------------------")
echo("OrderSummFileTimeStamp : "+$OrderSummFileTimeStamp)




#-------------------------------------------(Get the SummCreationRespTime Time Stamp)-----------------------------------------------------------------------

$timespan = new-timespan -Start ($QueuIDTimeStamp) -end ($OrderSummFileTimeStamp)

#Calculating the time in seconds
$SummCreationRespTime =  $timespan.TotalSeconds
 
echo("$SummCreationRespTime : "+$SummCreationRespTime)

#----------------------------------------------(COMPARISON OF ORDER XML AND IMPORT SUMMARY)-----------------------------------------------------------------------

$invocation = (Get-Variable MyInvocation).Value
$directorypath = Split-Path $invocation.MyCommand.Path
$settingspath = $directorypath + '\'
#$path = $settingspath + "test6.xml"
$path = $FileName

#To load the order import xml
$xml = [xml](get-content $path)
echo("-------------------------------------------------------------")


#To find the length of the shipping orders
$Records = $xml.MailingImport.Segments.Segment.Records.Record.ShippingOrderInfo.Length

#Read all the external shipping order ids and store it in an array
$AllESOrderIDs = $xml.MailingImport.Segments.Segment.Records.Record.ShippingOrderInfo|foreach {$_.ExternalShippingOrderID}

$AllESOrderIDsArray = @($AllESOrderIDs)

#To load the import summary xml
#$imp = 'D:\CFS_PowerShell\ImportSummary.xml'
$impNew = '\\TAYLORCFSQA\MonarchGatewayLog\Planner\'+ $GUIDValue + '.summary.log'
echo("impNew : "+$impNew)
$ImpSummNewValue = 'D:\CFS_PowerShell_New\ImportSummary\'+$GUIDValue
echo("ImpSummNewValue : "+$ImpSummNewValue)
#Rename-Item $impNew $ImpSummNewValue
Copy-Item $impNew $ImpSummNewValue
#$imp1 = '.\NewImpSumm.xml'
$imp2 = $ImpSummNewValue
$xmlImp = [xml](get-content $imp2 )

#To find the length of the shipping orders in importsummary xml
$RecordsNew = $xmlImp.importSummary.shipments.shipment.Length
echo("Total no of external shipping orders = "+$RecordsNew)

#Read all the external shipping order ids and store it in an array
$AllESImpSumOrderIDs = $xmlImp.importSummary.shipments.shipment|foreach {$_.externalShippingOrderID}

$AllESImpSumOrderIDsArray = @($AllESImpSumOrderIDs)

for($i=0; $i -lt $RecordsNew;$i++)
	{
		echo("External Shipping Order id "+$i+" = "+$AllESImpSumOrderIDsArray[$i]);
	}

#Read all the Planner ids and store it in an array
$AllPlannerIDs = $xmlImp.importSummary.shipments.shipment|foreach {$_.plannerShipmentID}
$AllPlannerIDsArray = @($AllPlannerIDs)

if($Records=$RecordsNew)
{
echo("Count of External shipping orders id in order import and import summary xml are matching")
}

$flag=$true
for($i=0; $i -lt $Records;$i++)
{	
	if($AllESOrderIDsArray[$i]-ne$AllESImpSumOrderIDsArray[$i])
	{
		$flag = $false
		break;
	} 
}
if($flag -eq "true")
{
	echo("External shipping orders in both the xml are matching");
	for($i=0; $i -lt $RecordsNew;$i++)
	{ 
		echo("Planner id "+$i+" = "+$AllPlannerIDsArray[$i]);
	}
}
else
{
	echo("External shipping orders in both the xml are not matching")
}

#-------------------------------------------------(INSERT INTO CFSDETAILS)------------------------------------------------------------------------------

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
  
  $dbFlag = $true
  if($Records=$RecordsNew)
  {
  	$dbFlag = $true
  }
  else
  {
  	$dbFlag = $false
  }
$dbCount = $Records-$RecordsNew
  
#---------------------------------------------(INSERT DETAILS INTO OrderXml2OrderSummMappingCfs)----------------------------------------------------------------------------------------------   
  
$conn = ConnectMySQL $user $pass $MySQLHost $database
 
# Read all the records from table
$query = "INSERT INTO plannermailing.orderxml2ordersummary_Validation(
QueueID,
GUID,
NoOfExtShippOrders,
ShippmentResponseInOrderSumm,
CompOfShippingOrders,
CountStatus,
OrderXmlFileName,
OrderSummFileName
)
VALUES ('$QueueID','$GUIDValue','$Records','$RecordsNew','$dbFlag',$dbCount,'$path','$imp2')"

$Rows = WriteMySQLQuery $conn $query
Write-Host $Rows " inserted into orderxml2ordersummmappingCfs database" 
	
#---------------------------------------------(INSERT DETAILS INTO PLANN : ALL PLANNERIDS)----------------------------------------------------------------------------------------------

$conn = ConnectMySQL $user $pass $MySQLHost $database
for($i=0; $i -lt $Records;$i++)
	{
	$pn1 = $AllPlannerIDsArray[$i]
	$sn1 = $AllESImpSumOrderIDsArray[$i]
	
$query = "INSERT INTO plannermailing.PlannerIdDtls(
QueueID,
GUID,
PlannerIDs
,ExternalShippingOrders
)
VALUES ('$QueueID','$GUIDValue','$pn1','$sn1')"

$Rows = WriteMySQLQuery $conn $query
#Write-Host $Rows " inserted into plannerIdDtls database" 

	}
if($dbFlag=$true)
	{
		$shippmentresponseflag = $false
	}
else
	{
		$shippmentresponseflag = 'NA'
	}

#---------------------------------------------(INSERT DETAILS INTO SHIPPMENT RESPONSE FLAG TABLE)----------------------------------------------------------------------------------------------

$conn = ConnectMySQL $user $pass $MySQLHost $database
#for($i=0; $i -lt $Records;$i++)
#	{
#	$pn1 = $AllPlannerIDsArray[$i]
#	$sn1 = $AllESImpSumOrderIDsArray[$i]
	
$query = "INSERT INTO plannermailing.shippmentresponseflag(
GUID,
FLAG
)
VALUES ('$GUIDValue','$shippmentresponseflag')"

$Rows = WriteMySQLQuery $conn $query
Write-Host $Rows " inserted into shippmentresponseflag database" 

#	}

#---------------------------------------------(INSERT DETAILS INTO RESPONSETIMEOFORDERSUMMCFS)----------------------------------------------------------------------------------------------

$conn = ConnectMySQL $user $pass $MySQLHost $database
	
$query = "INSERT INTO plannermailing.responsetimeofordersumm(
QueueID,
GUID,
QueueIdTimeStamp,
OrderSummFileTimeStamp,
SummCreationRespTime,Customer_Name
)
VALUES ('$QueueID','$GUIDValue','$QueuIDTimeStamp','$OrderSummFileTimeStamp','$SummCreationRespTime','$CustomerName')"

$Rows = WriteMySQLQuery $conn $query
Write-Host $Rows " inserted into responsetimeofordersumm database" 

	
#---------------------------------------------------(GENERATION OF SHIPPING RESPONSE XML)---------------------------------------------------------------------------------

$finalCount = $RecordsNew
$ItrCounter = 1
$counter = 0
for($i=0; $i -lt $finalCount;$i = $i+10)
	{ 
	$counter = $finalCount/10
	
	$SecondCount = $finalCount % 10
	if($ItrCounter -lt $counter)
	{	
		$ts4 = (Get-Date -format yyyyMMddHHmmss);
		$ShippRespPath = 'C:\Users\abhiskum\Desktop\XMLS\New\'+$AllPlannerIDsArray[$i]+'-A'+$AllPlannerIDsArray[$i+9]+'_'+$QueueID+'.xml'
		Copy-Item C:\Users\abhiskum\Desktop\XMLS\Old\ShippingOrderPackage_10.xml $ShippRespPath
		[xml] $xdoc = get-content $ShippRespPath
		echo("Planner id "+$i+" = "+$AllPlannerIDsArray[$i]);
		
		for($j=0; $j -lt 10;$j++)
		{
			$xdoc.ShipmentPackageResponse.ShippingOrder[$j].ShippingOrderDetails.UniqueOrderID = $AllPlannerIDsArray[$i+$j]
			echo($AllPlannerIDsArray[$i+$j])
		}
		$xdoc.Save($ShippRespPath)
		$ItrCounter++
		
		$CopyShippingResponse = '\\TAYLORCFSQA\hagenoa\transfer\FromProcessDemo\'+'ShippingOrderPackage_'+'_'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+9]+'_'+$QueueID+'.xml'
		Copy-Item $ShippRespPath $CopyShippingResponse
	}
	elseif($SecondCount -eq 9)
	{
		$ts4 = (Get-Date -format yyyyMMddHHmmss);
		$ShippRespPath = 'C:\Users\abhiskum\Desktop\XMLS\New\'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+8]+'_'+$QueueID+'.xml'
		Copy-Item C:\Users\abhiskum\Desktop\XMLS\Old\ShippingOrderPackage_9.xml $ShippRespPath
		[xml] $xdoc = get-content $ShippRespPath
		echo("Planner id "+$i+" = "+$AllPlannerIDsArray[$i]);
		
		for($j=0; $j -lt 9;$j++)
		{
			$xdoc.ShipmentPackageResponse.ShippingOrder[$j].ShippingOrderDetails.UniqueOrderID = $AllPlannerIDsArray[$i+$j]
			echo($AllPlannerIDsArray[$i+$j])
		}
		$xdoc.Save($ShippRespPath)
		
		$CopyShippingResponse = '\\TAYLORCFSQA\hagenoa\transfer\FromProcessDemo\'+'ShippingOrderPackage_'+$QueueID+'_'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+8]+'_'+$i+'.xml'
		Copy-Item $ShippRespPath $CopyShippingResponse
	}
	
	elseif($SecondCount -eq 8)
	{
		$ts4 = (Get-Date -format yyyyMMddHHmmss);
		$ShippRespPath = 'C:\Users\abhiskum\Desktop\XMLS\New\'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+7]+'_'+$QueueID+'.xml'
		Copy-Item C:\Users\abhiskum\Desktop\XMLS\Old\ShippingOrderPackage_8.xml $ShippRespPath
		[xml] $xdoc = get-content $ShippRespPath
		echo("Planner id "+$i+" = "+$AllPlannerIDsArray[$i]);
		
		for($j=0; $j -lt 8;$j++)
		{
			$xdoc.ShipmentPackageResponse.ShippingOrder[$j].ShippingOrderDetails.UniqueOrderID = $AllPlannerIDsArray[$i+$j]
			echo($AllPlannerIDsArray[$i+$j])
		}
		$xdoc.Save($ShippRespPath)
		
		$CopyShippingResponse = '\\TAYLORCFSQA\hagenoa\transfer\FromProcessDemo\'+'ShippingOrderPackage_'+$QueueID+'_'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+7]+'_'+$i+'.xml'
		Copy-Item $ShippRespPath $CopyShippingResponse
	}
	
	elseif($SecondCount -eq 7)
	{
		$ts4 = (Get-Date -format yyyyMMddHHmmss);
		$ShippRespPath = 'C:\Users\abhiskum\Desktop\XMLS\New\'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+6]+'_'+$QueueID+'.xml'
		Copy-Item C:\Users\abhiskum\Desktop\XMLS\Old\ShippingOrderPackage_7.xml $ShippRespPath
		[xml] $xdoc = get-content $ShippRespPath
		echo("Planner id "+$i+" = "+$AllPlannerIDsArray[$i]);
		
		for($j=0; $j -lt 7;$j++)
		{
			$xdoc.ShipmentPackageResponse.ShippingOrder[$j].ShippingOrderDetails.UniqueOrderID = $AllPlannerIDsArray[$i+$j]
			echo($AllPlannerIDsArray[$i+$j])
		}
		$xdoc.Save($ShippRespPath)
		
		
		$CopyShippingResponse = '\\TAYLORCFSQA\hagenoa\transfer\FromProcessDemo\'+'ShippingOrderPackage_'+$QueueID+'_'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+6]+'_'+$i+'.xml'
		Copy-Item $ShippRespPath $CopyShippingResponse
	}
	
	elseif($SecondCount -eq 6)
	{
		$ts4 = (Get-Date -format yyyyMMddHHmmss);
		$ShippRespPath = 'C:\Users\abhiskum\Desktop\XMLS\New\'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+5]+'_'+$QueueID+'.xml'
		Copy-Item C:\Users\abhiskum\Desktop\XMLS\Old\ShippingOrderPackage_6.xml $ShippRespPath
		[xml] $xdoc = get-content $ShippRespPath
		echo("Planner id "+$i+" = "+$AllPlannerIDsArray[$i]);
		
		for($j=0; $j -lt 6;$j++)
		{
			$xdoc.ShipmentPackageResponse.ShippingOrder[$j].ShippingOrderDetails.UniqueOrderID = $AllPlannerIDsArray[$i+$j]
			echo($AllPlannerIDsArray[$i+$j])
		}
		$xdoc.Save($ShippRespPath)
		
		$CopyShippingResponse = '\\TAYLORCFSQA\hagenoa\transfer\FromProcessDemo\'+'ShippingOrderPackage_'+$QueueID+'_'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+5]+'_'+$i+'.xml'
		Copy-Item $ShippRespPath $CopyShippingResponse
	}
	
	elseif($SecondCount -eq 5)
	{
		$ts4 = (Get-Date -format yyyyMMddHHmmss);
		$ShippRespPath = 'C:\Users\abhiskum\Desktop\XMLS\New\'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+4]+'_'+$QueueID+'.xml'
		Copy-Item C:\Users\abhiskum\Desktop\XMLS\Old\ShippingOrderPackage_5.xml $ShippRespPath
		[xml] $xdoc = get-content $ShippRespPath
		echo("Planner id "+$i+" = "+$AllPlannerIDsArray[$i]);
		
		for($j=0; $j -lt 5;$j++)
		{
			$xdoc.ShipmentPackageResponse.ShippingOrder[$j].ShippingOrderDetails.UniqueOrderID = $AllPlannerIDsArray[$i+$j]
			echo($AllPlannerIDsArray[$i+$j])
		}
		$xdoc.Save($ShippRespPath)
		
		
		$CopyShippingResponse = '\\TAYLORCFSQA\hagenoa\transfer\FromProcessDemo\'+'ShippingOrderPackage_'+$QueueID+'_'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+4]+'_'+$i+'.xml'
		Copy-Item $ShippRespPath $CopyShippingResponse
	}
	
	elseif($SecondCount -eq 4)
	{
		$ts4 = (Get-Date -format yyyyMMddHHmmss);
		$ShippRespPath = 'C:\Users\abhiskum\Desktop\XMLS\New\'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+3]+'_'+$QueueID+'.xml'
		Copy-Item C:\Users\abhiskum\Desktop\XMLS\Old\ShippingOrderPackage_4.xml $ShippRespPath
		[xml] $xdoc = get-content $ShippRespPath
		echo("Planner id "+$i+" = "+$AllPlannerIDsArray[$i]);
		
		for($j=0; $j -lt 4;$j++)
		{
			$xdoc.ShipmentPackageResponse.ShippingOrder[$j].ShippingOrderDetails.UniqueOrderID = $AllPlannerIDsArray[$i+$j]
			echo($AllPlannerIDsArray[$i+$j])
		}
		$xdoc.Save($ShippRespPath)
		
		
		$CopyShippingResponse = '\\TAYLORCFSQA\hagenoa\transfer\FromProcessDemo\'+'ShippingOrderPackage_'+$QueueID+'_'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+3]+'_'+$i+'.xml'
		Copy-Item $ShippRespPath $CopyShippingResponse
	}
	
	elseif($SecondCount -eq 3)
	{
		$ts4 = (Get-Date -format yyyyMMddHHmmss);
		$ShippRespPath = 'C:\Users\abhiskum\Desktop\XMLS\New\'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+2]+'_'+$QueueID+'.xml'
		Copy-Item C:\Users\abhiskum\Desktop\XMLS\Old\ShippingOrderPackage_3.xml $ShippRespPath
		[xml] $xdoc = get-content $ShippRespPath
		echo("Planner id "+$i+" = "+$AllPlannerIDsArray[$i]);
		
		for($j=0; $j -lt 3;$j++)
		{
			$xdoc.ShipmentPackageResponse.ShippingOrder[$j].ShippingOrderDetails.UniqueOrderID = $AllPlannerIDsArray[$i+$j]
			echo($AllPlannerIDsArray[$i+$j])
		}
		$xdoc.Save($ShippRespPath)
		
		
		$CopyShippingResponse = '\\TAYLORCFSQA\hagenoa\transfer\FromProcessDemo\'+'ShippingOrderPackage_'+$QueueID+'_'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+2]+'_'+$i+'.xml'
		Copy-Item $ShippRespPath $CopyShippingResponse
	}
	
	elseif($SecondCount -eq 2)
	{
		$ts4 = (Get-Date -format yyyyMMddHHmmss);
		$ShippRespPath = 'C:\Users\abhiskum\Desktop\XMLS\New\'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+1]+'_'+$QueueID+'.xml'
		Copy-Item C:\Users\abhiskum\Desktop\XMLS\Old\ShippingOrderPackage_2.xml $ShippRespPath
		[xml] $xdoc = get-content $ShippRespPath
		echo("Planner id "+$i+" = "+$AllPlannerIDsArray[$i]);
		
		for($j=0; $j -lt 2;$j++)
		{
			$xdoc.ShipmentPackageResponse.ShippingOrder[$j].ShippingOrderDetails.UniqueOrderID = $AllPlannerIDsArray[$i]
			echo($AllPlannerIDsArray[$i+$j])
		}
		$xdoc.Save($ShippRespPath)
		
		
		$CopyShippingResponse = '\\TAYLORCFSQA\hagenoa\transfer\FromProcessDemo\'+'ShippingOrderPackage_'+$QueueID+'_'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+1]+'_'+$i+'.xml'
		Copy-Item $ShippRespPath $CopyShippingResponse
	}
	
	elseif($SecondCount -eq 1)
	{
		$ts4 = (Get-Date -format yyyyMMddHHmmss);
		$ShippRespPath = 'C:\Users\abhiskum\Desktop\XMLS\New\'+$AllPlannerIDsArray[$i]+'-'+$AllPlannerIDsArray[$i+4]+'_'+$QueueID+'.xml'
		Copy-Item C:\Users\abhiskum\Desktop\XMLS\Old\ShippingOrderPackage_1.xml $ShippRespPath
		[xml] $xdoc = get-content $ShippRespPath
		echo("Planner id "+$i+" = "+$AllPlannerIDsArray[$i]);
		
			$xdoc.ShipmentPackageResponse.ShippingOrder[$0].ShippingOrderDetails.UniqueOrderID = $AllPlannerIDsArray[$i]
			echo($AllPlannerIDsArray[$0])
		}
		$xdoc.Save($ShippRespPath)
	}
	
		
#------------------------------------------------------------(FIND INSTANCE ID USING QUEUE ID : SERVER)--------------------------------------------------------------------------


$SQLServer = "TAYLORCFSQA" #use Server\Instance for named SQL instances! 
$SQLDBName = "TAYLORCFS"
#$SqlQuery = "select id,instance_id from msg_data WHERE instance_id = '1762'"
$SqlQuery = "Select instance_id from msg_Data where id = '$QueueID'" 
 
 
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

$instance_id_Value = $row[0].ToString().Trim()
echo("instance_id_Value"+$instance_id_Value)

}

	
	
#------------------------------------------------------------(JOB XML SENT TO FOUNDATION : TIME)--------------------------------------------------------------------------

while($true)

{

$XmlDelta = '%OT'+$instance_id_Value+'%'
$XmlDeltaInsertValue = 'OT'+$instance_id_Value
$SQLServer = "TAYLORCFSQA" #use Server\Instance for named SQL instances! 
$SQLDBName = "TAYLORCFS"
#$SqlQuery = "select id,instance_id from msg_data WHERE instance_id = '1762'"
$SqlQuery = "Select Top(1) b.CREATIONDATETIME from msg_Data a, Jobxml b where a.INSTANCE_ID = '$instance_id_Value' and b.XMLDELTA like '$XmlDelta' order by b.CREATIONDATETIME" 
 
 
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

$FoudationXmlTime = $row[0].ToString().Trim()
echo("Foundation Job Xml received time : "+$FoudationXmlTime)

}

if($FoudationXmlTime -ne $null)
{
	break;
}
}
#---------------------------------------------(FOUNDATION XML DETAILS INSERTION INTO DB)-------------------------------------------------------------------------------------------------

$fl = $false
$conn = ConnectMySQL $user $pass $MySQLHost $database
	
$query = "INSERT INTO plannermailing.FoundationXMLDtls(
QueueID,
InstanceID,
UniqueIdentifier,
FoundationXMlCreationTime,
flag
)
VALUES ('$QueueID','$instance_id_Value','$XmlDeltaInsertValue','$FoudationXmlTime','$fl')"

$Rows = WriteMySQLQuery $conn $query
Write-Host $Rows " inserted into FoundationXMLDtls" 


$TimeexeFinal = [System.DateTime]::Now
}
	}
	Until($TimeexeFinal -gt $Timeexe)
