# Roadmap

Diese Roadmap priorisiert das Repo nach Sicherheits- und Produktionsnutzen.

## P0: Security / Konsistenz

- `config/tools.yml`, `config/profiles.yml`, `config/ports.yml` als zentrale Registry pflegen
- `.env`- und Secret-Trennung ausserhalb des Repos erzwingen
- Gitleaks und TruffleHog vor Commit und in lokalen Checks nutzen
- Services standardmaessig auf `127.0.0.1` halten
- Proxy-/Tunnel-/Auth-Schicht sauber von lokalen Diensten trennen

## P1: Codex / Sandbox / Browser-Agent

- `Local_Codex_IDE_Agent` und `Browser_Agent_Web_Automation` stabilisieren
- Devcontainer-, Test- und Patch-Workflows weiter vereinheitlichen
- Browser-Agenten nur mit Safe-Mode und nachvollziehbaren Guardrails freigeben

## P2: Evaluation / RAG / Dokumente

- `Model_Evaluation_Benchmark`, `Knowledge_Graph_RAG`, `Dataset_Curation_Labeling` und `Privacy_Anonymization_Redaction` vertiefen
- Datasets, Prompt-Registries und Eval-Artefakte strukturierter versionieren
- Dokumentenprofile weiter auf OCR, Redaction und sichere DMS-Workflows ausrichten

## P3: Media / Studio / IoT / Office

- GPU-/VRAM-Pruefungen fuer Medienprofile schaerfen
- `Robotics_IoT_Edge_AI`, `Email_Calendar_Office_Agent` und `Self_Hosted_Cloud_Sync` weiter operationalisieren
- optionale Heavy-Tools wie Longhorn, Authentik, Traefik, Superset oder WhisperX erst nach separater Validierung aufnehmen

## Offene Strukturthemen

- Historische Altstruktur in `docs/Profil/` mittelfristig klar als Legacy markieren
- `setup_ultimate.sh` langfristig staerker aus den Registries ableiten
- Tool-Installationen mit mehr automatischen Ressourcenchecks versehen
