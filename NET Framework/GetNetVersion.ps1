# Based on the official documentation below
# https://learn.microsoft.com/en-us/dotnet/framework/install/how-to-determine-which-versions-are-installed
#===================================================================================================================================
$RegLocal = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full" -name InstallPath,Release -EA 0
$RegLocal | Select-Object -Property InstallPath, Release, @{name=".NET Framework"; expression={switch ($_.Release) {{$_ -gt 533509}{"Newer than 4.8.1 (Release $($_.Release))"; break}{$_ -ge 533320}{"4.8.1"; break}{$_ -ge 528040}{"4.8"; break}{$_ -ge 461808}{"4.7.2"; break}{$_ -ge 461308}{"4.7.1"; break}{$_ -ge 460798}{"4.7"; break}{$_ -ge 394802}{"4.6.2"; break}{$_ -ge 394254}{"4.6.1"; break}{$_ -ge 393295}{"4.6"; break}{$_ -ge 379893}{"4.5.2"; break}{$_ -ge 378675}{"4.5.1"; break}{$_ -ge 378389}{"4.5"; break}default{"$($_.Release) (Unknown)"}}}} | Format-Table -AutoSize
