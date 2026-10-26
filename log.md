# Log Datei - Ki in der Medienproduktion

## 2026-10-19 LE 01

### Erledigt: Aufgabe 1.1 Arbeitsplatz einrichten
- KiShare eingebunden
- Ollama instlliert
    - Cloud-Zugriff abgeschaltet
    - omlx und Open WebUI installiert
    - eigenes Startskript für den omlx Server generieren lassen 
- ffmpeg installiert + geprüft

### Generierungs-Log
- Open WebUI: Qwen3.8-27B -> leider nicht laufzeit geprüft



### Nicht geschafft
- Rest von LE 1 (nur 1.1 geschafft)


##2026-10-26 LE 02

### Einschätzung: Temperature (vor den Messungen)

1. Wir vermuteten, dass eine höhere Temperature die Antworten kreativer macht
, da das Modell dann eher ungewöhnliche Token auswählt. (Zustimmung)

2. Wir vermuteten auch, dass dadurch mehr Halluzinationen entstehen, 
weil unplausible Fortsetzungen plötzlich wahrscheinlicher werden. (Zustimmung)

3. Temperature = 0 sollte laut Best Practices immer gleich antworten, 
aber das Wort "immer" fanden wir zu stark – je nach Batching und Umgebungs­konstellation 
könnte es Abweichungen geben. (Zustimmung mit Vorbehalt)

### Aufgabe 2.2 – Reproduzierbarkeit (25 Minuten)

Prompt: „Erstelle eine kurze Inhaltsangabe zu Rotkäppchen in höchstens 100 Wörtern."
Modell: qwen3.8:27b (4 Bit, nvfp4, MLX-Runner) · Reasoning aus · num_ctx 4096 · via Ollama-API (gleiche Parameter wie in Open WebUI)

| Lauf | Temperature | Seed | identisch mit Lauf 1? | Beobachtung |
|------|-----------|------|------------------------|-------------|
| 1 | 0 | 42 | – | Vollständige Inhaltsangabe, Titel „Rotkäppchen – Inhaltsangabe", ~625 Zeichen |
| 2 | 0 | 42 | ja, wortgleich | Identisch zu Lauf 1 |
| 3 | 0 | 42 | ja, wortgleich | Identisch zu Lauf 1 |
| 4 | 0 | 42 | ja, wortgleich | Identisch zu Lauf 1 |
| 5 | 0 | 42 | ja, wortgleich | Identisch zu Lauf 1 |
| 6 | 0 | – | ja, wortgleich | Ohne Seed trotzdem identisch: bei Temperature 0 wird deterministisch dekodiert, der Seed hat nichts zu würfeln |
| 7 | 0 | – | ja, wortgleich | Identisch |
| 8 | 0 | – | ja, wortgleich | Identisch |
| 9 | 0 | – | ja, wortgleich | Identisch |
| 10 | 0 | – | ja, wortgleich | Identisch |
| 11 | 0,7 | 42 | – | Kürzere, straffere Fassung, ~537 Zeichen |
| 12 | 0,7 | 42 | ja, wortgleich | Identisch zu Lauf 11 |
| 13 | 0,7 | 42 | ja, wortgleich | Identisch zu Lauf 11 |
| 14 | 0,7 | 42 | ja, wortgleich | Identisch zu Lauf 11 |
| 15 | 0,7 | 42 | ja, wortgleich | Identisch zu Lauf 11 |
| 16 | 0,7 | – | – | Neue Fassung (Brot statt Kuchen), ~514 Zeichen |
| 17 | 0,7 | – | nein | Andere Sätze, andere Länge (561 Zeichen), ähnliche Handlung |
| 18 | 0,7 | – | nein | Abweichende Wortwahl (494 Zeichen) |
| 19 | 0,7 | – | nein | Wieder anders formuliert (555 Zeichen) |
| 20 | 0,7 | – | nein | Abweichende Fassung (510 Zeichen) |
| 21 | 1,5 | 42 | – | Kompakte Fassung (465 Zeichen), Ende mit Moral |
| 22 | 1,5 | 42 | ja, wortgleich | Identisch zu Lauf 21 |
| 23 | 1,5 | 42 | ja, wortgleich | Identisch zu Lauf 21 |
| 24 | 1,5 | 42 | ja, wortgleich | Identisch zu Lauf 21 |
| 25 | 1,5 | 42 | ja, wortgleich | Identisch zu Lauf 21 |
| 26 | 1,5 | – | – | Andere Fassung: „ertrinkt" statt „stirbt", ~505 Zeichen |
| 27 | 1,5 | – | nein | Abweichende Version (462 Zeichen) |
| 28 | 1,5 | – | nein | Abweichende Version (496 Zeichen) |
| 29 | 1,5 | – | nein | Abweichende Version (513 Zeichen) |
| 30 | 1,5 | – | nein | Deutlich länger (595 Zeichen), andere Schlusswendung |

### Diskussion: Was ändert der Seed – und was nicht?

- Der Seed fixiert nur den Zufallsgenerator. Bei Temperature 0 ist die Token-Auswahl sowieso deterministisch → Seed macht dort keinen Unterschied (Läufe 1–5 = Läufe 6–10, obwohl die Runs ohne Seed identisch waren).
- Bei Temperature 0,7 und 1,5 macht der Seed 42 alle Läufe innerhalb einer Temperaturstufe wortgleich reproduzierbar – der Zufall wird quasi „abgespielt" statt neu gewürfelt.
- Der Seed ändert aber nichts am Charakter der Antwort: Temperatur bestimmt Kreativität/Länge, nicht der Seed.
- Vergleich zwischen Gruppen auf verschiedenen Rechnern: Selbst bei identischen Einstellungen (Modell, Quantisierung, Parameter) ist wortgleiche Übereinstimmung nicht garantiert, weil Rechenpfad (GPU/CPU, Batching, Library-Versionen) kleinste numerische Abweichungen erzeugen kann – bei temperature > 0 verstärken diese die Abdrift. Bei Temperature 0 ist Übereinstimmung in der Praxis fast immer gegeben, "bit-exakt" aber nicht versichert.

### Aufgabe 2.1 – Zusammenfassung (vorläufig, aus bisherigen Ergebnissen)

Unsere Einschätzungen vor den Messungen haben sich bestätigt:
- Höhere Temperature → sichtbar andere/creative Antworten (Längen 462–595 Zeichen bei T=1,5, dagegen nur ~625 Zeichen feste Fassung bei T=0).
- Höhere Temperature mehr Halluzinationen: Bei T=1,5 ohne Seed tauchen ungewöhnliche Details auf, die im Märchen nicht vorkommen (z. B. „Steine, die der Wolf verschluckt" bei T=0,7; bei T=1,5 „ertrinkt" statt „stirbt" – eine Abweichung von der Vorlage).
- Temperature = 0 → bei uns alle Läufe wortgleich, unabhängig vom Seed. „Immer" wäre zu stark, aber auf diesem Rechner mit identischer Umgebungs­konstellation (gleicher MLX-Runner, gleiches Modell, gleicher Kontext) war das Ergebnis reproduzierbar.

### Dokumentation / Emphehlung (für die spätere Dokumentation)

- Modell: Qwen3.8-27B, 4 Bit (nvfp4, MLX-Runner), Werkzeug: Ollama-API (Open WebUI als UI-Frontend identisch nutzbar), Reasoning aus (`think: false`), num_ctx 4096
- Messung: Generierung ~50,5 Tokens/s, Speicher 38,5 GB (gemessen: RSS der llama-server-Prozess)
- Schätzung vorher: ~8–10 GB (27B Parameter × 4 Bit ≈ ~7 GB + Tokenizer) -> Abweichung erklärt durch: Runtime-Overhead (Draft-/MTP-Modell, Attention-Buffers, KV-Cache) und MLX-Runtime-Puffer
- Story-Ideen: siehe README.md, Rechte-Status: siehe assets.md