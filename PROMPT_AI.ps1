# Agent Smith AI - Where and How to Prompt the AI

Write-Host "`n" -NoNewline
Write-Host "🤖 Agent Smith AI - Prompt Interface" -ForegroundColor Cyan
Write-Host "====================================`n" -ForegroundColor Cyan

# Check if services are running
Write-Host "Checking services..." -ForegroundColor Yellow

try {
    $worker = Invoke-RestMethod -Uri http://localhost:8002/ -TimeoutSec 2
    Write-Host "✅ Worker running on port 8002" -ForegroundColor Green
}
catch {
    Write-Host "❌ Worker not running. Start with:" -ForegroundColor Red
    Write-Host "   cd workers\terminal" -ForegroundColor Gray
    Write-Host "   `$env:ACTIONS_ENABLED='false'; .\.venv\Scripts\uvicorn.exe main:app --port 8002" -ForegroundColor Gray
    exit
}

try {
    $orchestrator = Invoke-RestMethod -Uri http://localhost:8010/ -TimeoutSec 2
    Write-Host "✅ Orchestrator running on port 8010" -ForegroundColor Green
}
catch {
    Write-Host "❌ Orchestrator not running. Start with:" -ForegroundColor Red
    Write-Host "   cd services\orchestrator" -ForegroundColor Gray
    Write-Host "   `$env:MODE='approval'; .\.venv\Scripts\python.exe main.py" -ForegroundColor Gray
    exit
}

Write-Host "`n" -NoNewline
Write-Host "🎯 WHERE TO PROMPT THE AI:" -ForegroundColor Yellow
Write-Host "=========================" -ForegroundColor Yellow
Write-Host "1. 🌐 Web UI (recommended): http://localhost:3000/runs" -ForegroundColor White
Write-Host "   - User-friendly interface" -ForegroundColor Gray
Write-Host "   - View screenshots and steps visually" -ForegroundColor Gray
Write-Host "   - Click to approve/reject steps" -ForegroundColor Gray
Write-Host "`n2. 📡 API Endpoint: POST http://localhost:8010/run" -ForegroundColor White
Write-Host "   - Direct API calls (what we'll demo below)" -ForegroundColor Gray
Write-Host "`n3. 📖 API Docs: http://localhost:8010/docs" -ForegroundColor White
Write-Host "   - Interactive API documentation" -ForegroundColor Gray

Write-Host "`n" -NoNewline
Write-Host "🤖 HOW TO PROMPT THE AI:" -ForegroundColor Yellow
Write-Host "======================" -ForegroundColor Yellow
Write-Host "Send natural language goals like:" -ForegroundColor White
Write-Host '• "Open Calculator and compute 2+2"' -ForegroundColor Gray
Write-Host '• "Open Notepad and type Hello World"' -ForegroundColor Gray  
Write-Host '• "Search for Chrome in Start Menu"' -ForegroundColor Gray
Write-Host '• "Take a screenshot of the desktop"' -ForegroundColor Gray

Write-Host "`n" -NoNewline
Write-Host "🧪 LIVE DEMO - Prompting AI Now:" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

# Example 1: Simple goal
$goal1 = @{ text = "Take a screenshot and identify what's on the desktop" }
Write-Host "`n1️⃣ Sending goal: " -NoNewline -ForegroundColor Yellow
Write-Host '"Take a screenshot and identify what'"'"'s on the desktop"' -ForegroundColor White

try {
    $run1 = Invoke-RestMethod -Method Post -Uri "http://localhost:8010/run" -Body ($goal1 | ConvertTo-Json) -ContentType "application/json"
    Write-Host "✅ AI created run ID: " -NoNewline -ForegroundColor Green
    Write-Host $run1.id -ForegroundColor Yellow
    Write-Host "   Status: " -NoNewline -ForegroundColor Gray
    Write-Host $run1.status -ForegroundColor White
    
    # Get the run details to show steps
    Start-Sleep -Seconds 1
    $runDetails = Invoke-RestMethod -Uri "http://localhost:8010/runs/$($run1.id)"
    Write-Host "   Steps created: " -NoNewline -ForegroundColor Gray
    Write-Host $runDetails.steps.Count -ForegroundColor White
    
    if ($runDetails.steps.Count -gt 0) {
        Write-Host "   First step: " -NoNewline -ForegroundColor Gray
        Write-Host $runDetails.steps[0].action_type -ForegroundColor White
    }
}
catch {
    Write-Host "❌ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n" -NoNewline
Write-Host "📋 VIEW AI RESPONSES:" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow
Write-Host "• List all runs: " -NoNewline -ForegroundColor Gray
Write-Host "Invoke-RestMethod http://localhost:8010/runs" -ForegroundColor White
Write-Host "• View run details: " -NoNewline -ForegroundColor Gray  
Write-Host "Invoke-RestMethod http://localhost:8010/runs/RUN_ID" -ForegroundColor White
Write-Host "• Approve a step: " -NoNewline -ForegroundColor Gray
Write-Host "See APPROVE_STEP.ps1 script" -ForegroundColor White

Write-Host "`n" -NoNewline
Write-Host "🎮 WHAT HAPPENS NEXT:" -ForegroundColor Yellow
Write-Host "===================" -ForegroundColor Yellow
Write-Host "1. AI captures screenshot of your desktop" -ForegroundColor Gray
Write-Host "2. AI creates action steps (click, type, etc.)" -ForegroundColor Gray
Write-Host "3. Steps are in 'pending' status (approval mode)" -ForegroundColor Gray
Write-Host "4. You approve each step manually" -ForegroundColor Gray
Write-Host "5. Worker executes actions (simulated - safe!)" -ForegroundColor Gray

Write-Host "`n" -NoNewline
Write-Host "🔗 Quick Links:" -ForegroundColor Yellow
Write-Host "==============" -ForegroundColor Yellow
Write-Host "• Worker API:      http://localhost:8002/docs" -ForegroundColor White
Write-Host "• Orchestrator API: http://localhost:8010/docs" -ForegroundColor White
Write-Host "• Web UI:          http://localhost:3000 (run: pnpm dev:web)" -ForegroundColor White
Write-Host "• GitHub Repo:     https://github.com/fini-commits/agent-smith-ai" -ForegroundColor White

Write-Host "`n" -NoNewline
Write-Host "💡 Try these commands:" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan
Write-Host "# Prompt the AI with a new goal" -ForegroundColor Gray
Write-Host '$body = @{ text = "Open Calculator app" } | ConvertTo-Json' -ForegroundColor White
Write-Host 'Invoke-RestMethod -Method Post -Uri http://localhost:8010/run -Body $body -ContentType "application/json"' -ForegroundColor White
Write-Host "`n# View all runs" -ForegroundColor Gray
Write-Host 'Invoke-RestMethod http://localhost:8010/runs' -ForegroundColor White
Write-Host "`n# Start the web UI" -ForegroundColor Gray
Write-Host 'pnpm dev:web' -ForegroundColor White

Write-Host "`n🎉 Ready to test! The AI is waiting for your commands.`n" -ForegroundColor Green