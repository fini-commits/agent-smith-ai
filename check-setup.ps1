# Agent Smith Setup Checker
# Run this to verify your environment is ready

Write-Host "🤖 Agent Smith - Environment Check" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

$allGood = $true

# Check Node.js
Write-Host "Checking Node.js..." -NoNewline
try {
    $nodeVersion = node --version
    if ($nodeVersion -match "v(\d+)\.") {
        $majorVersion = [int]$Matches[1]
        if ($majorVersion -ge 18) {
            Write-Host " ✓ $nodeVersion" -ForegroundColor Green
        }
        else {
            Write-Host " ✗ $nodeVersion (need v18+)" -ForegroundColor Red
            $allGood = $false
        }
    }
}
catch {
    Write-Host " ✗ Not installed" -ForegroundColor Red
    $allGood = $false
}

# Check pnpm
Write-Host "Checking pnpm..." -NoNewline
try {
    $pnpmVersion = pnpm --version
    Write-Host " ✓ v$pnpmVersion" -ForegroundColor Green
}
catch {
    Write-Host " ✗ Not installed (run: npm install -g pnpm)" -ForegroundColor Red
    $allGood = $false
}

# Check Python
Write-Host "Checking Python..." -NoNewline
try {
    $pythonVersion = python --version
    if ($pythonVersion -match "(\d+)\.(\d+)") {
        $major = [int]$Matches[1]
        $minor = [int]$Matches[2]
        if ($major -eq 3 -and $minor -ge 11) {
            Write-Host " ✓ $pythonVersion" -ForegroundColor Green
        }
        else {
            Write-Host " ✗ $pythonVersion (need 3.11+)" -ForegroundColor Red
            $allGood = $false
        }
    }
}
catch {
    Write-Host " ✗ Not installed" -ForegroundColor Red
    $allGood = $false
}

# Check Docker
Write-Host "Checking Docker..." -NoNewline
try {
    $dockerVersion = docker --version
    Write-Host " ✓ $dockerVersion" -ForegroundColor Green
}
catch {
    Write-Host " ⚠ Not installed (optional)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Checking files..." -ForegroundColor Cyan

# Check .env
Write-Host "Checking .env..." -NoNewline
if (Test-Path ".env") {
    Write-Host " ✓ Exists" -ForegroundColor Green
}
else {
    Write-Host " ⚠ Missing (copy .env.example)" -ForegroundColor Yellow
}

# Check node_modules
Write-Host "Checking node_modules..." -NoNewline
if (Test-Path "node_modules") {
    Write-Host " ✓ Installed" -ForegroundColor Green
}
else {
    Write-Host " ✗ Run: pnpm install" -ForegroundColor Red
    $allGood = $false
}

# Check Python venvs
Write-Host "Checking orchestrator venv..." -NoNewline
if (Test-Path "services\orchestrator\venv") {
    Write-Host " ✓ Exists" -ForegroundColor Green
}
else {
    Write-Host " ✗ Not created" -ForegroundColor Red
    $allGood = $false
}

Write-Host "Checking worker venv..." -NoNewline
if (Test-Path "workers\terminal\venv") {
    Write-Host " ✓ Exists" -ForegroundColor Green
}
else {
    Write-Host " ✗ Not created" -ForegroundColor Red
    $allGood = $false
}

Write-Host ""
if ($allGood) {
    Write-Host "✓ Environment looks good! Ready to start." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Start services: pnpm dev:all" -ForegroundColor White
    Write-Host "2. Open admin: http://localhost:3000" -ForegroundColor White
    Write-Host "3. Read docs: .\docs\QUICKSTART.md" -ForegroundColor White
}
else {
    Write-Host "✗ Some requirements missing. Check above." -ForegroundColor Red
    Write-Host ""
    Write-Host "Setup guide: .\docs\QUICKSTART.md" -ForegroundColor Yellow
}

Write-Host ""
