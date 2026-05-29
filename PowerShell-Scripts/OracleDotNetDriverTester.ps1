<#
ODP.NET Unmanaged & Managed Test (leverages Power BI Desktop for Oracle.ManagedDataAccess.dll)
Script for troubleshooting/testing only.
Provided as-is. Review and test before use.
#>
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Resolves the managed driver's dependencies from the Power BI Desktop.
$script:ResolverReady = $false
try {
    Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;

public static class OdacResolver {
    static Dictionary<string, List<string>> _index;
    static bool _hooked;
    static readonly object _lock = new object();

    public static void Register(string root) {
        lock (_lock) {
            if (_index == null) {
                _index = new Dictionary<string, List<string>>(StringComparer.OrdinalIgnoreCase);
                try {
                    foreach (var f in Directory.GetFiles(root, "*.dll", SearchOption.AllDirectories)) {
                        var name = Path.GetFileNameWithoutExtension(f);
                        List<string> list;
                        if (!_index.TryGetValue(name, out list)) { list = new List<string>(); _index[name] = list; }
                        list.Add(f);
                    }
                } catch { }
            }
            if (!_hooked) { AppDomain.CurrentDomain.AssemblyResolve += Resolve; _hooked = true; }
        }
    }

    static Assembly Resolve(object sender, ResolveEventArgs args) {
        try {
            var req = new AssemblyName(args.Name);
            List<string> files;
            if (_index == null || !_index.TryGetValue(req.Name, out files)) return null;
            string pick = null;
            foreach (var f in files) {
                try { if (AssemblyName.GetAssemblyName(f).Version == req.Version) { pick = f; break; } } catch { }
            }
            if (pick == null) pick = files[0];
            return Assembly.LoadFrom(pick);
        } catch { return null; }
    }
}
'@
    $script:ResolverReady = $true
} catch { }

$ScriptPath = $PSCommandPath

#region Helpers

function Test-IsAdmin {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    (New-Object System.Security.Principal.WindowsPrincipal($id)).IsInRole(
        [System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin) -and $PSCommandPath) {
    try {
        Start-Process -FilePath (Join-Path $PSHOME 'powershell.exe') `
            -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    } catch { }
}

function Show-Msg($Text, $Title, [string]$Icon = 'Warning') {
    [Windows.Forms.MessageBox]::Show($Text, $Title,
        [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::$Icon) | Out-Null
}

function Test-DriverPresent {
    try { [void][System.Data.Common.DbProviderFactories]::GetFactory("Oracle.DataAccess.Client"); $true }
    catch { $false }
}

function Get-ConfiguredFetchSize {
    $key = Get-ChildItem "HKLM:\SOFTWARE\Oracle\ODP.NET" -ErrorAction SilentlyContinue |
           Where-Object { $null -ne (Get-ItemProperty $_.PSPath -Name FetchSize -ErrorAction SilentlyContinue).FetchSize } |
           Select-Object -First 1
    if (-not $key) { return $null }
    [pscustomobject]@{
        Value = [int64](Get-ItemProperty $key.PSPath -Name FetchSize).FetchSize
        Path  = $key.PSPath -replace '^Microsoft\.PowerShell\.Core\\Registry::', ''
    }
}

function Get-ManagedDriverPath {
    $rel = 'bin\ADO.NET Providers\ODAC\Oracle.ManagedDataAccess.dll'
    $pf = ${env:ProgramFiles}
    if ($pf) {
        $p = Join-Path $pf "Microsoft Power BI Desktop\$rel"
        if (Test-Path $p) { return $p }
    }
    foreach ($r in 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
                   'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*') {
        $hits = Get-ItemProperty $r -ErrorAction SilentlyContinue |
                Where-Object { $_.DisplayName -like '*Power BI Desktop*' -and $_.InstallLocation }
        foreach ($h in $hits) {
            $p = Join-Path $h.InstallLocation $rel
            if (Test-Path $p) { return $p }
        }
    }
    $null
}

#endregion

# Runs in a background runspace so the window stays responsive.
$QueryScript = {
    param($DbHost, $Port, $ServiceName, $UserName, $Password, $SqlQuery, $OutputCsv, $Provider, $ManagedDll)

    $dataSource = "(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=$DbHost)(PORT=$Port))(CONNECT_DATA=(SERVICE_NAME=$ServiceName)))"

    if ($Provider -eq 'Managed') {
        $binRoot = Split-Path (Split-Path (Split-Path $ManagedDll))
        [OdacResolver]::Register($binRoot)
        $asm     = [Reflection.Assembly]::LoadFrom($ManagedDll)
        $conn    = [Activator]::CreateInstance($asm.GetType('Oracle.ManagedDataAccess.Client.OracleConnection'))
        $builder = [Activator]::CreateInstance($asm.GetType('Oracle.ManagedDataAccess.Client.OracleConnectionStringBuilder'))
    } else {
        $factory = [System.Data.Common.DbProviderFactories]::GetFactory("Oracle.DataAccess.Client")
        $conn    = $factory.CreateConnection()
        $builder = $factory.CreateConnectionStringBuilder()
    }

    $builder['User Id']     = $UserName
    $builder['Password']    = $Password
    $builder['Data Source'] = $dataSource
    $builder['Pooling']     = $false
    $conn.ConnectionString  = $builder.ConnectionString

    $driverDll = $conn.GetType().Assembly.Location

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $rows = 0; $connectSec = 0; $execSec = 0; $fetchSec = 0; $clientSec = 0
    $cmd = $null; $reader = $null; $stream = $null; $cmdType = $null
    $connectionOnly = [string]::IsNullOrWhiteSpace($SqlQuery)

    try {
        $conn.Open()
        $connectSec = $sw.Elapsed.TotalSeconds

        if (-not $connectionOnly) {
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = $SqlQuery
            $cmdType = $cmd.GetType().FullName

            $es = $sw.Elapsed.TotalSeconds
            $reader = $cmd.ExecuteReader()
            $execSec = $sw.Elapsed.TotalSeconds - $es
            $readerStart = $sw.Elapsed.TotalSeconds

            $fieldCount = $reader.FieldCount
            $values = New-Object object[] $fieldCount
            $freq = [System.Diagnostics.Stopwatch]::Frequency
            $fetchTicks = [long]0

            if ([string]::IsNullOrWhiteSpace($OutputCsv)) {
                while ($true) {
                    $t0 = [System.Diagnostics.Stopwatch]::GetTimestamp()
                    $more = $reader.Read()
                    $fetchTicks += [System.Diagnostics.Stopwatch]::GetTimestamp() - $t0
                    if (-not $more) { break }
                    [void]$reader.GetValues($values)
                    $rows++
                }
            }
            else {
                $stream = [System.IO.StreamWriter]::new($OutputCsv, $false, [System.Text.UTF8Encoding]::new($true))
                $sb = [System.Text.StringBuilder]::new()
                $stream.WriteLine(((0..($fieldCount-1) | ForEach-Object { $reader.GetName($_) }) -join ','))
                while ($true) {
                    $t0 = [System.Diagnostics.Stopwatch]::GetTimestamp()
                    $more = $reader.Read()
                    $fetchTicks += [System.Diagnostics.Stopwatch]::GetTimestamp() - $t0
                    if (-not $more) { break }
                    [void]$reader.GetValues($values)
                    [void]$sb.Clear()
                    for ($i = 0; $i -lt $fieldCount; $i++) {
                        if ($i -gt 0) { [void]$sb.Append(',') }
                        $v = $values[$i]
                        if ($null -ne $v -and -not ($v -is [System.DBNull])) {
                            $s = [string]$v
                            if ($s.IndexOfAny([char[]]@(',','"',"`r","`n")) -ge 0) {
                                [void]$sb.Append('"').Append($s.Replace('"','""')).Append('"')
                            } else { [void]$sb.Append($s) }
                        }
                    }
                    $stream.WriteLine($sb.ToString())
                    $rows++
                }
            }

            $readerSec = $sw.Elapsed.TotalSeconds - $readerStart
            $fetchSec  = $fetchTicks / $freq
            $clientSec = $readerSec - $fetchSec
        }
    }
    finally {
        if ($stream) { try { $stream.Flush() } catch {}; $stream.Dispose() }
        if ($reader) { $reader.Dispose() }
        if ($cmd)    { $cmd.Dispose() }
        if ($conn)   { $conn.Close(); $conn.Dispose() }
        $sw.Stop()
    }

    [pscustomobject]@{
        Rows = $rows; ConnectSec = $connectSec; ExecSec = $execSec
        FetchSec = $fetchSec; ClientSec = $clientSec; ConnectionOnly = $connectionOnly
        TotalSec = $sw.Elapsed.TotalSeconds; OutputCsv = $OutputCsv
        DriverDll = $driverDll; CommandType = $cmdType; CommandText = $SqlQuery
    }
}

#region UI

$form = New-Object Windows.Forms.Form
$form.Text = "Oracle .NET Driver Test"
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.Font = New-Object Drawing.Font("Segoe UI", 9)

$y = 12

$lblHeader = New-Object Windows.Forms.Label
$lblHeader.Text = "Testing Unmanaged & Managed Oracle drivers"
$lblHeader.Location = New-Object Drawing.Point(15, $y)
$lblHeader.Size = New-Object Drawing.Size(600, 16)
$lblHeader.Font = New-Object Drawing.Font("Segoe UI", 8, [Drawing.FontStyle]::Bold)
$lblHeader.ForeColor = "DimGray"
$form.Controls.Add($lblHeader); $y += 22

function Add-Label($text) {
    $l = New-Object Windows.Forms.Label
    $l.Text = $text; $l.Location = New-Object Drawing.Point(15, $script:y)
    $l.Size = New-Object Drawing.Size(140, 22); $form.Controls.Add($l)
}

function Add-Field($placeholder, [int]$height = 22, [bool]$password = $false) {
    $t = New-Object Windows.Forms.TextBox
    $t.Location = New-Object Drawing.Point(160, $script:y)
    $t.Size = New-Object Drawing.Size(440, $height)
    if ($height -gt 30) { $t.Multiline = $true; $t.ScrollBars = "Vertical" }

    $normalFont = $form.Font
    $cueFont    = New-Object Drawing.Font($form.Font, [Drawing.FontStyle]::Italic)
    $t | Add-Member -NotePropertyName Placeholder -NotePropertyValue $placeholder
    $t | Add-Member -NotePropertyName IsCue        -NotePropertyValue $true

    $showCue = {
        param($tb)
        $tb.IsCue = $true; $tb.ForeColor = 'Gray'; $tb.Font = $cueFont
        if ($password) { $tb.UseSystemPasswordChar = $false }
        $tb.Text = $tb.Placeholder
    }
    $hideCue = {
        param($tb)
        $tb.IsCue = $false; $tb.ForeColor = 'Black'; $tb.Font = $normalFont
        if ($password) { $tb.UseSystemPasswordChar = $true }
        $tb.Text = ''
    }

    if ([string]::IsNullOrEmpty($placeholder)) { & $hideCue $t } else { & $showCue $t }

    $t.Add_Enter({ if ($this.IsCue) { & $hideCue $this } }.GetNewClosure())
    $t.Add_Leave({ if ([string]::IsNullOrEmpty($this.Text)) { & $showCue $this } }.GetNewClosure())

    $form.Controls.Add($t)
    $script:y += $height + 10
    return $t
}

function Get-Val($tb) { if ($tb.IsCue) { "" } else { $tb.Text } }

$script:ManagedDll = Get-ManagedDriverPath

Add-Label "Driver"
$cboDriver = New-Object Windows.Forms.ComboBox
$cboDriver.DropDownStyle = "DropDownList"
$cboDriver.Location = New-Object Drawing.Point(160, $y)
$cboDriver.Size = New-Object Drawing.Size(440, 22)
[void]$cboDriver.Items.Add("Oracle Unmanaged (ODP.NET)")
[void]$cboDriver.Items.Add("Oracle Managed (Preview - Requires PBID standalone)")
$cboDriver.SelectedIndex = 0
$cboDriver.Add_SelectedIndexChanged({
    if ($cboDriver.SelectedIndex -eq 1) {
        if ($script:ManagedDll) { $txtOut.Text = "Managed driver:`r`n$script:ManagedDll" }
        else { $txtOut.Text = "Managed driver not found (Power BI Desktop not detected)." }
    }
    else { $txtOut.Text = $script:startupNotes -join "`r`n" }
})
$form.Controls.Add($cboDriver); $y += 32

Add-Label "Host";         $txtHost    = Add-Field "HOST"
Add-Label "Port";         $txtPort    = Add-Field "1521"
Add-Label "Service Name"; $txtService = Add-Field "SERVICE_NAME"
Add-Label "User Name";    $txtUser    = Add-Field "OracleUser"
Add-Label "Password";     $txtPass    = Add-Field "" 22 $true
Add-Label "SQL Query (optional)"; $txtSql     = Add-Field "SELECT * FROM table WHERE ROWNUM <= 40000" 70

Add-Label "Save to CSV (optional)"
$txtCsv = Add-Field "C:\temp\file.csv"
$btnBrowse = New-Object Windows.Forms.Button
$btnBrowse.Text = "..."; $btnBrowse.Size = New-Object Drawing.Size(36, 22)
$btnBrowse.Location = New-Object Drawing.Point(564, ($txtCsv.Top))
$txtCsv.Width = 398
$btnBrowse.Add_Click({
    $dlg = New-Object Windows.Forms.SaveFileDialog
    $dlg.Filter = "CSV files (*.csv)|*.csv"; $dlg.FileName = "file.csv"
    if ($dlg.ShowDialog() -eq "OK") {
        if ($txtCsv.IsCue) { $txtCsv.IsCue = $false; $txtCsv.ForeColor = 'Black'; $txtCsv.Font = $form.Font }
        $txtCsv.Text = $dlg.FileName
    }
})
$form.Controls.Add($btnBrowse)

$fetch = Get-ConfiguredFetchSize
if ($fetch) {
    Add-Label "Configured FetchSize"
    $lblFetch = New-Object Windows.Forms.Label
    $lblFetch.Text = "{0:0.#} MB" -f ($fetch.Value / 1MB)
    $lblFetch.Location = New-Object Drawing.Point(160, $y)
    $lblFetch.Size = New-Object Drawing.Size(440, 18); $form.Controls.Add($lblFetch); $y += 20

    $lblPath = New-Object Windows.Forms.Label
    $lblPath.Text = $fetch.Path
    $lblPath.Location = New-Object Drawing.Point(160, $y)
    $lblPath.Size = New-Object Drawing.Size(460, 16); $lblPath.ForeColor = "Gray"
    $lblPath.Font = New-Object Drawing.Font("Segoe UI", 7.5)
    $form.Controls.Add($lblPath); $y += 24
} else {
    $lblFetch = New-Object Windows.Forms.Label
    $lblFetch.Text = "Configured FetchSize: not found (run as Administrator to read the registry)"
    $lblFetch.Location = New-Object Drawing.Point(15, $y)
    $lblFetch.Size = New-Object Drawing.Size(600, 18); $lblFetch.ForeColor = "Gray"
    $form.Controls.Add($lblFetch); $y += 24
}

$btnRun = New-Object Windows.Forms.Button
$btnRun.Text = "Run"; $btnRun.Location = New-Object Drawing.Point(15, $y)
$btnRun.Size = New-Object Drawing.Size(110, 32); $form.Controls.Add($btnRun)

$btnCancel = New-Object Windows.Forms.Button
$btnCancel.Text = "Cancel"; $btnCancel.Location = New-Object Drawing.Point(133, $y)
$btnCancel.Size = New-Object Drawing.Size(90, 32); $btnCancel.Enabled = $false
$form.Controls.Add($btnCancel)

$btnSource = New-Object Windows.Forms.Button
$btnSource.Text = "Review source code"; $btnSource.Location = New-Object Drawing.Point(231, $y)
$btnSource.Size = New-Object Drawing.Size(150, 32); $form.Controls.Add($btnSource)
$btnSource.Add_Click({
    if ($ScriptPath -and (Test-Path $ScriptPath)) { Start-Process notepad.exe $ScriptPath }
    else { Show-Msg "Source path is unknown (script not run from a file)." "Source" "Information" }
})
$y += 42

$txtOut = New-Object Windows.Forms.TextBox
$txtOut.Multiline = $true; $txtOut.ScrollBars = "Vertical"; $txtOut.ReadOnly = $true
$txtOut.Font = New-Object Drawing.Font("Consolas", 9)
$txtOut.Location = New-Object Drawing.Point(15, $y)
$txtOut.Size = New-Object Drawing.Size(600, 210); $form.Controls.Add($txtOut)
$form.ClientSize = New-Object Drawing.Size(630, ($txtOut.Bottom + 12))

#endregion

#region Startup checks

$script:startupNotes = @()
if (-not [Environment]::Is64BitProcess) {
    $script:startupNotes += "WARNING: 32-bit PowerShell process. Please launch the 64-bit PowerShell."
}
if (-not (Test-DriverPresent)) {
    $script:startupNotes += "WARNING: Unmanaged driver (Oracle.DataAccess.Client) not found. Install ODAC (64-bit): https://www.oracle.com/database/technologies/appdev/ocmt.html"
}
if (-not $script:ManagedDll) {
    $script:startupNotes += "WARNING: Power BI Desktop installation not found/recognized. Test only standalone version: https://aka.ms/pbiSingleInstaller (windows store not supported with this test)"
}
if (-not (Test-IsAdmin)) {
    $script:startupNotes += "WARNING: Not running as Administrator. Please open PowerShell with elevated permissions."
}
if ($script:startupNotes.Count) { $txtOut.Text = $script:startupNotes -join "`r`n" }

#endregion

#region Run / Cancel

$script:rs = $null; $script:ps = $null; $script:handle = $null; $script:cancelling = $false

$timer = New-Object Windows.Forms.Timer
$timer.Interval = 200

function Stop-Run {
    $timer.Stop()
    if ($script:ps)     { $script:ps.Dispose() }
    if ($script:rs)     { $script:rs.Close(); $script:rs.Dispose() }
    $script:ps = $null; $script:rs = $null; $script:handle = $null; $script:cancelling = $false
    $btnRun.Enabled = $true; $btnCancel.Enabled = $false
    $btnRun.Focus() | Out-Null
}

$timer.Add_Tick({
    if (-not ($script:handle -and $script:handle.IsCompleted)) { return }

    $timer.Stop()
    $completed = $script:handle
    $script:handle = $null

    if ($script:cancelling) {
        $txtOut.Text = "Cancelled."
        Stop-Run
        return
    }

    try {
        $r = $script:ps.EndInvoke($completed) | Select-Object -First 1
        if ($script:ps.HadErrors -and $script:ps.Streams.Error.Count) {
            throw $script:ps.Streams.Error[0].Exception
        }
        $lines = @()
        if ($r.ConnectionOnly) {
            $lines += "Driver DLL                     : $($r.DriverDll)"
            $lines += ""
            $lines += "OracleConnection.Open()        : {0,8:N3} sec" -f $r.ConnectSec
            $lines += ""
            $lines += "Result                         : Connection succeeded"
            $txtOut.Text = $lines -join "`r`n"
            Stop-Run
            return
        }
        $lines += "Driver DLL                     : $($r.DriverDll)"
        $lines += "Object                         : $($r.CommandType)"
        $lines += "Command Text                   : $($r.CommandText)"
        $lines += ""
        $lines += "OracleConnection.Open()        : {0,8:N3} sec" -f $r.ConnectSec
        $lines += "OracleCommand.ExecuteReader()  : {0,8:N3} sec" -f $r.ExecSec
        $lines += "OracleDataReader.Read() x rows : {0,8:N3} sec" -f $r.FetchSec
        $lines += "Total                          : {0,8:N3} sec" -f ($r.ConnectSec + $r.ExecSec + $r.FetchSec)
        if ($r.OutputCsv) {
            $lines += ""
            $lines += "CSV serialize + write          : {0,8:N3} sec" -f $r.ClientSec
            $lines += ""
            $lines += "Total (driver + CSV)           : {0,8:N3} sec" -f $r.TotalSec
            $lines += "CSV Path                       : $($r.OutputCsv)"
        }
        $lines += "Rows Read                      : {0:N0}" -f $r.Rows
        $txtOut.Text = $lines -join "`r`n"
        Stop-Run
    }
    catch {
        $txtOut.Text = "Failed: " + $_.Exception.Message
        Stop-Run
        Show-Msg $_.Exception.Message "Error" "Error"
    }
})

$btnRun.Add_Click({
    $h = Get-Val $txtHost; $svc = Get-Val $txtService; $usr = Get-Val $txtUser; $sql = Get-Val $txtSql
    if ([string]::IsNullOrWhiteSpace($h) -or [string]::IsNullOrWhiteSpace($svc) -or
        [string]::IsNullOrWhiteSpace($usr)) {
        Show-Msg "Host, Service Name and User Name are required." "Missing input"
        return
    }
    $portText = Get-Val $txtPort; if ([string]::IsNullOrWhiteSpace($portText)) { $portText = "1521" }
    $port = 0
    if (-not [int]::TryParse($portText, [ref]$port) -or $port -le 0 -or $port -gt 65535) {
        Show-Msg "Port must be a number between 1 and 65535." "Invalid input"
        return
    }
    $csv = Get-Val $txtCsv
    if (-not [string]::IsNullOrWhiteSpace($csv)) {
        $dir = Split-Path $csv -Parent
        if ($dir -and -not (Test-Path $dir)) {
            Show-Msg "Folder does not exist: $dir" "Invalid CSV path"
            return
        }
    }

    $provider = if ($cboDriver.SelectedIndex -eq 1) { 'Managed' } else { 'Unmanaged' }
    if ($provider -eq 'Unmanaged' -and -not (Test-DriverPresent)) {
        Show-Msg "Unmanaged driver (Oracle.DataAccess.Client) not found. Install ODAC, or select the Managed driver." "Unmanaged driver not found"
        return
    }
    if ($provider -eq 'Managed' -and -not $script:ManagedDll) {
        Show-Msg "Oracle Managed driver not found. Install Power BI Desktop, or use the Unmanaged driver." "Managed driver not found"
        return
    }
    if ($provider -eq 'Managed' -and -not $script:ResolverReady) {
        Show-Msg "Managed driver support is unavailable (dependency resolver could not be initialized on this machine). Use the Unmanaged driver." "Managed driver unavailable"
        return
    }

    $btnRun.Enabled = $false; $btnCancel.Enabled = $true
    $txtOut.Text = "Running..."

    $script:rs = [runspacefactory]::CreateRunspace(); $script:rs.Open()
    $script:ps = [powershell]::Create(); $script:ps.Runspace = $script:rs
    [void]$script:ps.AddScript($QueryScript).AddParameters(@{
        DbHost = $h; Port = $port; ServiceName = $svc; UserName = $usr
        Password = $txtPass.Text; SqlQuery = $sql; OutputCsv = $csv
        Provider = $provider; ManagedDll = $script:ManagedDll
    })
    $script:handle = $script:ps.BeginInvoke()
    $timer.Start()
})

$btnCancel.Add_Click({
    if ($script:ps -and -not $script:cancelling) {
        $script:cancelling = $true
        $btnCancel.Enabled = $false
        $txtOut.Text = "Cancelling..."
        try { [void]$script:ps.BeginStop($null, $null) } catch {}
    }
})

$form.Add_FormClosed({
    $timer.Stop()
    if ($script:ps) { try { [void]$script:ps.BeginStop($null, $null) } catch {} }
})

#endregion

[Windows.Forms.Application]::add_ThreadException({
    param($sender, $e)
    try { Show-Msg $e.Exception.Message "Unexpected error (the tool stays running)" "Error" } catch {}
})

try {
    [void]$form.ShowDialog()
}
finally {
    $timer.Stop()
    try { $form.Dispose() } catch {}
}
