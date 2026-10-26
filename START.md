# START — Media / omlx + open-webui

Schnellstart-Referenz. Alle Wege laufen mit `~/start-*.sh` im Terminal.

## Starten
| Script | Startet | Port |
|--------|---------|------|
| `~/start-all.sh` | omlx + open-webui gleichzeitig | 8000 + 8080 |
| `~/start-omlx.sh` | nur omlx-Server | 8000 |
| `~/start-openwebui.sh` | nur open-webui | 8080 |

```
~/start-all.sh          # beides (Ctrl-C beendet beide)
~/start-omlx.sh
~/start-openwebui.sh
```

o mlx API-Key: **1234** (aus `~/.omlx/settings.json`). open-webui sendet ihn als `OPENAI_API_KEY`.

## URLs (nach dem Start)
- **omlx-Admin:**  http://localhost:8000/admin/dashboard?tab=settings&settingsTab=global
- **omlx-API:**    http://localhost:8000/v1
- **open-webui:**  http://localhost:8080
- **open-webui (aktuelle Unterhaltungen):** http://localhost:8080/c/

## Ports / Prozesse beenden
```
kill $(lsof -tiTCP:8000 -sTCP:LISTEN) $(lsof -tiTCP:8080 -sTCP:LISTEN)
```

## Hinweise
- Modelle für omlx liegen in `~/.omlx/models/` (jedes Unterverzeichnis = 1 Modell).
- omlx erwartet **kein** Modell als CLI-Argument (wird abgelehnt → Server beendet).
- Startskripte liegen in `~/` (nicht in diesem Projekt-Ordner).
