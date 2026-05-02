# Setup Review And Roadmap

## Gesamtbewertung

Das Repository hat sich zu einer ernstzunehmenden lokalen und hybriden LLMOps-Plattform entwickelt. Besonders stark sind die Breite der Profile, der Ollama-/OpenClaw-Fokus, die Smart-Home- und Automationsnähe sowie die inzwischen vorhandenen Betriebs- und Sicherheitsbausteine.

Trotzdem gibt es noch typische Wachstumsprobleme:

- zu viele ähnliche Profile mit Überschneidungen
- nicht alle neuen Tools sind im Hauptmenü gleich gut integriert
- nicht jede Installation hat bereits denselben Healthcheck- und Rollback-Reifegrad
- GPU-/VRAM-/CUDA-/ROCm-Prüfungen sind noch nicht überall konsistent
- das Registry-System ist angelegt, aber noch nicht die alleinige Wahrheit

## Einzelbewertung

| Bereich | Bewertung | Kommentar |
|---|---:|---|
| Architekturqualität | 8/10 | Schichtenmodell ist erkennbar und dokumentiert |
| Sicherheit | 7/10 | gute Richtung, aber noch nicht überall gleich tief |
| Updatefähigkeit | 7/10 | Repo-/Workspace-Trennung hilft, Menü/Registry noch nicht voll synchron |
| Modularität | 8/10 | viele Profile und Tools, aber teils redundant |
| Profil-System | 7/10 | stark gewachsen, braucht stärkere Registry-Steuerung |
| Tool-Auswahl | 9/10 | sehr breit und praxisnah |
| LLMOps-Fähigkeit | 8/10 | LiteLLM, Open WebUI, RAG, Monitoring sind vorhanden |
| Kubernetes-/VPS-Tauglichkeit | 7/10 | gut vorbereitet, aber nicht alles produktionsfertig automatisiert |
| WSL-/MiniPC-Tauglichkeit | 7/10 | viel Rücksicht auf WSL2, aber GPU/Build-Pfade bleiben sensibel |
| Dokumentationsstand | 8/10 | deutlich besser, aber weiterhin stark wachsend |
| Risiko durch zu viele Tools | 6/10 | hohe Flexibilität, aber komplex für Einsteiger |
| Testbarkeit | 5/10 | noch zu wenig Ende-zu-Ende-Checks |
| Healthchecks | 6/10 | verbessert, aber nicht durchgehend standardisiert |
| Backup-/Restore-Automation | 6/10 | vorhanden, aber noch nicht überall tief integriert |
| Kosten-/Ressourcenabschätzung | 6/10 | Schätzwerte vorhanden, echte GPU-/VRAM-Basis noch lückenhaft |
| GPU-/CUDA-/ROCm-Erkennung | 5/10 | Grundchecks da, Medienpfade brauchen mehr Tiefe |
| Secrets-Prüfung | 7/10 | Gitleaks und Audits vorhanden, aber noch nicht überall im Workflow verpflichtend |

## Must-have

- `setup_ultimate.sh` schrittweise vollständig auf Registry-Basis umstellen
- Healthchecks pro Toolfamilie stärker vereinheitlichen
- Secret-, Port- und Docker-Socket-Audits fest in den Betriebsweg integrieren
- klare Trennung von Kern- vs. Heavy-/Optional-Tools in Menü und Doku
- GPU-/VRAM-Warnungen für Bild-/Video-/Voice-Profile verschärfen

## Should-have

- mehr Source-Builds direkt aus GitHub statt Paket-/Image-Abkürzungen
- Rollback-/Restore-Pfade pro Profil dokumentierter und konsistenter machen
- Pre-Commit-, Lint- und Secret-Checks für Mitwirkende standardisieren
- Ressourcen- und Kostenübersicht je Profil feiner schätzen

## Nice-to-have

- automatische Menü-Generierung aus `config/tools.yml` und `config/profiles.yml`
- optionale K3s-/Argo-/Flux-Stacks mit separaten Produktionshinweisen
- Tool-Metadaten mit Ports, RAM und GPU-Anforderungen stärker maschinenlesbar pflegen

## Später

- echte GPU-Profilierung pro Host
- WSL2-/Linux-/VPS-spezifische Build-Optimierung je Tool
- Testmatrix für MiniPC, VPS, K3s und GPU-Workstation
