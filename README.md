# 🤖 Agent Smith - AI Terminal Control System

An AI agent system that can control a terminal/desktop environment via screenshots and actions (mouse, keyboard). Built with Next.js admin UI, FastAPI orchestrator with control loop, and Python terminal worker running in VM/sandbox.

## 🏗️ Architecture

```
agent-smith/
├── apps/web/                 # Next.js 14 Admin Dashboard
│   ├── src/app/
│   │   ├── page.tsx         # Runs list
│   │   ├── runs/[id]/       # Run details with screenshots
│   │   └── settings/        # Safety & execution settings
│   └── package.json
├── services/orchestrator/    # FastAPI Control Loop
│   ├── main.py              # Observe → Plan → Act → Verify
│   └── requirements.txt
├── workers/terminal/         # FastAPI Terminal Worker (VM)
│   ├── main.py              # Screenshot + Mouse/Keyboard
│   └── requirements.txt
└── packages/shared/          # Shared schemas (future)
```

## ⚡ Quick Start

> 📖 **New here?** Check out the [Quick Setup Guide](docs/QUICKSTART.md) for step-by-step instructions!

### Prerequisites

- **Node.js** 18+ and **pnpm** 8+
- **Python** 3.11+
- **Docker** (for PostgreSQL/Redis)
- **VM/Sandbox** for running terminal worker safely

### Setup Check

```powershell
# Run environment checker (Windows)
.\check-setup.ps1
```

### 1. Clone & Install

```bash
cd agent-smith
pnpm install
```

### 2. Setup Environment

```bash
cp .env.example .env
# Edit .env with your API keys and settings
```

### 3. Start Database

```bash
docker compose up -d
```

### 4. Install Python Dependencies

**Orchestrator:**
```bash
cd services/orchestrator
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

**Terminal Worker (in VM/sandbox):**
```bash
cd workers/terminal
python -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### 5. Start Services

**Option A - Start All at Once:**
```bash
pnpm dev:all
```

**Option B - Start Individually:**

Terminal 1 - Web Admin:
```bash
pnpm dev:web
```

Terminal 2 - Orchestrator:
```bash
pnpm dev:orchestrator
```

Terminal 3 - Worker (in VM):
```bash
pnpm dev:worker
```

### 6. Access the Admin UI

Open http://localhost:3000

## 🚀 Usage

### Creating a Run

1. Click **"New Run"** in the admin UI
2. Enter your goal (e.g., "Fill out the login form")
3. The orchestrator will:
   - Take a screenshot
   - Plan actions using VLM
   - Execute or queue for approval

### Execution Modes

Configure in `/settings`:

- **🔬 Simulation** - Plans actions but doesn't execute (safest)
- **✋ Approval** - Requires manual approval for each action
- **🤖 Autonomous** - Executes automatically (USE IN VM ONLY!)

### Approving Actions

In Approval mode:
1. Go to `/runs/{id}`
2. Review screenshot and action
3. Click **✓ Approve** or **✗ Reject**

## 🛡️ Safety Guidelines

⚠️ **CRITICAL SAFETY RULES:**

1. **ALWAYS run terminal worker in VM/sandbox**
2. **NEVER run worker on host machine in autonomous mode**
3. Start with **Simulation**, then **Approval**, then **Autonomous**
4. Rate limit: 1-3 actions/second
5. Step timeout: 60 seconds max
6. Log every action and screenshot

## 🏗️ Development

### Project Structure

**Web App (`apps/web/`):**
- Next.js 14 with App Router
- TypeScript + Tailwind CSS
- SWR for data fetching

**Orchestrator (`services/orchestrator/`):**
- FastAPI + SQLModel
- Control loop: Observe → Plan → Act → Verify
- VLM integration (OpenAI/Anthropic)

**Terminal Worker (`workers/terminal/`):**
- FastAPI REST API
- `mss` - Screenshot capture
- `pyautogui` - Mouse/keyboard control
- Rate limiting & safety checks

### Commands

```bash
# Development
pnpm dev:web              # Start Next.js (port 3000)
pnpm dev:orchestrator     # Start orchestrator (port 8010)
pnpm dev:worker           # Start worker (port 8002)
pnpm dev:all              # Start all services

# Build
pnpm build:web            # Build Next.js for production

# Formatting & Linting
pnpm format               # Format TypeScript/JavaScript
pnpm format:python        # Format Python with Black
pnpm lint                 # Lint Next.js
pnpm lint:python          # Lint Python with Ruff

# Database
pnpm docker:up            # Start PostgreSQL & Redis
pnpm docker:down          # Stop services
```

### API Endpoints

**Orchestrator (`http://localhost:8010`):**
- `GET /runs` - List all runs
- `GET /runs/{id}` - Get run details with steps
- `POST /run` - Create new run
- `POST /runs/{id}/approve` - Approve step
- `POST /runs/{id}/reject` - Reject step
- `GET /settings` - Get settings
- `POST /settings` - Update settings

**Terminal Worker (`http://localhost:8002`):**
- `POST /screenshot` - Capture screenshot
- `POST /action` - Execute action (move, click, type, hotkey, scroll)
- `POST /open_url` - Open URL in browser
- `GET /screen_size` - Get screen dimensions
- `GET /mouse_position` - Get current mouse position
- `POST /reset_session` - Reset to safe state

## 🔧 Configuration

### Environment Variables

```bash
# Worker
TERMINAL_URL=http://localhost:8002

# Mode
MODE=approval  # simulation | approval | autonomous

# Database
DATABASE_URL=postgresql://agent:password@localhost:5432/agentsmith
REDIS_URL=redis://localhost:6379

# VLM (choose one)
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...

# Safety
RATE_LIMIT_ACTIONS_PER_SECOND=2
STEP_TIMEOUT_SECONDS=60
```

### Execution Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| `simulation` | Plans but doesn't execute | Development, testing plans |
| `approval` | Requires manual approval | Safe production use |
| `autonomous` | Fully automatic | VM-only automation |

## 🎯 Roadmap

### Phase 1 - Foundation ✅
- [x] Monorepo setup
- [x] Next.js admin UI
- [x] FastAPI orchestrator
- [x] Terminal worker (screenshot + actions)
- [x] Approval workflow

### Phase 2 - Intelligence (Current)
- [ ] VLM integration (GPT-4o/Claude)
- [ ] Structured action planning
- [ ] Screenshot analysis
- [ ] Confidence scoring

### Phase 3 - Persistence
- [ ] PostgreSQL models (Run, Step, Screenshot)
- [ ] SQLModel repositories
- [ ] Screenshot storage (S3/local)
- [ ] Audit logging

### Phase 4 - Advanced Control
- [ ] LangGraph state machine
- [ ] Multi-step workflows
- [ ] Error recovery
- [ ] Verification loop

### Phase 5 - Scale
- [ ] Worker pool
- [ ] Queue system (Celery/Bull)
- [ ] Distributed runs
- [ ] Monitoring & metrics

## 🤝 Contributing

This is a prototype/research project. Contributions welcome!

1. Fork the repo
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open Pull Request

## 📝 License

MIT License - see LICENSE file

## ⚠️ Disclaimer

This software controls mouse and keyboard. Use at your own risk. Always run in isolated environments. Not responsible for any damage or data loss.

## 🙏 Acknowledgments

- Inspired by Anthropic's Computer Use demo
- Built with Next.js, FastAPI, and Python automation tools
- Safety practices from AI agent research community

---

**Built with ❤️ for safe AI automation**
