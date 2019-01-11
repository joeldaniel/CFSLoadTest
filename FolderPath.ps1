$folders = get-childitem E:\CFS_PowerShell_LoadServer\FileNaming -directory
$i= 1

foreach ($folder in $folders)
{
	$appvpath = $folder.fullname 
	echo($appvpath)
	$Days= 'E:\CFS_PowerShell_LoadServer\FileNaming\'+$folder
	$dates=Get-ChildItem $Days -directory
	$d=1
	foreach ($j in $dates)
	{

			$u = 1
			
			

			$fileLocation = $Days+'\'+$j
			$fileLocation1 = 'E:\CFS_PowerShell_LoadServer\Post\Customer'+$i+'\Day'+$d
			$files = Get-ChildItem -Path $fileLocation
			foreach ($file in $files) 
				{
					$fileLoc = $fileLocation+'\'+$file.Name
				    $newFileName= $fileLocation1+ '\Customer'+$i+'Iteration'+$u+'.xml'
					echo($newFileName)
				    Copy-Item $fileLoc $newFileName
					
					$u++;
					
				}
				$d++;
				echo($i)
			
	}
	$i++;
}

