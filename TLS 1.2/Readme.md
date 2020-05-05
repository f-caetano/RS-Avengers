1. **Have .NET Framework 4.5 or newer installed**

2. **Check following registry keys exist (if they don't exist please create them)**

		a) Path: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v4.0.30319
			- "SchUseStrongCrypto" = dword:00000001
			- "SystemDefaultTlsVersions" = dword:00000001
		
		b) Path: HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v4.0.30319
			- "SchUseStrongCrypto" = dword:00000001
			- "SystemDefaultTlsVersions" = dword:00000001
				
		c) Path: HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\.NETFramework\v2.0.50727
			- "SchUseStrongCrypto" = dword:00000001
			- "SystemDefaultTlsVersions" = dword:00000001

		d) Path: HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\v2.0.50727
			- "SchUseStrongCrypto" = dword:00000001
			- "SystemDefaultTlsVersions" = dword:00000001
				
		e) Path: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client
			 “Enabled” = dword:00000001
			- “DisabledByDefault” = dword:00000000
