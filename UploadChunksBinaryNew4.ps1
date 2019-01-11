$Customer = $args[0];
#$Customer="Customer343"
$timeExecute =$args[1];
#$timeExecute="2000000"
$currentExecutingPath = $args[2];
#$currentExecutingPath = "E:\CFS_PowerShell_LoadServer\"

echo($Customer)
echo($timeExecute)
echo($currentExecutingPath)
#$Customer = "CustomerA"
#$timeExecute = 3

#$currentExecutingPath='D:\CFS_PowerShell_New\'

$EndPoint = "http://TVmongateway/MonarchIISGateway/PlannerIntegration.asmx?WSDL"
$Timeexe = [System.DateTime]::Now.AddMinutes($timeExecute);

#do{
#$invocation = (Get-Variable MyInvocation).Value
#$directorypath = Split-Path $invocation.MyCommand.Path
#$settingspath = $directorypath + '\'
$TimeexeFinal = [System.DateTime]::Now
#      echo($TimeexeFinal)
$settingspath = $currentExecutingPath
#Write-host "Setting path is - "  + $settingspath
$oldPath = $settingspath + $Customer + '\OrderXMLSInput'
#Write-host "Old"  + $oldPath
$newPath = $settingspath + $Customer + '\OrderXMLToPost'
#Write-host "New path is - "  + $newPath
$GciFiles = get-childitem $oldPath

foreach ($file in $GciFiles){
$TimeexeFinal = [System.DateTime]::Now
#      echo($TimeexeFinal)
if($TimeexeFinal -gt $Timeexe)
{
break
}

  Write-host $file.Name
  if(!($file.Name -eq $null) -and $file.Name.EndsWith(".xml")){
      Write-host "copying item "+($newPath+'\'+$file)
      Copy-item $oldPath\$file $newPath
      if (Test-path ($newPath+'\'+$file)) {
          Write-host "removing item "+($oldPath+'\'+$file)
          Remove-item ($oldPath+'\'+$file) -recurse

$path = $newPath + '\' + $file.Name
#Write-host "File path to post " + $path
Write-host "Value to be changed"+ $path

#-------------------------------------Updating the externalId and Name in the xml--------------------------------
[xml] $xdoc = get-content $path

#Unique Value
$ts4 = (Get-Date -format yyyyMMddHHmmss);
$ExternalOrderTypeID11 = $Customer + $ts4
$ExternalOrderTypeID11XML = $ExternalOrderTypeID11 +".xml"
$xdoc.MailingImport.OrderType.ExternalOrderTypeID = $ExternalOrderTypeID11
$xdoc.MailingImport.OrderType.Name = $ExternalOrderTypeID11XML
              
$xdoc.Save($path)

$chunkSize=900000
$ts = (Get-Date -format yyyy-MM-dd_HH-mm-ss); 
$RndDig = Get-Random
$RndDig1 = Get-Random
[string]$FileName1 = ""

[string]$FileName1 = "Upload" + $ts + ".xml"
$xmlFile = $settingspath + "UploadXML.xml"
$InputXML = $settingspath +"\"+$Customer+ "\InputXML\" + $FileName1
$OutPutXML =$settingspath +"\"+$Customer+"\OutPutXML\" + "OutPutXML_" + $ts + "_" + $RndDig + $RndDig1 + ".xml"
$OrderImporterFileOutput = $settingspath+"\" +$Customer+ "\OrderImportOutput\" + "OIResponseXML_" + $ts + "_" + $RndDig + $RndDig1 + ".xml"
$OrderImporterFile = $settingspath +"\"+$Customer+"\OrderImport\"+ "OrderImport_" + $ts + "_" + $RndDig + $RndDig1 + ".xml"
$OrderImporterTemplate = $settingspath + "OrderImporterTemplate.xml"

$fileName = [System.IO.Path]::GetFileNameWithoutExtension($path)
$directory = [System.IO.Path]::GetDirectoryName($path)
$extension = [System.IO.Path]::GetExtension($path)

$file = New-Object System.IO.FileInfo($path)
$totalChunks = [int]($file.Length / $chunkSize) + 1
$digitCount = [int][System.Math]::Log10($totalChunks) + 1

$reader = [System.IO.File]::OpenRead($path)
       
       
#      $Data = get-content $path
#      $Bytes = [System.Text.Encoding]::Unicode.GetBytes($Data)
#      $EncodedData = [Convert]::ToBase64String($Bytes)
       
       
    $count = 0
    $buffer = New-Object Byte[] $chunkSize
       
    $hasMore = $true
       $bytesRead =""
       $bytesRead1 = 0
    while($hasMore)
    {
        $bytesRead = $reader.Read($buffer, 0, $chunkSize)
              
              echo($bytesRead)
              $Base64Bin = [Convert]::ToBase64String($buffer, 0, $bytesRead);
              $writer.Write([Convert]::ToBase64String($buffer, 0, $bytesRead));
           $chunkFileName = "$directory\$fileName$extension.{0:D$digitCount}.part"
        $chunkFileName = $chunkFileName -f $count
        $output = $Base64Bin
        if ($bytesRead -ne $buffer.Length)
        {
            $hasMore = $false
            $output = New-Object Byte[] $bytesRead
            [System.Array]::Copy($buffer, $output, $bytesRead)
        }
              [string]$buffercnt = $output
              $InputXML = $settingspath +"\"+ $Customer+ "\InputXML\" +"InputXML_" + $count + "_" + $RndDig + $RndDig1 + ".xml"
              $OutPutXML = $settingspath +"\"+ $Customer+"\OutPutXML\" + "OutPutXML_" + $count + "_" + $RndDig + $RndDig1 + ".xml"

              
              [System.Xml.XmlDocument] $xd = new-object System.Xml.XmlDocument
              [string]$iCointer = $count
              $xd.Load($xmlFile)
              [string]$Position = $bytesRead1
              $xd.DocumentElement.Body.UploadFile.fileName = $FileName1
              $xd.DocumentElement.Body.UploadFile.buffer = $Base64Bin
              $xd.DocumentElement.Body.UploadFile.offset = $Position
              Start-Sleep -Seconds 1
              $xd.Save($InputXML)
                     
              $bytesRead1 = $bytesRead+$bytesRead1
              echo($bytesRead1)
              $a = [Char]64 + $InputXML
              $sPingcmd = "E:\CFS\curl-7.56.1-win64-mingw\bin\curl.exe -v -o " + [Char]34 + $OutPutXML + [Char]34 + " -H " + [Char]34 + "Content-Type: text/xml" + [Char]34 + " -H " + [Char]34 + "SOAPAction: " + [Char]34 + "http://planner.efi.com/UploadFile" + [Char]34 + [Char]34 + " -d " + [Char]34 + $a + [Char]34 + " " + $EndPoint
              $sPingcmd1 = $sPingcmd
##$StartTime = (Get-Date -format yyyy-MM-dd_HH-mm-ss); 
#$StartTime = [System.DateTime]::Now;
              $StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss";
              
              cmd.exe /c $sPingcmd1;
              
              $xd.Load($OutPutXML)
              $FileName1= $xd.DocumentElement.Body.UploadFileResponse.fileName
              $FileResponse= $xd.DocumentElement.Body.UploadFileResponse.UploadFileResult
              
              echo($FileName1)
              echo($FileResponse)
              
              
      #  [System.IO.File]::WriteAllBytes($chunkFileName, $output)
        ++$count
    }
       $xd.Load($OrderImporterTemplate)
       $xd.DocumentElement.Body.OrderImporter.orderXMLFileName = $FileName1
       $xd.Save($OrderImporterFile)
       
#--------------------------------------------(START TIME TO CALCULATE IMPORT ORDER GENERATION)-----------------------------------------------------------------------------------------
       
       $StartTimeOfImportGeneration = Get-Date -format "yyyy-MM-dd HH:mm:ss";
       
       $a = [Char]64 + $OrderImporterFile
       $sPingcmd = "E:\CFS\curl-7.56.1-win64-mingw\bin\curl.exe -v -o " + [Char]34 + $OrderImporterFileOutput + [Char]34 + " -H " + [Char]34 + "Content-Type: text/xml" + [Char]34 + " -H " + [Char]34 + "SOAPAction: " + [Char]34 + "http://planner.efi.com/OrderImporter" + [Char]34 + [Char]34 + " -d " + [Char]34 + $a + [Char]34 + " " + $EndPoint
       $sPingcmd1 = $sPingcmd
       $StartTime = Get-Date -format "yyyy-MM-dd HH:mm:ss";
       cmd.exe /c $sPingcmd1;
       
       $xd.Load($OrderImporterFileOutput)
       $QueueID= $xd.DocumentElement.Body.OrderImporterResponse.OrderImporterResult
       
       echo($QueueID)
       

#--------------------------------------------(END TIME TO CALCULATE IMPORT ORDER GENERATION)-----------------------------------------------------------------------------------------
$EndTimeOfImportGeneration = Get-Date -format "yyyy-MM-dd HH:mm:ss";
       
$reader.Close()
       
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

       
       
#----------------------------------------------(INSERTION OF TRANSACTION TIME INTO DATABASE)--------------------------------------------

#----------------------------------------------(ORDER IMPORT GENERATION TIME)--------------------------------------------------

echo($StartTimeOfImportGeneration)
echo($EndTimeOfImportGeneration)
$timespan = new-timespan -Start ($StartTimeOfImportGeneration) -end ($EndTimeOfImportGeneration)
#Calculating the time in seconds
$OrderImportGenerationTime =  $timespan.TotalSeconds
echo("Order Creation Time : "+$OrderImportGenerationTime)

#------------------------------------------------------(DB INSERTION)----------------------------------------------------------
echo("MyValue  :"+$path)

$Path12 = $path.Replace('\','\\\')
  
$conn = ConnectMySQL $user $pass $MySQLHost $database
# Read all the records from table
$query = "INSERT INTO plannermailing.ImportFileDtlscfs(
FileName,
QueueID,
GUID,
FinalGuidReceivedTIme,
QueueIdReceivedTime,
TOTAL_TRANSACTION_TIME,
Customer_Name,
queueIdFlag
)      
VALUES ('$Path12','$QueueID','$FileName1','$StartTimeOfImportGeneration','$EndTimeOfImportGeneration','$OrderImportGenerationTime','$Customer','false')"

$Rows = WriteMySQLQuery $conn $query
Write-Host $Rows " inserted into ImportFileDtls"   
  	


       

   
       
       
       }
       }
	   Start-Sleep -Seconds 60
       }
	   
#       }
#       Until($TimeexeFinal -gt $Timeexe)

#------------------------------------------------------------Writing into text file---------------------------------------------------------

       
       
