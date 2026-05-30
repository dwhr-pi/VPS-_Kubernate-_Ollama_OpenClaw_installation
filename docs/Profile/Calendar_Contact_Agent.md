# Calendar Contact Agent

## Status

- Installationsstatus: planned
- Ressourcenklasse: medium
- Automatische Installation: nein

## Zweck

Kalender-/Kontakt-Ablage mit CalDAV/CardDAV und lokalen Regeln.

## Empfohlene Tools

- stalwart_mail
- radicale
- n8n

## Minimaler Installationspfad

1. Zuerst `bash scripts/doctor.sh` oder vorhandene Check-Skripte ausfuehren.
2. Nur stabile oder beta-markierte Tools einzeln installieren.
3. Schwere Tools nur nach Ressourcencheck und manueller Bestaetigung starten.

## Full-Installationspfad

Full-Installationen bleiben documentation-first, bis Healthchecks, Uninstaller und Rollback getestet sind. Lange Jobs sollen ueber den Job Queue Manager laufen.

## Sicherheitswarnungen

- Keine Secrets ins Repository schreiben.
- Dienste standardmaessig nur auf `127.0.0.1` binden.
- Externe Freigabe nur ueber WireGuard, Tailscale, optional Cloudflare Access oder gehaerteten Reverse Proxy.
- Agentenaktionen bleiben read-only-first und brauchen Freigabe fuer Schreibaktionen.

## Modelle

- Lokal/Ollama leicht: `llama3.2:1b`
- Lokal/Ollama besser: vorhandenes groesseres Llama/Qwen/Mistral-Modell je nach RAM
- Cloud optional: OpenAI, Gemini oder Claude nur mit Kostenwarnung und extern gespeicherten Keys

## Plattformhinweise

- WSL2: Windows-C:-Speicher und RAM-Limit vorher pruefen.
- MiniPC: Parallelitaet niedrig halten, Queue default `1`.
- VPS: keine sensiblen Heimdienste direkt freigeben.
- K3s: nur geplante Worker- oder Control-Plane-Rollen aktivieren.
- GPU Workstation: GPU-Profile nur bei Bedarf per Wake-on-LAN starten.

## Beispiel-Prompt

```text
Pruefe dieses Profil im Dry-Run, nenne benoetigte Tools, Risiken und sichere naechste Schritte. Fuehre keine Installation ohne Freigabe aus.
```

## Grenzen

Dieses Profil darf keine produktiven Secrets erzeugen, keine Admin-Ports oeffnen und keine schweren Builds automatisch starten.
