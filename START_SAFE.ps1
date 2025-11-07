# Agent Smith - Safe Startup Script
# This runs the system in SIMULATION mode for testing

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Agent Smith - Safe Mode Startup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Configuration:" -ForegroundColor Yellow
Write-Host "  - Worker: ACTIONS_ENABLED=false (simulated actions)" -ForegroundColor Green
Write-Host "  - Orchestrator: MODE=approval (manual approval required)" -ForegroundColor Green
Write-Host "`nThis is SAFE to run on your host machine.`n" -ForegroundColor Green

# Refresh environment variables
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Start terminal worker in background (simulated mode)
Write-Host "[1/2] Starting Terminal Worker (port 8002)..." -ForegroundColor Cyan
$workerJob = Start-Job -ScriptBlock {
    Set-Location 'C:\Users\testuser\Downloads\AgenSmith\workers\terminal'
    $env:ACTIONS_ENABLED = 'false'
    & .\.venv\Scripts\uvicorn.exe main:app --host 0.0.0.0 --port 8002
}

Start-Sleep -Seconds 3

# Start orchestrator in background (approval mode)
Write-Host "[2/2] Starting Orchestrator (port 8010)..." -ForegroundColor Cyan
$orchestratorJob = Start-Job -ScriptBlock {
    Set-Location 'C:\Users\testuser\Downloads\AgenSmith\services\orchestrator'
    $env:MODE = 'approval'
    $env:TERMINAL_URL = 'http://localhost:8002'
    & .\.venv\Scripts\uvicorn.exe main:app --host 0.0.0.0 --port 8010
}

Start-Sleep -Seconds 3

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Services Started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host "`nAPI Endpoints:" -ForegroundColor Yellow
Write-Host "  Orchestrator:  http://localhost:8010" -ForegroundColor White
Write-Host "  Worker:        http://localhost:8002" -ForegroundColor White
Write-Host "  API Docs:      http://localhost:8010/docs" -ForegroundColor White
Write-Host "`nTest the system:" -ForegroundColor Yellow
Write-Host "  Invoke-RestMethod -Uri http://localhost:8010/ | ConvertTo-Json" -ForegroundColor Gray
Write-Host "`nTo stop services:" -ForegroundColor Yellow
Write-Host "  Stop-Job -Id $($workerJob.Id),$($orchestratorJob.Id); Remove-Job -Id $($workerJob.Id),$($orchestratorJob.Id)" -ForegroundColor Gray
Write-Host "`nMonitor logs:" -ForegroundColor Yellow
Write-Host "  Receive-Job -Id $($workerJob.Id) -Keep" -ForegroundColor Gray
Write-Host "  Receive-Job -Id $($orchestratorJob.Id) -Keep" -ForegroundColor Gray
Write-Host "`n"

# Keep script alive
Write-Host "Press Ctrl+C to stop all services...`n" -ForegroundColor Yellow
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    Write-Host "`nStopping services..." -ForegroundColor Yellow
    Stop-Job -Id $workerJob.Id,$orchestratorJob.Id -ErrorAction SilentlyContinue
    Remove-Job -Id $workerJob.Id,$orchestratorJob.Id -ErrorAction SilentlyContinue
    Write-Host "All services stopped.`n" -ForegroundColor Green
}
