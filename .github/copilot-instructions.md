# Agent Smith - AI Terminal Control System

## Project Overview
Monorepo for an AI agent that can control a terminal/desktop environment via screenshots and actions (mouse, keyboard). Uses Next.js admin UI, FastAPI orchestrator with LangGraph control loop, and Python terminal worker running in VM/sandbox.

## Architecture
- `apps/web/` - Next.js 14 admin dashboard (TypeScript, Tailwind)
- `services/orchestrator/` - FastAPI control loop (Python, SQLModel, PostgreSQL)
- `workers/terminal/` - FastAPI worker for VM control (Python, mss, pyautogui)
- `packages/shared/` - Shared schemas and types

## Development Commands
- `pnpm install` - Install all dependencies
- `pnpm dev:web` - Start Next.js admin (port 3000)
- `pnpm dev:orchestrator` - Start FastAPI orchestrator (port 8010)
- `pnpm dev:worker` - Start terminal worker (port 8002)
- `pnpm dev:all` - Start all services concurrently

## Safety Guidelines
- Always run the terminal worker inside a VM/sandbox, never on host
- Start with Simulation mode, then Approval mode, then Autonomous
- Rate limit: 1-3 actions/second, 60s step timeout
- Log every screenshot, action, and result

## Tech Stack
- Frontend: Next.js 14, TypeScript, Tailwind CSS
- Backend: FastAPI, Python 3.11+, SQLModel, PostgreSQL
- Worker: mss, pyautogui, pynput, Pillow
- Package Manager: pnpm workspaces
