#!/bin/bash
# ============================================================
#  KiMediaProduktion – Setup & Prüfung (LE 1)
#  Doppelklick: installiert/prüft alle Werkzeuge der Reihe nach
#  (Ollama, oMLX, Open WebUI, uv, KiShare, Projektordner)
# ============================================================
set -u

GRUEN=$'\033[32m'; GELB=$'\033[33m'; ROT=$'\033[31m'; BLAU=$'\033[36m'; GRAU=$'\033[2m'; RESET=$'\033[0m'
ok()   { echo "${GRUEN}[ OK ]${RESET} $1"; }
warn() { echo "${GELB}[WARN]${RESET} $1"; }
fail() { echo "${ROT}[FEHLER]${RESET} $1"; MISSING+=("$1"); }
info() { echo "${GRAU}       $1${RESET}"; }
step() { echo; echo "${BLAU}━━━ $1 ━━━${RESET}"; }
MISSING=()

OMLX_DIR="$HOME/omlx"
OWUI_DIR="$HOME/openwebui"
GRP_DIR="$HOME/Desktop/KiMediaProduktion/Gruppe-KIMedia"
KISHARE="/Volumes/KiShare"

# ------------------------------------------------------------
step "1/8  Systemvoraussetzungen"
# ------------------------------------------------------------
[ "$(uname -m)" = "arm64" ] && ok "Apple Silicon" || fail "Kein Apple Silicon – Anleitung gilt nur für Apple-Silicon-MacBooks"

if command -v python3.12 >/dev/null 2>&1; then
  ok "Python: $(python3.12 --version)"
else
  fail "Python 3.12 fehlt – beim Lehrteam/Python.org installieren"
fi

if command -v git >/dev/null 2>&1; then
  ok "Git: $(git --version)"
  [ -n "$(git config --global user.name 2>/dev/null)" ] && ok "Git-Identität: $(git config --global user.name) <$(git config --global user.email)>" || warn "Git-Identität fehlt: git config --global user.name / user.email setzen"
else
  fail "Git fehlt"
fi

if xcode-select -p >/dev/null 2>&1; then
  ok "C/C++-Toolchain (Xcode CLT) – für oMLX Custom Kernels"
else
  warn "C/C++-Toolchain fehlt – Terminal ausführen: xcode-select --install"
fi

case ":$PATH:" in
  *":$HOME/.local/bin:"*) : ;;
  *) PATH="$HOME/.local/bin:$PATH" ; export PATH ;;
esac
if command -v uv >/dev/null 2>&1; then
  ok "uv: $(uv --version 2>/dev/null)"
else
  warn "uv fehlt – Installation (ACE-Step 1.5 braucht uv) …"
  if curl -LsSf https://astral.sh/uv/install.sh | sh; then ok "uv installiert"; else fail "uv-Installation fehlgeschlagen (Internet?)"; fi
fi

# ------------------------------------------------------------
step "2/8  Ollama"
# ------------------------------------------------------------
if command -v ollama >/dev/null 2>&1; then
  ok "Ollama: $(ollama --version 2>&1 | head -1)"
  info "Modelle: $(ollama list 2>/dev/null | tail -n +2 | awk '{print $1}' | paste -sd ', ' -)"

  # Cloud-Funktionen abschalten (Pflicht)
  mkdir -p "$HOME/.ollama"
  if [ -f "$HOME/.ollama/server.json" ] && grep -q "disable_ollama_cloud" "$HOME/.ollama/server.json"; then
    ok "Cloud-Funktion deaktiviert (~/.ollama/server.json)"
  else
    printf '{\n  "disable_ollama_cloud": true\n}\n' > "$HOME/.ollama/server.json"
    warn "Cloud-Funktion DEAKTIVIERT – Ollama-App über Menüleiste neu starten!"
  fi

  if curl -s --max-time 3 http://localhost:11434/api/tags >/dev/null 2>&1; then
    ok "Ollama läuft (Port 11434)"
  else
    warn "Ollama läuft nicht (Port 11434) – Ollama-App in der Menüleiste starten"
  fi

  # Pflicht-Modelle prüfen
  MODELLS=$(ollama list 2>/dev/null | tail -n +2)
  for name in "qwen3.8:27b" "gemma4"; do
    if echo "$MODELLS" | awk '{print $1}' | grep -q "^${name}"; then
      ok "Modell vorhanden: ${name}${RESET}"
    else
      fail "Modell fehlt: ${name} – aus KiShare importieren (Modelfile + ollama create) bzw. ollama pull"
    fi
  done
else
  fail "Ollama fehlt – App von ollama.com/download laden, in Programme ziehen, starten"
fi

# ------------------------------------------------------------
step "3/8  oMLX"
# ------------------------------------------------------------
if [ ! -d "$OMLX_DIR/.git" ]; then
  warn "oMLX-Repository fehlt – clone …"
  git clone https://github.com/jundot/omlx.git "$OMLX_DIR" || fail "oMLX-Clone fehlgeschlagen (Internet?)"
else
  ok "oMLX-Repository vorhanden ($OMLX_DIR, Stand: $(git -C "$OMLX_DIR" log -1 --oneline 2>/dev/null))"
  info "Model-Freeze: bei Bedarf Stand des Lehrteams ziehen: git -C $OMLX_DIR checkout <Tag>"
fi

if [ ! -d "$OMLX_DIR/venv" ]; then
  warn "venv fehlt – anlegen …"
  python3.12 -m venv "$OMLX_DIR/venv" || fail "oMLX-venv konnte nicht angelegt werden"
else
  ok "oMLX-venv vorhanden"
fi

# venv aktivieren und prüfen
if [ -d "$OMLX_DIR/venv" ]; then
  # shellcheck disable=SC1091
  source "$OMLX_DIR/venv/bin/activate"
  if pip show omlx >/dev/null 2>&1; then
    ok "oMLX installiert: v$(pip show omlx | awk '/^Version/{print $2}')"
    info "Standardeinstellung: OMLX_WITH_CUSTOM_KERNEL=1 – falls Generation langsam: mit Kernels neu installieren"
  else
    warn "oMLX in venv NICHT installiert – 'OMLX_WITH_CUSTOM_KERNEL=1 pip install -e .' (dauert einige Minuten) …"
    if OMLX_WITH_CUSTOM_KERNEL=1 pip install -e "$OMLX_DIR"; then
      ok "oMLX installiert (mit Custom Kernels)"
    else
      fail "oMLX-Installation fehlgeschlagen – C/C++-Toolchain prüfen (xcode-select --install)"
    fi
  fi
  omlx --version >/dev/null 2>&1 && ok "omlx --version: $(omlx --version 2>&1 | head -1)" || warn "'omlx --version' schlägt fehl"
  deactivate
fi

if curl -s --max-time 3 http://localhost:8000/v1/models >/dev/null 2>&1; then
  ok "oMLX-Server läuft (http://localhost:8000/v1)"
else
  info "oMLX-Server läuft nicht – Starten mit: start-ai.command (Desktop) oder '~/' (cd ~/omlx && source venv/bin/activate && omlx serve)"
fi

# ------------------------------------------------------------
step "4/8  Open WebUI"
# ------------------------------------------------------------
mkdir -p "$OWUI_DIR"
if [ ! -d "$OWUI_DIR/venv" ]; then
  warn "Open-WebUI-venv fehlt – anlegen …"
  python3.12 -m venv "$OWUI_DIR/venv" || fail "Open-WebUI-venv konnte nicht angelegt werden"
else
  ok "Open-WebUI-venv vorhanden"
fi

if [ -d "$OWUI_DIR/venv" ]; then
  # shellcheck disable=SC1091
  source "$OWUI_DIR/venv/bin/activate"
  if pip show open-webui >/dev/null 2>&1; then
    ok "Open WebUI installiert: v$(pip show open-webui | awk '/^Version/{print $2}')"
  else
    warn "Open WebUI NICHT installiert – 'pip install open-webui' (dauert einige Minuten) …"
    if pip install open-webui; then ok "Open WebUI installiert"; else fail "Open-WebUI-Installation fehlgeschlagen"; fi
  fi
  deactivate
fi

if curl -s --max-time 3 http://localhost:8080 >/dev/null 2>&1; then
  ok "Open WebUI läuft (http://localhost:8080)"
else
  info "Open WebUI läuft nicht – Starten mit: start-ai.command (Desktop) oder open-webui serve im venv"
fi

# ------------------------------------------------------------
step "5/8  KiShare"
# ------------------------------------------------------------
if [ -d "$KISHARE/Models" ]; then
  ok "KiShare eingebunden – $(ls "$KISHARE/Models" | wc -l | tr -d ' ') Ordner unter /Volumes/KiShare/Models"
  ls "$KISHARE/Models" | sed 's/^/       /'
else
  warn "KiShare NICHT eingebunden (/Volumes/KiShare fehlt)"
  warn "→ AvidNEXIS (in /Applications) starten, anmelden (User: ki, Passwort: ki_2026), Laufwerk einbinden"
  warn "→ Tipp: AvidNEXIS unter Systemeinstellungen → Allgemein → Anmeldeobjekte eintragen"
fi


# ------------------------------------------------------------
step "7/8  Offline-Einstellungen"
# ------------------------------------------------------------
export HF_HUB_OFFLINE=1
if [ -f "$HOME/.zshrc" ] && grep -q "HF_HUB_OFFLINE" "$HOME/.zshrc"; then
  ok "HF_HUB_OFFLINE=1 bereits in ~/.zshrc"
else
  {
    echo ""
    echo "# Kein HuggingFace-Download (nur lokale Modelle) – Kurs KI Media Produktion"
    echo "export HF_HUB_OFFLINE=1"
  } >> "$HOME/.zshrc"
  ok "HF_HUB_OFFLINE=1 in ~/.zshrc ergänzt (gilt ab nächster Shell / nach 'source ~/.zshrc')"
fi

# ------------------------------------------------------------
step "8/8  Cloud-Inferenz-Prüfung (Pflicht)"
# ------------------------------------------------------------
if [ -f "$HOME/.ollama/server.json" ] && grep -q "disable_ollama_cloud" "$HOME/.ollama/server.json"; then
  ok "Ollama: cloud disabled"
else
  fail "Ollama server.json – 'disable_ollama_cloud: true' fehlt"
fi
info "Manuell prüfen: keine 'ollama -cloud'-Modelle, kein 'ollama signin',"
info "Open WebUI Admin → Verbindungen: nur localhost-Adressen (keine api.openai.com)."

# ------------------------------------------------------------
echo
echo "${BLAU}════════════════════════════════════════════════════${RESET}"
if [ ${#MISSING[@]} -eq 0 ]; then
  echo "${GRUEN}  FERTIG – alle Prüfungen bestanden. Server starten mit: start-ai.command${RESET}"
else
  echo "${GELB}  FERTIG mit ${#MISSING[@]} offenen Punkt(en):${RESET}"
  for m in "${MISSING[@]}"; do echo "${ROT}   - $m${RESET}"; done
fi
echo "${BLAU}════════════════════════════════════════════════════${RESET}"
echo
read -r -p "Fenster schließen? [Enter] " _
