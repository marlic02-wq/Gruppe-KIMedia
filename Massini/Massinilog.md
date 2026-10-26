# Massinilog — Ki in der Medienproduktion

> Zentrale Log-Datei: Hier werden alle Mess-/Generierungs-Experimente dokumentiert.
> **Regel: Jede Eintrags-Einheit fixiert Datum, Aufgabe, Zweck (Warum), Modell,
> vollständige Parameter (u. a. Seed, Temperature, num_ctx, reasoning) und Ergebnis.**

---

## Legende / Schema

| Feld | Bedeutung |
|------|-----------|
| **Datum / LE** | Datum + Lerneinheit |
| **Aufgabe** | Was wurde gemacht |
| **Warum (Zweck)** | Ziel der Messung / der Entscheidung |
| **Modell** | Name + Quantisierung + Runner (z. B. qwen3.8:27b, 4 Bit, nvfp4, MLX-Runner) |
| **Parameter** | temperature, seed, num_ctx, reasoning (`think`), API/Runner, UI |
| **Lauf** | Laufnummer je Messung |
| **Ergebnis** | wortgleich? / Länge (Zeichen) / Beobachtung |
| **Diskussion** | Auswertung, Deutung |

---

## 2026-10-19 LE 01 — Arbeitsplatz einrichten

- **Aufgabe 1.1:** KiShare eingebunden; Ollama installiert (Cloud-Zugriff aus).
- **Warum:** Lokaler, kontrollierter LLM-Betrieb für die Kurs-Experimente.
- **Installiert:** ollama · omlx + Open WebUI · eigener omlx-Startskript · ffmpeg geprüft.
- **Resultat:** Rest von LE 1 nicht geschafft (nur 1.1).

---

## 2026-10-26 LE 02 — Reproduzierbarkeit (Temperature / Seed)

- **Aufgabe 2.2:** Reproduzierbarkeit (25 Min.)
- **Prompt:** „Erstelle eine kurze Inhaltsangabe zu Rotkäppchen in höchstens 100 Wörtern."
- **Modell:** qwen3.8:27b (4 Bit, nvfp4, MLX-Runner)
- **Parameter:** Reasoning aus (`think: false`) · num_ctx 4096 · via Ollama-API (gleiche Parameter wie in Open WebUI)

### Einschätzung vor den Messungen
1. Höhere Temperature → kreativere Antworten (ungewöhnlichere Token). *(Zustimmung)*
2. Höhere Temperature → mehr Halluzinationen (unplausible Fortsetzungen wahrscheinlicher). *(Zustimmung)*
3. Temperature = 0 → laut Best Practices immer gleich; „immer" für zu stark gehalten (Batching/Umgebung). *(Zustimmung mit Vorbehalt)*

### Messergebnisse (30 Läufe)

| Lauf | Temperature | Seed | identisch mit Referenz? | Beobachtung |
|------|-----------|------|-------------------------|-------------|
| 1–5  | 0   | 42 | – / wortgleich | vollständige Fassung, ~625 Zeichen |
| 6–10 | 0   | –  | wortgleich | ohne Seed identisch: T=0 deterministisch, Seed hat nichts zu würfeln |
| 11–15| 0,7 | 42 | wortgleich (L.11) | kürzer/straffer, ~537 Zeichen |
| 16    | 0,7 | –  | –                      | neue Fassung (Brot statt Kuchen), ~514 Zeichen |
| 17–20 | 0,7 | –  | nein (variiert) | abweichende Wortwahl/Länge (510–561 Zeichen) |
| 21–25 | 1,5 | 42 | wortgleich (L.21) | kompakt, ~465 Zeichen, Ende mit Moral |
| 26–30 | 1,5 | –  | nein (variiert) | andere Fassungen (462–595 Zeichen); z. B. „ertrinkt" statt „stirbt" |

### Diskussion
- Seed fixiert nur den Zufallsgenerator. Bei T=0 ist die Dekodierung sowieso determinisch → Seed irrelevant (1–5 = 6–10).
- Bei T=0,7 / 1,5 machen Seed=42 alle Läufe einer Temperaturstufe wortgleich (= Zufall wird „abgespielt").
- Seed ändert nichts am Charakter: Temperature bestimmt Kreativität/Länge, nicht der Seed.
- Vergleich zwischen Rechnern: wortgleiche Übereinstimmung nicht garantiert (Rechenpfad, Batching, Lib-Versionen) — bei T>0 wird die Abdrift verstärkt; bei T=0 praktisch gegeben, „bit-exakt" aber nicht versichert.

### Zusammenfassung (Aufgabe 2.1, vorläufig)
- Höhere Temperature → sichtbar andere/kreativere Antworten.
- Höhere Temperature → mehr Halluzinationen (Fremddetails, z. B. „ertrinkt").
- T=0 → auf diesem Rechner reproduzierbar; „always identisch" wäre zu stark.

### System / Messwerte
- Modell: Qwen3.8-27B, 4 Bit (nvfp4, MLX-Runner); Reasoning aus (`think:false`); num_ctx 4096.
- Speed: ~50,5 Tokens/s · RAM ~20–22 GB unified (von 24 GB).
- Schätzung vorher: ~14 GB (27B × 4 Bit ≈ 13,5 GB). Abweichung: KV-Cache (4096 Kontext), MLX-Runtime-Overhead, Attention-Buffers im Unified Memory (M2).

---

## 2026-10-26 — Prozess-Log (was in dieser Sitzung gemacht wurde)

- **15:45** Navigation in `Gruppe-KIMedia`; `README.md` + `log.md` gelesen; Ordnerstruktur geprüft (audio, prompts, renders, scripts, shotlist, workflows — jeweils leer).
- **15:45** Ordner `Massini/` erstellt; `Massinilog.md` angelegt und mit den Daten aus `log.md` gefüllt.
- **Zweck:** zentrale, erweiterbare Log-Datei für alle weiteren Messungen; Schema fixiert Datum, Aufgabe, Zweck/Warum, Modell, Parameter (Seed/Temperature/num_ctx/reasoning) und Ergebnis.

---

<!-- NEUE EINTRÄGE HIERUNTER ANFÜGEN. Pro Experiment: Schema wie oben (Modell + vollständige Parameter + Seed + Ergebnis + Diskussion). -->
