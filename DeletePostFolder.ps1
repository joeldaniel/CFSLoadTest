#Remove-Item "D:\CFS_PowerShell_LoadServer\Post\Customer24\*.*"

$i=1
for($i=1; $i -lt 343;$i++)
{
	for ($j=1; $j -lt 25; $j++)
	{
	$fileLocation1 = 'E:\CFS_PowerShell_LoadServer\Post\Customer'+$i+'\Day'+$j+'\*.*'
	Remove-Item $fileLocation1
	}
}