# Personalakten Local First

Status: **planned**; lokale Vorschlags-CLI experimental, kein Produktionssystem.

## Zweck und Zielgruppe

Kleine Organisationen/HR-Verantwortliche, die eine lokal kontrollierte Dokumentenablage mit
menschlich geprueften KI-Vorschlaegen erproben wollen. Keine automatisierte Leistungsbewertung oder
Personalentscheidung.

## Tools und Installationspfade

Minimal: vorhandenes Python 3.10+, Offline-Beispieldaten und `personnel_documents`. Optional
vorhandenes Ollama fuer eine lokale Anfrage. Ausbau: Paperless-ngx mit integrierter Tesseract-OCR,
privater DB und Rollen. RAG/Vector-Stores, n8n/OpenClaw und Restic/Borg erst nach
Sicherheitsfreigabe. Der Profilpfad installiert keine dieser Abhaengigkeiten automatisch.

```bash
bash scripts/tools/personnel_documents_install.sh --dry-run
python3 tools/personnel_documents/pipeline.py validate --input examples/personnel_documents/proposal.json
```

## Ressourcen und Plattform

Paperless: 2 GiB RAM/10 GiB Disk als konservative Installer-Reserve; 4 GiB RAM fuer kleines
Testsystem einplanen, LLM/Modelle zusaetzlich. WSL2: mindestens 20 GiB Windows-Host-Reserve, keine
Aenderung an WSL durch Codex. MiniPC: OCR/Inferenz seriell; VPS/K3s nur privat; ARM/GPU/Restore
ungetestet. Neue Paperless-Installation bindet nur `127.0.0.1:8010`, Ollama bleibt lokal.

## Sicherheitsregeln

Erlaubt: synthetische Tests, autorisierte Einzeldatei, begrenzte Metadatenvorschlaege. Verboten als
Default: Cloud-Fallback, Akten-/Rechteaenderungen, Loeschungen, allgemeiner Personalakten-RAG,
Namen/Gehaelter/Diagnosen als Ausgabefelder, automatische Eignungs-/Kuendigungsentscheidungen.
Eingaben koennen trotzdem besonders sensibel sein: Ausgabe-Minimierung ist keine Anonymisierung.

Keine Keys oder Akten im Repo. Echte ENV nur im privaten User-Workspace; keine API-Variable fuer den
CLI-Prototyp erforderlich. Spaetere API-Tokens brauchen ein minimal berechtigtes Servicekonto,
niemals einen Superuser-Token.

## Ergebnis, Tests und Deinstallation

Ausgabe ist JSON auf stdout mit `human_review_required: true`, `applied: false`. Persistente
Ergebnisse nur kontrolliert ausserhalb Git unter dem privaten User-Workspace in
`personnel_documents/` speichern, nicht in Agenten-/CI-Logs. Dieser Pfad ist vom allgemeinen
Setup-Backup ausgeschlossen: separaten verschluesselten Backupjob vor Produktivbetrieb einrichten.
Fehler geben keine Inhalte aus. Originaldatum und OCR gegen das Original pruefen. Bei falschem
Schema wird abgebrochen. Deinstallation des Prototyps loescht keine Akten; Wrapper bleibt bewusst
gesperrt. Der neue Paperless-Deinstaller stoppt Container und behaelt Daten; Legacy-Pfade erfordern
manuelle Migration statt automatischer Loeschung.

Beispielprompt: "Klassifiziere dieses synthetische Dokument und schlage das Dokumentdatum vor.
Fehlende Werte bleiben null; nichts speichern oder veraendern."

[Schritt-fuer-Schritt-Tutorial, Rechtshinweise, Reparatur und offene Aufgaben](../tools/personnel-documents.md).
