$i= 1
$u = 1
#$fileLocation = 'C:\Users\abhiskum\Desktop\Original\Customer6'
#$fileLocation1 = 'C:\Users\abhiskum\Desktop\Original\Customer7'
$fileLocation='C:\Users\abhiskum\Desktop\FileNaming\241'
$fileLocation1 = 'C:\Users\abhiskum\Desktop\FileNaming\Customer1'
$files = Get-ChildItem -Path $fileLocation
foreach ($file in $files) 
{
	$fileLoc = $fileLocation+'\'+$file.Name
    $newFileName= $fileLocation1+ '\Customer'+$i+'Iteration'+$u+'.xml'
	echo($newFileName)
    Copy-Item $fileLoc $newFileName
	#$i++;
	$u++;
}