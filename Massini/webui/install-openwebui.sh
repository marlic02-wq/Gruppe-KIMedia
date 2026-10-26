Open WebUI – Installation & Konfiguration (macOS)
Open WebUI ist eine Chat-Oberfläche im Browser. Im Kurs verbindet sie sich ausschließlich mit lokalen Servern: Ollama, oMLX und optional LM Studio. Sie wird in LE 1–3 für Experimente mit Prompts und Sampling-Parametern genutzt.

⚠️ Nur lokale Inferenz. Open WebUI richtet standardmäßig eine Verbindung zu https://api.openai.com/v1 ein – das wäre Cloud-Inferenz. Diese Verbindung wird in Abschnitt 6 entfernt. API-Schlüssel externer Anbieter werden nie eingetragen.

1. Voraussetzungen
Python 3.12
Ollama und/oder oMLX installiert und gestartet (ollama, omlx)
2. Python-Umgebung erstellen
mkdir -p ~/openwebui && cd ~/openwebui
python3.12 -m venv venv
source venv/bin/activate
3. Open WebUI installieren
pip install open-webui
Die Installation dauert einige Minuten. Open WebUI speichert Konten, Chats und Einstellungen in einer lokalen SQLite-Datenbank.

Model-Freeze: Die vom Lehrteam festgelegte Version installieren: pip install open-webui==<Version laut Lehrteam>.

4. Server starten
Start mit lokalen Verbindungen:

OLLAMA_BASE_URL=http://localhost:11434 \
OPENAI_API_BASE_URL=http://localhost:8000/v1 \
OPENAI_API_KEY=lokal \
open-webui serve
OPENAI_API_BASE_URL zeigt auf oMLX statt auf OpenAI. Der Schlüssel lokal ist ein Platzhalter.
Optional: OFFLINE_MODE=true schaltet Versionsprüfungen und automatische Downloads ab.
Hinweis: Verbindungseinstellungen aus Umgebungsvariablen übernimmt Open WebUI beim ersten Start in seine Datenbank. Später geänderte Verbindungen werden im Admin-Bereich gepflegt (Abschnitt 6).

Der Server läuft auf Port 8080. Das Terminal-Fenster geöffnet lassen.

5. Erster Aufruf und Admin-Konto
Im Browser: http://localhost:8080

Beim ersten Aufruf wird ein Admin-Konto angelegt (Name, E-Mail, Passwort). Das Konto existiert nur lokal auf diesem Rechner.

Danach erscheint die Startseite des Chats.

6. Verbindungen prüfen – nur lokal
Unten links auf den Benutzernamen klicken → Admin-Bereich.

Einstellungen → Verbindungen öffnen.

OpenAI-API: Den Eintrag https://api.openai.com/v1 löschen. Mit „+“ die lokalen Server eintragen:

Server	API-URL	Schlüssel
oMLX	http://localhost:8000/v1	lokal
LM Studio (optional)	http://localhost:1234/v1	lokal
Ollama-API: Eintrag http://localhost:11434 aktiv lassen.
Speichern.
Kontrolle: In der Liste dürfen nur Adressen mit localhost stehen.

Weitere Funktionen mit Modellen: Unter Einstellungen → Audio und Bilder keine externen Anbieter (z. B. OpenAI) eintragen – das wäre Cloud-Inferenz. Diese Funktionen bleiben aus oder nutzen lokale Engines.
7. Modell auswählen und chatten
Oben im Chat das Modell wählen, z. B. qwen3.8:27b (Ollama) oder das Qwen3.8-Modell aus oMLX.

8. Sampling-Parameter einstellen (LE 2)
Rechts oben über Steuerung lassen sich für den aktuellen Chat Parameter setzen: Temperature, Top P, Top K, Seed, Kontextlänge und weitere.

Für die Experimente in LE 2:

immer nur einen Parameter ändern,
jede Einstellung in log.md notieren,
für jeden Lauf einen neuen Chat beginnen, damit der Verlauf das Ergebnis nicht beeinflusst.
Unter Einstellungen → Allgemein lässt sich ein System-Prompt festlegen (LE 3: Rollen-Prompts).

9. Server stoppen
Strg + C        # im Terminal-Fenster des Servers
deactivate
Häufige Probleme
Problem	Lösung
python3.12: command not found	Python 3.12 installieren bzw. Lehrteam fragen
(venv) erscheint nicht	im Ordner ~/openwebui source venv/bin/activate erneut ausführen
Port 8080 belegt	open-webui serve --port 8081 und http://localhost:8081 aufrufen
Keine Modelle in der Auswahl	Läuft Ollama bzw. oMLX? Verbindung im Admin-Bereich prüfen
Übersicht der Befehle
cd ~/openwebui
source venv/bin/activate
OLLAMA_BASE_URL=http://localhost:11434 \
OPENAI_API_BASE_URL=http://localhost:8000/v1 OPENAI_API_KEY=lokal \
open-webui serve
# Browser: http://localhost:8080