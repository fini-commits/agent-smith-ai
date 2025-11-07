# 🚀 Quick Setup Guide

Follow these steps to get Agent Smith running in 5 minutes.

## Step 1: Prerequisites Check

```powershell
# Check Node.js (need 18+)
node --version

# Check pnpm (need 8+)
pnpm --version
# If not installed: npm install -g pnpm

# Check Python (need 3.11+)
python --version

# Check Docker
docker --version
```

## Step 2: Install Dependencies

```powershell
# Install Node dependencies
pnpm install

# Create Python virtual environments
cd services\orchestrator
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
deactivate

cd ..\..\workers\terminal
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
deactivate

cd ..\..
```

## Step 3: Configure Environment

```powershell
# Copy environment template
copy .env.example .env

# Edit .env and add your API keys (optional for now)
notepad .env
```

Minimal `.env` for local testing:
```bash
TERMINAL_URL=http://localhost:8002
NEXT_PUBLIC_ORCHESTRATOR_URL=http://localhost:8010
MODE=approval
```

## Step 4: Start Database (Optional)

```powershell
# Start PostgreSQL and Redis
docker compose up -d

# Check they're running
docker compose ps
```

## Step 5: Start Services

Open **3 separate terminals**:

### Terminal 1 - Worker (⚠️ Run in VM for safety!)
```powershell
cd workers\terminal
.\venv\Scripts\activate
python main.py
# Should see: Running on http://0.0.0.0:8002
```

### Terminal 2 - Orchestrator
```powershell
cd services\orchestrator
.\venv\Scripts\activate
python main.py
# Should see: Running on http://0.0.0.0:8010
```

### Terminal 3 - Web Admin
```powershell
pnpm dev:web
# Should see: Ready on http://localhost:3000
```

## Step 6: Test It Out

1. Open http://localhost:3000
2. Click **"New Run"**
3. Enter goal: `"Test the mouse movement"`
4. Watch it create a run and plan actions
5. Go to the run detail page
6. Click **✓ Approve** to execute each step

## 🎉 You're Running!

### What's Happening?

1. **Orchestrator** takes a screenshot from the **Worker**
2. Plans some demo actions (move mouse, click, type)
3. Creates steps in "pending" state (approval mode)
4. You approve each step
5. Worker executes the action
6. Screenshots show before/after

### Next Steps

- Configure VLM API key (OpenAI/Anthropic) for real planning
- Create a VM to run the worker safely
- Try different execution modes in Settings
- Build custom workflows

## ⚠️ Safety Reminder

The terminal worker controls your mouse and keyboard. For now it's running on your host machine with simple demo actions. 

**Before going autonomous:**
1. Set up a Windows Sandbox or VM
2. Run worker inside the sandbox
3. Test thoroughly in approval mode first

## 🐛 Troubleshooting

**Port already in use:**
```powershell
# Find and kill process using port 3000/8010/8002
netstat -ano | findstr :3000
taskkill /PID <PID> /F
```

**Python module not found:**
```powershell
# Make sure venv is activated
.\venv\Scripts\activate
pip install -r requirements.txt
```

**Can't connect to orchestrator:**
- Check orchestrator is running on port 8010
- Check .env has correct NEXT_PUBLIC_ORCHESTRATOR_URL
- Check no firewall blocking

**Worker can't take screenshot:**
- Make sure mss is installed
- Try running as administrator (Windows)
- Check display/screen is accessible

## 📚 Resources

- [Full README](../README.md) - Complete documentation
- [Architecture](../README.md#-architecture) - System design
- [API Docs](../README.md#api-endpoints) - Endpoint reference
- [Safety Guidelines](../README.md#-safety-guidelines) - Important!

---

Need help? Check the issues or reach out!
