# 🎯 Getting Started with Agent Smith

Welcome! This guide will get you from zero to running in about 10 minutes.

## What You'll Build

By the end of this guide, you'll have:
- ✅ A running Next.js admin dashboard
- ✅ A FastAPI orchestrator managing AI workflows
- ✅ A terminal worker that can take screenshots and control the mouse
- ✅ An approval workflow to review every action

## Prerequisites (2 minutes)

Make sure you have:
- **Node.js 18+** - [Download](https://nodejs.org/)
- **Python 3.11+** - [Download](https://www.python.org/)
- **pnpm** - Run: `npm install -g pnpm`
- **Git** (you already have this if you cloned the repo)

Optional but recommended:
- **Docker Desktop** - For PostgreSQL/Redis
- **VS Code** - With recommended extensions

## Step-by-Step Setup

### 1️⃣ Verify Your Environment (1 min)

```powershell
# Run the automated checker
.\check-setup.ps1
```

This will tell you what's missing. If everything shows ✓, continue!

### 2️⃣ Install Node Dependencies (2 min)

```powershell
pnpm install
```

This installs Next.js and all frontend dependencies.

### 3️⃣ Setup Python Services (3 min)

**Orchestrator:**
```powershell
cd services\orchestrator
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
deactivate
cd ..\..
```

**Worker:**
```powershell
cd workers\terminal
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
deactivate
cd ..\..
```

### 4️⃣ Configure Environment (1 min)

```powershell
# Copy the template
copy .env.example .env

# Open and review (no changes needed for local testing)
notepad .env
```

The defaults work fine for getting started. You can add API keys later.

### 5️⃣ Start Everything (2 min)

**Easy Mode - One Command:**
```powershell
.\start-all.ps1
```

This opens 3 PowerShell windows with each service.

**Manual Mode - Three Separate Terminals:**

Terminal 1 - Worker:
```powershell
cd workers\terminal
.\venv\Scripts\activate
python main.py
```

Terminal 2 - Orchestrator:
```powershell
cd services\orchestrator
.\venv\Scripts\activate
python main.py
```

Terminal 3 - Web:
```powershell
pnpm dev:web
```

### 6️⃣ Open the Admin (30 seconds)

Navigate to: **http://localhost:3000**

You should see the Agent Smith dashboard! 🎉

## Your First Run

### Create a Run

1. Click the **"New Run"** button
2. Enter a goal: `"Test the system"`
3. Click OK

### What Happens Next

1. The orchestrator takes a screenshot
2. It creates a simple plan (demo actions)
3. Steps appear as "pending" (in approval mode)

### Review and Approve

1. Click on the run in the list
2. You'll see the run detail page with steps
3. Each step shows:
   - The action to be performed
   - A screenshot (before)
   - Approve/Reject buttons
4. Click **✓ Approve** on the first step
5. Watch it execute!
6. The "after" screenshot appears
7. Continue approving steps

## Understanding the System

### The Flow

```
1. OBSERVE  → Take screenshot of current state
2. PLAN     → AI decides what actions to take
3. ACT      → Execute actions (with approval)
4. VERIFY   → Take another screenshot
```

### Three Modes

**Simulation** 🔬
- Plans actions but doesn't execute
- Safe for testing prompts and logic
- No mouse/keyboard control

**Approval** ✋
- Requires your approval for each action
- You see before/after screenshots
- Safe for real usage

**Autonomous** 🤖
- Executes automatically
- ⚠️ ONLY use in VM/sandbox!
- Full automation

Change modes in: **Settings** → **Execution Mode**

## What's Next?

### Add Intelligence (Optional)

The system currently uses stub actions. To make it smart:

1. Get an API key:
   - [OpenAI API Key](https://platform.openai.com/)
   - Or [Anthropic API Key](https://console.anthropic.com/)

2. Add to `.env`:
   ```bash
   OPENAI_API_KEY=sk-...
   # OR
   ANTHROPIC_API_KEY=sk-ant-...
   ```

3. Update `services/orchestrator/main.py` to call the VLM

### Set Up a VM (Recommended)

Before going autonomous:

1. Set up Windows Sandbox or a VM
2. Install Python and dependencies in the VM
3. Run the worker inside: `python main.py`
4. Point orchestrator to VM IP: `TERMINAL_URL=http://vm-ip:8002`

### Explore the Code

**Web Admin** - `apps/web/src/app/`
- `page.tsx` - Runs list
- `runs/[id]/page.tsx` - Run details
- `settings/page.tsx` - Configuration

**Orchestrator** - `services/orchestrator/main.py`
- Look for the `create_run()` function
- Replace the stub plan with VLM calls

**Worker** - `workers/terminal/main.py`
- See how screenshots are captured
- Review action execution logic

## Troubleshooting

### "Port already in use"

Kill the process:
```powershell
# Find the process
netstat -ano | findstr :3000

# Kill it
taskkill /PID <number> /F
```

### "Module not found"

Make sure virtual environment is activated:
```powershell
.\venv\Scripts\activate
pip install -r requirements.txt
```

### "Can't connect to orchestrator"

Check the orchestrator is running:
- Should see "Running on http://0.0.0.0:8010"
- Check `.env` has correct URL

### "Screenshot failed"

- Make sure `mss` is installed
- Try running PowerShell as Administrator
- Check a display is connected

## Need Help?

- 📖 [Full README](../README.md) - Complete documentation
- 🚀 [Quick Start](QUICKSTART.md) - Detailed setup guide
- 🔧 [API Tests](../api-tests.http) - Test endpoints directly
- 📊 [Project Summary](../PROJECT_SUMMARY.md) - What's included

## Key Files

- `check-setup.ps1` - Verify environment
- `start-all.ps1` - Start all services at once
- `.env.example` - Configuration template
- `api-tests.http` - Test API endpoints
- `docker-compose.yml` - Start PostgreSQL/Redis

## You're Ready! 🚀

You now have a fully functional AI terminal control system. The foundation is solid:

✅ Modern Next.js admin with real-time updates
✅ FastAPI services with async performance
✅ Safety-first architecture with approval workflow
✅ Clean monorepo structure for scaling

Start small, test thoroughly, and gradually add intelligence. Most importantly: **have fun building!** 🤖

---

Questions? Issues? Check the docs or open an issue on GitHub.
