	$HostNames = @()
	$HostNames += "reporting.microsft.com"
	$HostNames += "NetBIOS"
	$HostNames += "NetBIOS.domain.com"
	
New-ItemProperty "hklm:SYSTEM\CurrentControlSet\Control\Lsa\MSV1_0" -Type MultiString -PSProperty BackConnectionHostNames -Value $HostNames
	
New-ItemProperty "hklm:\SYSTEM\CurrentControlSet\Services\lanmanserver\parameters" -Name DisableStrictNameChecking -PropertyType DWord -Value 1

# RUN ON POWERSHELL ISE & Edit lines 2 to 4