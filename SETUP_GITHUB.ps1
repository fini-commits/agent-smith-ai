# GitHub Repository Setup Script
# This initializes git and helps you push to a new GitHub repository

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Agent Smith - GitHub Setup" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "✗ Git is not installed!" -ForegroundColor Red
    Write-Host "  Please install Git from: https://git-scm.com/download/win" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Git found: $(git --version)" -ForegroundColor Green

# Check if already a git repo
if (Test-Path ".git") {
    Write-Host "`n⚠️  This is already a git repository!" -ForegroundColor Yellow
    Write-Host "   Checking status..." -ForegroundColor White
    git status --short
    Write-Host ""
    $continue = Read-Host "Continue with existing repo? (y/N)"
    if ($continue -ne 'y') {
        Write-Host "Cancelled." -ForegroundColor Yellow
        exit 0
    }
} else {
    # Initialize git repo
    Write-Host "`n[1/4] Initializing git repository..." -ForegroundColor Yellow
    git init
    Write-Host "✓ Git repository initialized" -ForegroundColor Green
}

# Check git config
Write-Host "`n[2/4] Checking git configuration..." -ForegroundColor Yellow
$gitUser = git config user.name
$gitEmail = git config user.email

if (-not $gitUser -or -not $gitEmail) {
    Write-Host "⚠️  Git user not configured" -ForegroundColor Yellow
    $userName = Read-Host "Enter your name"
    $userEmail = Read-Host "Enter your email"
    
    git config user.name "$userName"
    git config user.email "$userEmail"
    Write-Host "✓ Git user configured" -ForegroundColor Green
} else {
    Write-Host "✓ Git user: $gitUser <$gitEmail>" -ForegroundColor Green
}

# Add files
Write-Host "`n[3/4] Adding files to git..." -ForegroundColor Yellow
git add .
Write-Host "✓ Files staged" -ForegroundColor Green

# Show what will be committed
Write-Host "`nFiles to commit:" -ForegroundColor Cyan
git status --short | Write-Host -ForegroundColor Gray

# Commit
Write-Host "`n[4/4] Creating initial commit..." -ForegroundColor Yellow
$commitMsg = "Initial commit: Agent Smith AI Terminal Control System

Features:
- FastAPI orchestrator with approval/autonomous/simulation modes
- Terminal worker with screenshot capture and action execution
- Simulation mode for safe testing
- Next.js admin UI (frontend)
- Safety features: rate limiting, timeouts, action approval workflow
- Full Python and Node.js setup with dependencies

Setup:
- Python 3.11+ with virtual environments
- Node.js 24+ with pnpm
- All dependencies installed and configured
"

git commit -m "$commitMsg"
Write-Host "✓ Initial commit created" -ForegroundColor Green

# GitHub instructions
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  Repository Ready for GitHub!" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "Next steps to push to GitHub:`n" -ForegroundColor Yellow

Write-Host "1. Create a new repository on GitHub:" -ForegroundColor Cyan
Write-Host "   https://github.com/new" -ForegroundColor White
Write-Host "   Repository name: agent-smith" -ForegroundColor Gray
Write-Host "   Description: AI Terminal Control System with FastAPI orchestrator" -ForegroundColor Gray
Write-Host "   ⚠️  Do NOT initialize with README, .gitignore, or license`n" -ForegroundColor Yellow

Write-Host "2. After creating the repo, run these commands:" -ForegroundColor Cyan
Write-Host "   git branch -M main" -ForegroundColor Gray
Write-Host "   git remote add origin https://github.com/YOUR_USERNAME/agent-smith.git" -ForegroundColor Gray
Write-Host "   git push -u origin main`n" -ForegroundColor Gray

Write-Host "Or using GitHub CLI (if installed):" -ForegroundColor Cyan
Write-Host "   gh repo create agent-smith --public --source=. --remote=origin --push" -ForegroundColor Gray

Write-Host "`n📝 Repository contents:" -ForegroundColor Yellow
git log --oneline -1
Write-Host ""
git diff --stat --cached HEAD~1 2>$null | Write-Host -ForegroundColor Gray

Write-Host "`n✓ Ready to push!" -ForegroundColor Green
Write-Host ""
