# Approve a specific step in a run

param(
    [Parameter(Mandatory=$true)]
    [string]$RunId,
    
    [Parameter(Mandatory=$true)]
    [string]$StepId
)

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Approving Step" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Run ID:  $RunId" -ForegroundColor White
Write-Host "Step ID: $StepId`n" -ForegroundColor White

# Get step details before approval
Write-Host "Getting step details..." -ForegroundColor Yellow
$runDetails = Invoke-RestMethod -Uri "http://localhost:8010/runs/$RunId"
$step = $runDetails.steps | Where-Object { $_.id -eq $StepId }

if (-not $step) {
    Write-Host "✗ Step not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Step $($step.step_number): $($step.action_type.ToUpper())" -ForegroundColor Cyan
Write-Host "Status: $($step.status)" -ForegroundColor Yellow

if ($step.status -ne 'pending') {
    Write-Host "`n⚠️  Step is not pending (status: $($step.status))" -ForegroundColor Yellow
    Write-Host "Cannot approve a step that is already $($step.status)" -ForegroundColor Yellow
    exit 1
}

# Show what will be executed
Write-Host "`n📋 Action to execute:" -ForegroundColor White
$step.action_data | ConvertTo-Json | Write-Host -ForegroundColor Gray

Write-Host "`n⚠️  This will execute the action!" -ForegroundColor Yellow
Write-Host "   (In simulation mode, it's just simulated - no real mouse/keyboard action)`n" -ForegroundColor Green

$confirm = Read-Host "Approve this step? (y/N)"
if ($confirm -ne 'y') {
    Write-Host "Cancelled." -ForegroundColor Yellow
    exit 0
}

# Approve the step
Write-Host "`nApproving step..." -ForegroundColor Yellow
$body = @{ step_id = $StepId } | ConvertTo-Json

try {
    $result = Invoke-RestMethod -Method Post -Uri "http://localhost:8010/runs/$RunId/approve" -Body $body -ContentType "application/json"
    
    Write-Host "✓ Step approved and executed!" -ForegroundColor Green
    Write-Host "`nResult:" -ForegroundColor Cyan
    $result.step | ConvertTo-Json -Depth 3 | Write-Host -ForegroundColor Gray
    
    # Get updated run details
    Write-Host "`nUpdated run status:" -ForegroundColor Cyan
    $updatedRun = Invoke-RestMethod -Uri "http://localhost:8010/runs/$RunId"
    Write-Host "  Status: $($updatedRun.status)" -ForegroundColor White
    Write-Host "  Current step: $($updatedRun.current_step) / $($updatedRun.total_steps)" -ForegroundColor White
    
    # Check if there are more pending steps
    $nextPendingStep = $updatedRun.steps | Where-Object { $_.status -eq 'pending' } | Select-Object -First 1
    
    if ($nextPendingStep) {
        Write-Host "`n📋 Next pending step:" -ForegroundColor Yellow
        Write-Host "  Step $($nextPendingStep.step_number): $($nextPendingStep.action_type)" -ForegroundColor White
        Write-Host "`nTo approve next step, run:" -ForegroundColor Cyan
        Write-Host "  .\APPROVE_STEP.ps1 -RunId '$RunId' -StepId '$($nextPendingStep.id)'" -ForegroundColor Gray
    } else {
        Write-Host "`n✓ All steps completed!" -ForegroundColor Green
    }
    
} catch {
    Write-Host "✗ Failed to approve step: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
