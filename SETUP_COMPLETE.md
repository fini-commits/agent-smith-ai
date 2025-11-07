# 🤖 Agent Smith - AI Terminal Control System

**Status: ✅ READY TO RUN**

An AI agent system that can control a terminal/desktop environment via screenshots and actions (mouse, keyboard).

## 🚀 Quick Start (Safe Mode)

The system is now fully set up and ready to test! Both services are running:

### Services Running:

- **Terminal Worker**: `http://localhost:8002` (Simulation mode - safe)
- **Orchestrator**: `http://localhost:8010` (Approval mode - manual control)

### Test the APIs:

```powershell
# Test worker
Invoke-RestMethod -Uri http://localhost:8002/

# Test orchestrator
Invoke-RestMethod -Uri http://localhost:8010/

# View API docs
Start-Process http://localhost:8010/docs
```

### Quick Test - Create a Run:

```powershell
# Create a simple test run
$body = @{ text = "Click the start button" } | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri http://localhost:8010/run -Body $body -ContentType "application/json"
```

## 📦 What Was Installed

✅ **System Dependencies:**

- Node.js 24.11.0 (for Next.js frontend)
- Python 3.11.9 (for FastAPI services)
- pnpm 8.15.0 (package manager)

✅ **Project Dependencies:**

- JavaScript packages (393 packages via pnpm)
- Python packages for orchestrator (FastAPI, SQLModel, OpenAI, Anthropic, etc.)
- Python packages for worker (mss, pyautogui, pynput, Pillow)

✅ **Safety Configuration:**

- Worker runs in **simulation mode** (`ACTIONS_ENABLED=false`)
- Orchestrator uses **approval mode** (`MODE=approval`)
- No real mouse/keyboard actions will occur

## 🏗️ Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Web UI        │────▶│   Orchestrator   │────▶│  Terminal       │
│   (Next.js)     │     │   (FastAPI)      │     │  Worker         │
│   Port 3000     │     │   Port 8010      │     │  (FastAPI)      │
│                 │     │                  │     │  Port 8002      │
│  - View runs    │     │  - Control loop  │     │  - Screenshots  │
│  - Approve      │     │  - Planning      │     │  - Actions      │
│    steps        │     │  - State mgmt    │     │  - Simulation   │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

## 🎯 Current Configuration

### Worker (Simulation Mode)

- **Location**: `workers/terminal/`
- **Port**: 8002
- **Mode**: Simulation (`ACTIONS_ENABLED=false`)
- **Status**: ✅ Running
- **Safety**: Actions are simulated, no real mouse/keyboard control

### Orchestrator (Approval Mode)

- **Location**: `services/orchestrator/`
- **Port**: 8010
- **Mode**: Approval (`MODE=approval`)
- **Status**: ✅ Running
- **Behavior**: Creates steps but waits for manual approval before execution

## 📖 API Endpoints

### Worker (`http://localhost:8002`)

- `GET /` - Service info
- `POST /screenshot` - Capture screen
- `POST /action` - Execute action (simulated)
- `GET /health` - Health check

### Orchestrator (`http://localhost:8010`)

- `GET /` - Service info
- `POST /run` - Create new run
- `GET /runs` - List all runs
- `GET /runs/{id}` - Get run details
- `POST /runs/{id}/approve` - Approve a step
- `POST /runs/{id}/reject` - Reject a step
- `GET /settings` - Get settings
- `POST /settings` - Update settings

## 🛡️ Safety Features

1. **Simulation Mode**: Worker won't perform real actions
2. **Approval Mode**: Every step requires manual approval
3. **Rate Limiting**: Max 3 actions/second
4. **Timeouts**: 60s step timeout
5. **Logging**: All screenshots and actions logged

## 🎮 How to Control the System

### Change Modes:

```powershell
# 1. Simulation Mode (safest - no actions at all)
$body = @{ mode = "simulation"; rate_limit = 2; step_timeout = 60 } | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri http://localhost:8010/settings -Body $body -ContentType "application/json"

# 2. Approval Mode (current - manual approval required)
# Already configured!

# 3. Autonomous Mode (⚠️ CAUTION - auto-executes)
# Only use in VM: $body = @{ mode = "autonomous"; rate_limit = 2; step_timeout = 60 } | ConvertTo-Json
```

## 🚧 Development Commands

### Start Services Individually:

```powershell
# Terminal Worker (simulation mode)
cd workers\terminal
$env:ACTIONS_ENABLED='false'
.\.venv\Scripts\uvicorn.exe main:app --host 0.0.0.0 --port 8002

# Orchestrator (approval mode)
cd services\orchestrator
$env:MODE='approval'
$env:TERMINAL_URL='http://localhost:8002'
.\.venv\Scripts\uvicorn.exe main:app --host 0.0.0.0 --port 8010
```

### Run Next.js Frontend:

```powershell
pnpm dev:web
# Visit http://localhost:3000
```

## 📝 Next Steps

1. **Test the worker** - Verify screenshot capture works
2. **Create a test run** - Use the API to create a simple automation
3. **Approve steps** - Practice the approval workflow
4. **Start the web UI** - Run `pnpm dev:web` and view in browser
5. **Integrate VLM** - Add OpenAI API key to `.env` for vision-based planning

## 🔧 Configuration Files

- `workers/terminal/.env.example` - Worker configuration template
- `services/orchestrator/.env.example` - Orchestrator configuration template
- `START_SAFE.ps1` - Safe startup script (both services in safe mode)

## ⚠️ Important Safety Warning

**NEVER run the terminal worker with `ACTIONS_ENABLED=true` on your host machine!**

Real mouse/keyboard control should ONLY be used inside:

- Virtual machines (VMware, VirtualBox, Hyper-V)
- Sandboxed environments
- Dedicated test machines

## 🧪 Testing Example

```powershell
# 1. Take a screenshot
Invoke-RestMethod -Method Post -Uri http://localhost:8002/screenshot

# 2. Create a run
$body = @{ text = "Open notepad and type hello" } | ConvertTo-Json
$run = Invoke-RestMethod -Method Post -Uri http://localhost:8010/run -Body $body -ContentType "application/json"

# 3. Get run details (see pending steps)
$runId = $run.id
Invoke-RestMethod -Uri "http://localhost:8010/runs/$runId"

# 4. Approve a step
$body = @{ step_id = "step-id-from-above" } | ConvertTo-Json
Invoke-RestMethod -Method Post -Uri "http://localhost:8010/runs/$runId/approve" -Body $body -ContentType "application/json"
```

## 📚 Documentation

- `README.md` - This file
- `GETTING_STARTED.md` - Original getting started guide
- `PROJECT_SUMMARY.md` - Project overview
- `docs/QUICKSTART.md` - Quick start guide
- `.github/copilot-instructions.md` - Development guidelines

---

**System Status**: ✅ All services installed and configured  
**Mode**: 🛡️ Safe (Simulation + Approval)  
**Ready for**: Testing, development, AI agent experimentation

Have fun testing the AI agent! 🤖
