Start-Process "powershell.exe" -ArgumentList "-File", "C:\autolaunch\docker-container-auto-launcher\pedro2-Copy.ps1" -WindowStyle Minimized

Write-Host "program launched, this window will close soon"
Start-Sleep 10