"""
Agent Smith Terminal Worker

SAFETY WARNING:
This service controls mouse, keyboard, and can execute arbitrary actions.
ALWAYS run this inside a VM or sandbox, NEVER on your host machine.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import base64
import mss
import mss.tools
import pyautogui
import time
import webbrowser
import subprocess
import os
from dotenv import load_dotenv

load_dotenv()

# Safety: allow disabling actual actions via env var for local testing
ACTIONS_ENABLED = os.getenv("ACTIONS_ENABLED", "true").lower() in ("1", "true", "yes")

app = FastAPI(title="Agent Smith Terminal Worker")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, restrict this
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize screen grabber
grabber = mss.mss()

# Rate limiting state
last_action_time = 0
MIN_ACTION_INTERVAL = 0.33  # 3 actions per second max


# Models
class Action(BaseModel):
    type: str  # move | click | type | hotkey | scroll
    x: Optional[int] = None
    y: Optional[int] = None
    text: Optional[str] = None
    button: Optional[str] = "left"
    keys: Optional[List[str]] = None
    amount: Optional[int] = None  # for scroll


class URLRequest(BaseModel):
    url: str


class WindowRequest(BaseModel):
    title: str


# Routes
@app.get("/")
def root():
    return {
        "service": "agent-smith-terminal-worker",
        "version": "0.1.0",
        "warning": "⚠️ This service controls your terminal. Run in VM only!",
    }


@app.get("/health")
def health():
    """Health check"""
    return {"status": "ok", "screen_count": len(grabber.monitors) - 1}


@app.post("/screenshot")
def screenshot():
    """Capture screenshot of primary monitor"""
    try:
        # Grab primary monitor (monitor 1)
        monitor = grabber.monitors[1]
        shot = grabber.grab(monitor)
        
        # Convert to PNG bytes
        png_bytes = mss.tools.to_png(shot.rgb, shot.size)
        
        # Encode to base64
        b64 = base64.b64encode(png_bytes).decode()
        
        return {
            "image_base64": b64,
            "width": shot.width,
            "height": shot.height,
            "monitor": 1,
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Screenshot failed: {str(e)}")


@app.post("/action")
def execute_action(action: Action):
    """Execute a mouse/keyboard action"""
    global last_action_time
    
    # Rate limiting
    current_time = time.time()
    time_since_last = current_time - last_action_time
    if time_since_last < MIN_ACTION_INTERVAL:
        time.sleep(MIN_ACTION_INTERVAL - time_since_last)
    
    try:
        # If actions are disabled, simulate success without performing any pyautogui calls
        if not ACTIONS_ENABLED:
            # Log minimal info and return a simulated response
            return {"success": True, "action": action.type, "simulated": True}

        if action.type == "move":
            if action.x is None or action.y is None:
                raise HTTPException(status_code=400, detail="x and y required for move")
            pyautogui.moveTo(action.x, action.y, duration=0.15)

        elif action.type == "click":
            pyautogui.click(button=action.button)

        elif action.type == "type":
            if action.text is None:
                raise HTTPException(status_code=400, detail="text required for type")
            # Use typewrite for better reliability
            pyautogui.typewrite(action.text, interval=0.02)

        elif action.type == "hotkey":
            if not action.keys:
                raise HTTPException(status_code=400, detail="keys required for hotkey")
            pyautogui.hotkey(*action.keys)

        elif action.type == "scroll":
            if action.amount is None:
                raise HTTPException(status_code=400, detail="amount required for scroll")
            pyautogui.scroll(action.amount)

        else:
            raise HTTPException(status_code=400, detail=f"Unknown action type: {action.type}")

        # Small delay to let UI update
        time.sleep(0.2)
        last_action_time = time.time()

        return {"success": True, "action": action.type, "simulated": False}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Action failed: {str(e)}")


@app.post("/open_url")
def open_url(req: URLRequest):
    """Open URL in default browser"""
    try:
        webbrowser.open(req.url)
        time.sleep(1)  # Give browser time to open
        return {"success": True, "url": req.url}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to open URL: {str(e)}")


@app.post("/focus_window")
def focus_window(req: WindowRequest):
    """Focus a window by title (platform-specific)"""
    # This is a simplified version - real implementation would use platform-specific APIs
    try:
        # On Windows, you might use pygetwindow
        # On Linux, wmctrl
        # On macOS, AppleScript
        return {"success": True, "title": req.title, "note": "Not fully implemented"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to focus window: {str(e)}")


@app.post("/reset_session")
def reset_session():
    """Reset session state (move mouse to safe position, etc.)"""
    try:
        # Move mouse to center of screen
        screen_width, screen_height = pyautogui.size()
        pyautogui.moveTo(screen_width // 2, screen_height // 2, duration=0.5)
        return {"success": True, "message": "Session reset"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Reset failed: {str(e)}")


@app.get("/screen_size")
def get_screen_size():
    """Get screen dimensions"""
    width, height = pyautogui.size()
    return {"width": width, "height": height}


@app.get("/mouse_position")
def get_mouse_position():
    """Get current mouse position"""
    x, y = pyautogui.position()
    return {"x": x, "y": y}


if __name__ == "__main__":
    import uvicorn
    
    print("\n" + "="*60)
    print("⚠️  WARNING: TERMINAL WORKER STARTING ⚠️")
    print("="*60)
    print("This service will control mouse and keyboard.")
    print("ONLY run this inside a VM or sandbox!")
    print("="*60 + "\n")
    
    uvicorn.run(app, host="0.0.0.0", port=8002)
