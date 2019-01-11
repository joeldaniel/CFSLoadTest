#Copy-Item $originalLocation $UploadLocation

#$u=1
#$j = 1
#
#	for($i=1; $i -lt 3;$i++)
#	{
#
#			$originalLocation = 'D:\CFS_PowerShell_LoadServer\Post\Customer'+$i+'\Day1\Customer'+$i+'Iteration'+$u+'.xml'
#			echo($originalLocation)
#			$UploadLocation = 'D:\CFS_PowerShell_LoadServer\Customer'+$j+'\OrderXMLSInput'+'\Customer'+$i+'Iteration'+$u+'.xml'
#			echo($UploadLocation)
#
#			$j++
#			
#			Copy-Item $originalLocation $UploadLocation
#
#	}

$cust = $args[0];
$Days = $args[1];
#for($i=1; $i -le 24;$i++)
#	{
			$fileloc='E:\CFS_PowerShell_LoadServer\Post\Customer'+$cust+'\Day'+$Days
			$files = Get-ChildItem -Path $fileloc
			foreach($file in $files){
				
				$filename = $file.Name
				[string]$originalLocation  = 'E:\CFS_PowerShell_LoadServer\Post\Customer'+$cust+'\Day4\'+$filename
				[string]$UploadLocation = 'E:\CFS_PowerShell_LoadServer\Customer'+$cust+'\OrderXMLSInput\'
				#Copy-item -Force -Recurse -Verbose $originalLocation -Destination $UploadLocation
				Copy-Item -Path $originalLocation -Destination $UploadLocation -recurse 
				#Start-Sleep -Seconds 60
			}

#	}


	