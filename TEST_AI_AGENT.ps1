# Agent Smith - Interactive Test Script
# This demonstrates the full AI agent workflow

param(
    [string]$Goal = "Open notepad and type 'Hello from Agent Smith'"
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Agent Smith - AI Agent Test" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if services are running
Write-Host "[1/5] Checking services..." -ForegroundColor Yellow
try {
    $worker = Invoke-RestMethod -Uri http://localhost:8002/ -ErrorAction Stop
    Write-Host "  ✓ Worker running: $($worker.service)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Worker not running! Start it first:" -ForegroundColor Red
    Write-Host "    cd workers\terminal; `$env:ACTIONS_ENABLED='false'; .\.venv\Scripts\uvicorn main:app --port 8002" -ForegroundColor Gray
    exit 1
}

try {
    $orchestrator = Invoke-RestMethod -Uri http://localhost:8010/ -ErrorAction Stop
    Write-Host "  ✓ Orchestrator running: $($orchestrator.service)" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Orchestrator not running! Start it first:" -ForegroundColor Red
    Write-Host "    cd services\orchestrator; `$env:MODE='approval'; .\.venv\Scripts\uvicorn main:app --port 8010" -ForegroundColor Gray
    exit 1
}

# Get current settings
Write-Host "`n[2/5] Current configuration..." -ForegroundColor Yellow
$settings = Invoke-RestMethod -Uri http://localhost:8010/settings
Write-Host "  Mode: $($settings.mode)" -ForegroundColor $(if($settings.mode -eq 'autonomous'){'Red'}else{'Green'})
Write-Host "  Rate Limit: $($settings.rate_limit) actions/sec" -ForegroundColor White
Write-Host "  Timeout: $($settings.step_timeout)s" -ForegroundColor White

# Take a screenshot to show current screen
Write-Host "`n[3/5] Capturing current screen state..." -ForegroundColor Yellow
$screenshot = Invoke-RestMethod -Method Post -Uri http://localhost:8002/screenshot
Write-Host "  ✓ Screenshot captured: $($screenshot.width)x$($screenshot.height) pixels" -ForegroundColor Green
Write-Host "  Base64 length: $($screenshot.image_base64.Length) characters" -ForegroundColor Gray

# Create a run with the goal
Write-Host "`n[4/5] Creating AI agent run..." -ForegroundColor Yellow
Write-Host "  Goal: '$Goal'" -ForegroundColor Cyan

$body = @{ text = $Goal } | ConvertTo-Json
try {
    $run = Invoke-RestMethod -Method Post -Uri http://localhost:8010/run -Body $body -ContentType "application/json"
    Write-Host "  ✓ Run created: $($run.id)" -ForegroundColor Green
    Write-Host "  Status: $($run.status)" -ForegroundColor Yellow
    Write-Host "  Total steps planned: $($run.total_steps)" -ForegroundColor White
} catch {
    Write-Host "  ✗ Failed to create run: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Get the run details to see the planned steps
Write-Host "`n[5/5] AI Planning Results..." -ForegroundColor Yellow
$runDetails = Invoke-RestMethod -Uri "http://localhost:8010/runs/$($run.id)"

Write-Host "`n  📋 PLANNED ACTIONS:" -ForegroundColor Cyan
Write-Host "  " + ("="*60) -ForegroundColor Gray

foreach ($step in $runDetails.steps) {
    Write-Host "`n  Step $($step.step_number): $($step.action_type.ToUpper())" -ForegroundColor White
    Write-Host "    ID: $($step.id)" -ForegroundColor Gray
    Write-Host "    Status: $($step.status)" -ForegroundColor $(if($step.status -eq 'pending'){'Yellow'}elseif($step.status -eq 'completed'){'Green'}else{'Red'})
    
    # Show action details
    if ($step.action_data.x) {
        Write-Host "    Position: ($($step.action_data.x), $($step.action_data.y))" -ForegroundColor Gray
    }
    if ($step.action_data.text) {
        Write-Host "    Text: '$($step.action_data.text)'" -ForegroundColor Cyan
    }
    if ($step.action_data.keys) {
        Write-Host "    Keys: $($step.action_data.keys -join '+')" -ForegroundColor Cyan
    }
    
    if ($step.reasoning) {
        Write-Host "    Reasoning: $($step.reasoning)" -ForegroundColor White
    }
}

Write-Host "`n  " + ("="*60) -ForegroundColor Gray

# Show next steps
Write-Host "`n📝 NEXT STEPS:" -ForegroundColor Yellow

if ($settings.mode -eq 'approval') {
    Write-Host "`n  The AI has PLANNED the actions but NOT executed them yet." -ForegroundColor Green
    Write-Host "  You're in APPROVAL mode - you must approve each step manually.`n" -ForegroundColor Green
    
    $firstPendingStep = $runDetails.steps | Where-Object { $_.status -eq 'pending' } | Select-Object -First 1
    
    if ($firstPendingStep) {
        Write-Host "  To approve the FIRST step, run:" -ForegroundColor Cyan
        Write-Host "  `$body = @{ step_id = '$($firstPendingStep.id)' } | ConvertTo-Json" -ForegroundColor Gray
        Write-Host "  Invoke-RestMethod -Method Post -Uri 'http://localhost:8010/runs/$($run.id)/approve' -Body `$body -ContentType 'application/json'" -ForegroundColor Gray
        
        Write-Host "`n  Or to approve it NOW, run:" -ForegroundColor Yellow
        Write-Host "  .\APPROVE_STEP.ps1 -RunId '$($run.id)' -StepId '$($firstPendingStep.id)'" -ForegroundColor White
    }
} elseif ($settings.mode -eq 'simulation') {
    Write-Host "`n  The AI is in SIMULATION mode - actions are only planned, never executed." -ForegroundColor Yellow
} elseif ($settings.mode -eq 'autonomous') {
    Write-Host "`n  ⚠️  The AI is in AUTONOMOUS mode - actions were executed automatically!" -ForegroundColor Red
    Write-Host "  Check the step statuses above to see what happened." -ForegroundColor Yellow
}

Write-Host "`n  View all runs:" -ForegroundColor Cyan
Write-Host "  Invoke-RestMethod -Uri http://localhost:8010/runs" -ForegroundColor Gray

Write-Host "`n  View this run details:" -ForegroundColor Cyan
Write-Host "  Invoke-RestMethod -Uri http://localhost:8010/runs/$($run.id)" -ForegroundColor Gray

Write-Host "`n  Change to autonomous mode (⚠️ CAUTION):" -ForegroundColor Cyan
Write-Host "  `$body = @{ mode = 'autonomous'; rate_limit = 2; step_timeout = 60 } | ConvertTo-Json" -ForegroundColor Gray
Write-Host "  Invoke-RestMethod -Method Post -Uri http://localhost:8010/settings -Body `$body -ContentType 'application/json'" -ForegroundColor Gray

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Test Complete!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green
