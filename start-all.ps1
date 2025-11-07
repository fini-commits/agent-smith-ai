# Agent Smith - Start All Services
# This script starts orchestrator, worker, and web in separate windows

Write-Host "🤖 Starting Agent Smith Services..." -ForegroundColor Cyan
Write-Host ""

# Check if required files exist
if (-not (Test-Path "services\orchestrator\main.py")) {
    Write-Host "✗ Orchestrator not found!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "workers\terminal\main.py")) {
    Write-Host "✗ Worker not found!" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "apps\web\package.json")) {
    Write-Host "✗ Web app not found!" -ForegroundColor Red
    exit 1
}

# Start Worker in new window
Write-Host "Starting Terminal Worker (port 8002)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\workers\terminal'; .\venv\Scripts\activate; python main.py"
Start-Sleep -Seconds 2

# Start Orchestrator in new window
Write-Host "Starting Orchestrator (port 8010)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD\services\orchestrator'; .\venv\Scripts\activate; python main.py"
Start-Sleep -Seconds 2

# Start Web in new window
Write-Host "Starting Web Admin (port 3000)..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; pnpm dev:web"
Start-Sleep -Seconds 2

Write-Host ""
Write-Host "✓ All services starting!" -ForegroundColor Green
Write-Host ""
Write-Host "Services:" -ForegroundColor Cyan
Write-Host "  Worker:       http://localhost:8002" -ForegroundColor White
Write-Host "  Orchestrator: http://localhost:8010" -ForegroundColor White
Write-Host "  Web Admin:    http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  Remember: Run worker in VM for safety!" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press any key to exit this window..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
