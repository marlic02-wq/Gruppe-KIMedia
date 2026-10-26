#!/bin/bash

# ── Terminal-Fenster 1: omlx serve ──────────────────────────
osascript <<'APPLESCRIPT'
tell application "Terminal"
    activate
    do script "cd ~/omlx && source venv/bin/activate && omlx serve"
end tell
APPLESCRIPT

# kleine Pause, damit beide Fenster sauber öffnen
sleep 1

# ── Terminal-Fenster 2: open-webui serve ────────────────────
osascript <<'APPLESCRIPT'
tell application "Terminal"
    activate
    do script "cd ~/openwebui && source venv/bin/activate && OLLAMA_BASE_URL=http://localhost:11434 OPENAI_API_BASE_URL=http://localhost:8000/v1 OPENAI_API_KEY=lokal open-webui serve"
end tell
APPLESCRIPT

# Hauptfenster (das leere) schließen
osascript -e 'tell application "Terminal" to close (every window whose name is "start-ai.command")'

