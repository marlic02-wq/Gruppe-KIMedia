#!/usr/bin/env bash
set -euo pipefail
RED='\033[0;31m'; GRN='\033[0;32m'; NC='\033[0m'
echo "=== Lokale Verbindungen ==="
for srv in "Ollama:11434:/api/tags" "oMLX:8000:/v1/models" "LM Studio:1234:/v1/models"; do
  IFS=: read -r name port path <<< "$srv"
  curl -s "http://localhost:${port}${path}" >/dev/null 2>&1 \
    && echo -e "${GRN}[✓]${NC} $name ($port)" \
    || echo -e "${RED}[✗]${NC} $name ($port) nicht erreichbar"
done
curl -s http://localhost:8080 >/dev/null 2>&1 \
  && echo -e "${GRN}[✓]${NC} Open WebUI (8080)" \
  || echo -e "${RED}[✗]${NC} Open WebUI (8080) nicht erreichbar"
echo "\nKontrolle: Admin → Verbindungen – nur localhost erlaubt!"