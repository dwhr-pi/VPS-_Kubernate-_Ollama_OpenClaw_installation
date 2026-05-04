# Roadmap

Diese Roadmap priorisiert Konsistenz, Sicherheit und belastbare Installationspfade vor weiterer Funktionsbreite.

## P0: Security und Konsistenz

- `config/tools.yml`, `config/profiles.yml` und `config/ports.yml` als verbindliche zentrale Wahrheit halten
- Compose- und Stack-Dateien auf `.env` statt `.env.example` umstellen
- Standardports nur lokal binden, externe Freigabe nur ueber Tunnel oder Reverse Proxy
- Secret-Scanning als Pflichtpfad fuer lokale Commits und CI sichtbar machen
- Profil- und Tool-Doku strikt mit den echten Skripten synchronisieren

## P1: Coding-, Sandbox- und Browser-Pfade

- `Programmierer`, `AI_Project_Manager`, `Browser_Automation_Agent` und `Repo_Maintainer` funktional durchtesten
- `Clawhub`, `Clawhub CLI`, `OpenManus`, `OpenHands`, `Aider` und `Playwright` auf WSL2 und VPS sauber abklopfen
- gemeinsame Status-/Repair-/Dry-Run-Schnittstelle fuer Tool-Skripte definieren
- Ressourcenchecks fuer grosse Node-/Python-Builds vereinheitlichen

## P2: Evaluation, RAG, Dokumente

- `Prompt_Engineering_Studio`, `AI_Agent_Evaluation`, `RAG_Wissensdatenbank`, `Document_Intelligence` zusammenziehen
- eval- und dokumentbezogene Toolketten um fehlende Installer wie `DVC`, `Label Studio`, `Haystack`, `Typesense` erweitern
- ingestierbare Dokumente, OCR-Pfade und RAG-Speicher mit klaren Datenschutzgrenzen versehen

## P3: Apps, Automation und Office

- `NoCode_LowCode_AI`, `Local_AI_App_Builder` und `Email_Office_Automation` mit stabilen Port- und Auth-Standards versehen
- lokale App-Builder und Automations-Stacks gegen Wildwuchs bei Ports, Volumes und Secret-Dateien haerten
- spaeter optionale Profile fuer Meeting-, Mail- und Kalender-Workflows nachziehen

## P4: Media, Voice, IoT und Web3 Safe

- GPU-/VRAM-Hinweise weiter schaerfen
- Voice-/Clone-/Video-Profile mit deutlicheren Ethik- und Rechtehinweisen versehen
- `Robotics_IoT_Edge_AI` und `Smart_Home_Automation` mit Backup- und Netzwerksegmentierungs-Checks erweitern
- Web3/Trading weiterhin strikt auf Analyse, Paper-Trading und manuelle Bestaetigung begrenzen

## P5: Governance und Plattformbetrieb

- Profilempfehlungen fuer `MiniPC`, `WSL2`, `VPS`, `GPU-Workstation` und `Kubernetes` konsolidieren
- Backup-Punkte vor groesseren Setup-Aenderungen automatisieren
- Healthcheck-, Status- und Repair-Funktionen systematisch in die Menues heben
- optionale GitOps-Pfade fuer K3s nur dann weiter ausbauen, wenn die lokale Basis stabil ist
