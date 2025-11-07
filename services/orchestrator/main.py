from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Any
from datetime import datetime
import uuid
import httpx
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Agent Smith Orchestrator")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuration
TERMINAL_URL = os.getenv("TERMINAL_URL", "http://localhost:8002")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY", "")
MODE = os.getenv("MODE", "approval")  # simulation | approval | autonomous

# In-memory storage (replace with database later)
runs_db = {}
steps_db = {}
settings_db = {"mode": MODE, "rate_limit": 2, "step_timeout": 60}


# Models
class Goal(BaseModel):
    text: str


class Run(BaseModel):
    id: str
    goal: str
    status: str
    created_at: str
    updated_at: str
    current_step: Optional[int] = None
    total_steps: Optional[int] = None


class Step(BaseModel):
    id: str
    run_id: str
    step_number: int
    action_type: str
    action_data: Any
    screenshot_before: Optional[str] = None
    screenshot_after: Optional[str] = None
    status: str
    created_at: str
    reasoning: Optional[str] = None


class ApprovalRequest(BaseModel):
    step_id: str


class Settings(BaseModel):
    mode: str
    rate_limit: int
    step_timeout: int


# Routes
@app.get("/")
def root():
    return {"service": "agent-smith-orchestrator", "version": "0.1.0"}


@app.get("/runs")
def get_runs():
    """Get all runs"""
    runs = list(runs_db.values())
    return {"runs": runs}


@app.get("/runs/{run_id}")
def get_run(run_id: str):
    """Get a specific run with its steps"""
    if run_id not in runs_db:
        raise HTTPException(status_code=404, detail="Run not found")
    
    run = runs_db[run_id]
    steps = [s for s in steps_db.values() if s["run_id"] == run_id]
    steps.sort(key=lambda x: x["step_number"])
    
    return {**run, "steps": steps}


@app.post("/run")
async def create_run(goal: Goal):
    """Start a new agent run"""
    run_id = str(uuid.uuid4())
    now = datetime.utcnow().isoformat()
    
    run = {
        "id": run_id,
        "goal": goal.text,
        "status": "running",
        "created_at": now,
        "updated_at": now,
        "current_step": 0,
        "total_steps": None,
    }
    runs_db[run_id] = run
    
    # Start control loop in background (simplified)
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            # 1) Observe
            screenshot_resp = await client.post(f"{TERMINAL_URL}/screenshot")
            screenshot_data = screenshot_resp.json()
            screenshot_b64 = screenshot_data["image_base64"]
            
            # 2) Plan (stub - replace with VLM call)
            plan = {
                "actions": [
                    {"type": "move", "x": 350, "y": 120},
                    {"type": "click"},
                    {"type": "type", "text": "demo@example.com"},
                ],
                "expected_state": "email field filled",
                "reasoning": "Moving to email field and filling it"
            }
            
            # Create steps
            for idx, action in enumerate(plan["actions"]):
                step_id = str(uuid.uuid4())
                step = {
                    "id": step_id,
                    "run_id": run_id,
                    "step_number": idx + 1,
                    "action_type": action["type"],
                    "action_data": action,
                    "screenshot_before": screenshot_b64 if idx == 0 else None,
                    "screenshot_after": None,
                    "status": "pending" if settings_db["mode"] == "approval" else "completed",
                    "created_at": datetime.utcnow().isoformat(),
                    "reasoning": plan.get("reasoning"),
                }
                steps_db[step_id] = step
                
                # Execute if in autonomous mode
                if settings_db["mode"] == "autonomous":
                    await client.post(f"{TERMINAL_URL}/action", json=action)
                    
                    # Get after screenshot
                    after_resp = await client.post(f"{TERMINAL_URL}/screenshot")
                    step["screenshot_after"] = after_resp.json()["image_base64"]
                    step["status"] = "completed"
            
            run["total_steps"] = len(plan["actions"])
            run["status"] = "pending" if settings_db["mode"] == "approval" else "completed"
            runs_db[run_id] = run
            
    except Exception as e:
        run["status"] = "failed"
        runs_db[run_id] = run
        raise HTTPException(status_code=500, detail=str(e))
    
    return run


@app.post("/runs/{run_id}/approve")
async def approve_step(run_id: str, req: ApprovalRequest):
    """Approve and execute a pending step"""
    if run_id not in runs_db:
        raise HTTPException(status_code=404, detail="Run not found")
    
    if req.step_id not in steps_db:
        raise HTTPException(status_code=404, detail="Step not found")
    
    step = steps_db[req.step_id]
    
    if step["status"] != "pending":
        raise HTTPException(status_code=400, detail="Step is not pending")
    
    # Execute the action
    async with httpx.AsyncClient(timeout=30.0) as client:
        try:
            # Get before screenshot if not already captured
            if not step["screenshot_before"]:
                before_resp = await client.post(f"{TERMINAL_URL}/screenshot")
                step["screenshot_before"] = before_resp.json()["image_base64"]
            
            # Execute action
            await client.post(f"{TERMINAL_URL}/action", json=step["action_data"])
            
            # Get after screenshot
            after_resp = await client.post(f"{TERMINAL_URL}/screenshot")
            step["screenshot_after"] = after_resp.json()["image_base64"]
            
            step["status"] = "completed"
            steps_db[req.step_id] = step
            
            # Update run progress
            run = runs_db[run_id]
            run["current_step"] = step["step_number"]
            
            # Check if all steps complete
            all_steps = [s for s in steps_db.values() if s["run_id"] == run_id]
            if all(s["status"] in ["completed", "rejected"] for s in all_steps):
                run["status"] = "completed"
            
            runs_db[run_id] = run
            
        except Exception as e:
            step["status"] = "failed"
            steps_db[req.step_id] = step
            raise HTTPException(status_code=500, detail=str(e))
    
    return {"success": True, "step": step}


@app.post("/runs/{run_id}/reject")
async def reject_step(run_id: str, req: ApprovalRequest):
    """Reject a pending step"""
    if run_id not in runs_db:
        raise HTTPException(status_code=404, detail="Run not found")
    
    if req.step_id not in steps_db:
        raise HTTPException(status_code=404, detail="Step not found")
    
    step = steps_db[req.step_id]
    step["status"] = "rejected"
    steps_db[req.step_id] = step
    
    # Update run status
    run = runs_db[run_id]
    run["status"] = "paused"
    runs_db[run_id] = run
    
    return {"success": True, "step": step}


@app.get("/settings")
def get_settings():
    """Get current settings"""
    return settings_db


@app.post("/settings")
def update_settings(settings: Settings):
    """Update settings"""
    settings_db.update(settings.dict())
    return settings_db


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8010)
