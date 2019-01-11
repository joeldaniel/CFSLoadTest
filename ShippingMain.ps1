$FileSystemWatcher  = New-Object  System.IO.FileSystemWatcher  
$FileSystemWatcher.Path= "\\TVMONBROKER\XMLInbox\ShipmentNotice"  
 
  Register-ObjectEvent -InputObject $FileSystemWatcher  -EventName Created  -Action {
  
  $name = $Event.SourceEventArgs.Name
  $changeType = $Event.SourceEventArgs.ChangeType
  $timeStamp = $Event.TimeGenerated
  Write-Host "The file '$name' was $changeType at $timeStamp"





$Value1 = $name
$charge = 0
$i=100


			$myarg='\\TVMONBROKER\XMLInbox\ShipmentNotice\'+$Value1 +' '+ $i+ ' ' +'\\TVMONBROKER\hagenoa\transfer\FromProcessDemo'+' '+ 0
			Start-Sleep -Seconds 2
			Start-Process -FilePath "E:\Joel\ShippingResponse\Monarch.Planner.AutoTest.ShippingResponse.App.exe" -ArgumentList $myarg -Wait -WindowStyle Hidden
			       
			Copy-item "\\TVMONBROKER\XMLInbox\ShipmentNotice\$name" "E:\Joel\ShippingNoticeAlternate"
			
			 Remove-item "\\TVMONBROKER\XMLInbox\ShipmentNotice\$name" -recurse    
	

}