# 🤖 Agent Smith - Complete Working Example
# This shows you EXACTLY where and how to prompt the AI

Write-Host "🤖 Agent Smith AI - Complete Working Demo" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "`n1️⃣ Starting Services..." -ForegroundColor Yellow

# Start Worker
Write-Host "Starting Terminal Worker (port 8002)..." -ForegroundColor Gray
$workerJob = Start-Job -ScriptBlock {
    Set-Location 'C:\Users\testuser\Downloads\AgenSmith\workers\terminal'
    $env:ACTIONS_ENABLED = 'false'
    & '.\.venv\Scripts\uvicorn.exe' main:app --host 0.0.0.0 --port 8002
}

# Start Orchestrator  
Write-Host "Starting Orchestrator (port 8010)..." -ForegroundColor Gray
$orchestratorJob = Start-Job -ScriptBlock {
    Set-Location 'C:\Users\testuser\Downloads\AgenSmith\services\orchestrator'
    $env:MODE = 'approval'
    $env:TERMINAL_URL = 'http://localhost:8002'
    & '.\.venv\Scripts\python.exe' main.py
}

Write-Host "`nWaiting for services to start..." -ForegroundColor Gray
Start-Sleep -Seconds 5

Write-Host "`n2️⃣ Testing Services..." -ForegroundColor Yellow

# Test Worker
try {
    $worker = Invoke-RestMethod -Uri http://localhost:8002/ -TimeoutSec 3
    Write-Host "✅ Worker running: $($worker.service)" -ForegroundColor Green
} catch {
    Write-Host "❌ Worker not responding" -ForegroundColor Red
    Stop-Job $workerJob, $orchestratorJob -ErrorAction SilentlyContinue
    exit 1
}

# Test Orchestrator
try {
    $orchestrator = Invoke-RestMethod -Uri http://localhost:8010/ -TimeoutSec 3  
    Write-Host "✅ Orchestrator running: $($orchestrator.service)" -ForegroundColor Green
} catch {
    Write-Host "❌ Orchestrator not responding" -ForegroundColor Red
    Stop-Job $workerJob, $orchestratorJob -ErrorAction SilentlyContinue
    exit 1
}

Write-Host "`n3️⃣ WHERE TO PROMPT THE AI:" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "🌐 Web UI (Best):     http://localhost:3000/runs (run: pnpm dev:web)" -ForegroundColor White
Write-Host "📡 API Direct:        POST http://localhost:8010/run" -ForegroundColor White  
Write-Host "📖 API Docs:          http://localhost:8010/docs" -ForegroundColor White

Write-Host "`n4️⃣ PROMPTING THE AI NOW:" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan

# Example Goal
$exampleGoal = "Take a screenshot and identify what applications are visible on the desktop"
Write-Host "Sending goal: " -NoNewline -ForegroundColor Yellow
Write-Host """$exampleGoal""" -ForegroundColor White

$goalJson = @{ text = $exampleGoal } | ConvertTo-Json
try {
    $run = Invoke-RestMethod -Method Post -Uri "http://localhost:8010/run" -Body $goalJson -ContentType "application/json" -TimeoutSec 10
    
    Write-Host "`n✅ AI RESPONSE:" -ForegroundColor Green
    Write-Host "Run ID:    $($run.id)" -ForegroundColor White
    Write-Host "Status:    $($run.status)" -ForegroundColor White
    Write-Host "Goal:      $($run.goal)" -ForegroundColor White
    Write-Host "Steps:     $($run.total_steps)" -ForegroundColor White
    
    # Get detailed run info
    Start-Sleep -Seconds 2
    $runDetails = Invoke-RestMethod -Uri "http://localhost:8010/runs/$($run.id)" -TimeoutSec 5
    
    Write-Host "`n📋 PLANNED STEPS:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $runDetails.steps.Count; $i++) {
        $step = $runDetails.steps[$i]
        Write-Host "Step $($step.step_number): $($step.action_type) - $($step.status)" -ForegroundColor Gray
        if ($step.reasoning) {
            Write-Host "  Reasoning: $($step.reasoning)" -ForegroundColor DarkGray
        }
    }
    
    Write-Host "`n5️⃣ WHAT TO DO NEXT:" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    Write-Host "The AI has planned steps but they're PENDING approval." -ForegroundColor White
    Write-Host "To approve a step:" -ForegroundColor Gray
    Write-Host "  1. Get step ID from above" -ForegroundColor Gray
    Write-Host "  2. Run: .\APPROVE_STEP.ps1" -ForegroundColor Gray
    Write-Host "  3. Or use API: POST /runs/$($run.id)/approve" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Failed to prompt AI: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n6️⃣ TRY THESE GOALS:" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host '• "Open Calculator and compute 5 + 3"' -ForegroundColor Gray
Write-Host '• "Search for Notepad in Start Menu"' -ForegroundColor Gray
Write-Host '• "Take a screenshot of the taskbar"' -ForegroundColor Gray
Write-Host '• "Open File Explorer and navigate to Downloads"' -ForegroundColor Gray

Write-Host "`n7️⃣ API COMMANDS TO COPY/PASTE:" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
Write-Host "# Prompt the AI:" -ForegroundColor Gray
Write-Host '$goal = @{ text = "Your goal here" } | ConvertTo-Json' -ForegroundColor White
Write-Host 'Invoke-RestMethod -Method Post -Uri http://localhost:8010/run -Body $goal -ContentType "application/json"' -ForegroundColor White
Write-Host "`n# View all runs:" -ForegroundColor Gray  
Write-Host 'Invoke-RestMethod http://localhost:8010/runs' -ForegroundColor White
Write-Host "`n# View run details:" -ForegroundColor Gray
Write-Host 'Invoke-RestMethod http://localhost:8010/runs/RUN_ID_HERE' -ForegroundColor White

Write-Host "`n🎮 Services are running! Press Ctrl+C to stop." -ForegroundColor Green
Write-Host "Monitor logs with:" -ForegroundColor Gray
Write-Host "  Receive-Job -Id $($workerJob.Id) -Keep" -ForegroundColor White
Write-Host "  Receive-Job -Id $($orchestratorJob.Id) -Keep" -ForegroundColor White

# Keep services running
try {
    while ($true) {
        Start-Sleep -Seconds 1
    }
} finally {
    Write-Host "`nStopping services..." -ForegroundColor Yellow
    Stop-Job $workerJob, $orchestratorJob -ErrorAction SilentlyContinue
    Remove-Job $workerJob, $orchestratorJob -ErrorAction SilentlyContinue
    Write-Host "Services stopped." -ForegroundColor Green
}