#Copy-Item $originalLocation $UploadLocation

	$Days=4

	for($i=1; $i -lt 172;$i++)
	{
			
		$args= $i,$Days
		Start-Job -FilePath E:\CFS_PowerShell_LoadServer\DataPasting.ps1 -ArgumentList $args
		
	}

