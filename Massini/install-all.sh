#!/usr/bin/env bash
set -euo pipefail

# ── Kombination aus install-openwebui.sh + omlx-Aufbau ──
# Richtet Toolchain, oMLX und Open WebUI ein.

# ── Farben ──────────────────────────────────────────────
RED='\033[0;31m'; GRN='\033[0;32m'; YEL='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GRN}[✓]${NC} $*"; }
warn()  { echo -e "${YEL}[!]${NC} $*"; }
err()   { echo -e "${RED}[✗]${NC} $*" >&2; }

echo "=== Media – omlx + Open WebUI (kombinierte Installation) ==="

# ── 0. Toolchain (einmalig) ─────────────────────────────
if ! xcode-select -p &>/dev/null; then
  warn "Xcode-Command-Line-Tools fehlen – bitte manuell ausführen: xcode-select --install"
  xcode-select --install || true
else
  info "Xcode-Command-Line-Tools vorhanden."
fi

command -v brew &>/dev/null || { err "Homebrew nicht gefunden."; exit 1; }
if ! brew list --versions python@3.12 &>/dev/null; then
  info "python@3.12 wird über Homebrew installiert …"
  brew install python@3.12
else
  info "python@3.12 bereits installiert."
fi
info "Toolchain bereit."

# ── 1. oMLX ─────────────────────────────────────────────
OMLX_DIR="$HOME/omlx"
info "Verzeichnis: $OMLX_DIR"

if [[ ! -d "$OMLX_DIR" ]]; then
  warn "$OMLX_DIR existiert nicht – oMLX muss vorkonfiguriert sein (git-Repo + venv)."
fi

if [[ -d "$OMLX_DIR" && ! -d "$OMLX_DIR/venv" ]]; then
  PYBIN="$(command -v python3.12 || true)"
  [[ -n "$PYBIN" ]] || { err "python3.12 nicht gefunden."; exit 1; }
  "$PYBIN" -m venv "$OMLX_DIR/venv"
  info "omlx-venv erstellt."
fi

start_omlx="$HOME/start-omlx.sh"
if [[ ! -f "$start_omlx" ]]; then
  cat > "$start_omlx" << 'EOF'
#!/bin/bash
cd "$HOME/omlx" || exit 1
source venv/bin/activate
exec omlx serve --host 127.0.0.1 --port 8000 "$@"
EOF
  chmod +x "$start_omlx"
  info "start-omlx.sh erstellt."
else
  info "start-omlx.sh existiert bereits."
fi

if curl -s http://localhost:8000/v1/models >/dev/null 2>&1; then
  info "oMLX erreichbar (Port 8000)."
else
  warn "oMLX läuft nicht (Port 8000). Start: ~/start-omlx.sh"
  warn "→ Modell-Verzeichnis in http://localhost:8000/admin eintragen (z. B. /Volumes/KiShare/Models)"
fi

# ── 2. Voraussetzungen für Open WebUI ───────────────────
PYBIN="$(command -v python3.12 || true)"
if [[ -z "$PYBIN" ]]; then
  err "python3.12 nicht gefunden. Bitte: brew install python@3.12"
  exit 1
fi
info "Python: $PYBIN ($("$PYBIN" --version))"

if command -v ollama &>/dev/null; then
  info "Ollama-Binär gefunden."
  curl -s http://localhost:11434/ >/dev/null 2>&1 && info "Ollama läuft." \
    || warn "Ollama läuft nicht (Port 11434). Start: ollama serve"
else
  warn "Ollama nicht im PATH."
fi

# ── 3. Open WebUI ───────────────────────────────────────
WEBUI_DIR="$HOME/openwebui"
mkdir -p "$WEBUI_DIR"
cd "$WEBUI_DIR"
info "Verzeichnis: $WEBUI_DIR"

if [[ ! -d "venv" ]]; then
  "$PYBIN" -m venv venv
  info "venv erstellt."
else
  info "venv existiert bereits."
fi

source venv/bin/activate
pip install --upgrade pip
pip install open-webui
# Feste Version:  pip install "open-webui==X.Y.Z"
info "open-webui installiert."

cat > start-openwebui.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source venv/bin/activate
export OLLAMA_BASE_URL="http://localhost:11434"
export OPENAI_API_BASE_URL="http://localhost:8000/v1"
export OPENAI_API_KEY="lokal"
# export OFFLINE_MODE="true"
PORT="${1:-8080}"
echo "Starte Open WebUI → http://localhost:${PORT}  (Strg+C = Stop)"
exec open-webui serve --port "$PORT"
EOF
chmod +x start-openwebui.sh
info "start-openwebui.sh erstellt."

# ── 4. Verbindung prüfen ────────────────────────────────
echo "=== Verbindungstest ==="
curl -s http://localhost:8000/v1/models >/dev/null 2>&1 \
  && info "oMLX (8000) erreichbar." || warn "oMLX (8000) nicht erreichbar – ~/start-omlx.sh starten."
curl -s http://localhost:8080 >/dev/null 2>&1 \
  && info "Open WebUI (8080) erreichbar." || warn "Open WebUI (8080) nicht erreichbar – ./start-openwebui.sh starten."

echo -e "\n${GRN}Installation fertig!${NC}"
echo "Start oMLX:       ~/start-omlx.sh        → http://localhost:8000/admin"
echo "Start Open WebUI: cd ~/openwebui && ./start-openwebui.sh → http://localhost:8080"
