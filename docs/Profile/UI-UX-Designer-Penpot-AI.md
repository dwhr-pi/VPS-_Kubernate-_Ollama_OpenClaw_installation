# Profil: UI-UX-Designer-Penpot-AI

## Überblick

Dieses Profil erweitert das Repository um einen optionalen Pfad für self-hostbares UI/UX-Design, Prototyping, Design-Systeme und AI-gestützte Design-to-Code-Workflows mit Penpot.

Penpot ist in diesem Setup keine Konkurrenz zu `Ollama`, `OpenClaw` oder `Codex`, sondern die visuelle Design- und Prototyping-Oberfläche, die mit lokalen oder hybriden KI-Workflows kombiniert werden kann.

## Geeignete Einsatzgebiete

- Dashboards für `Ollama`-, `OpenClaw`- und Agentenplattformen
- klickbare UI-Prototypen
- Design-Systeme und Tokens
- Design-Handoffs für React-, Tailwind- oder Web-Frontends
- interne Admin-Panels, Chatoberflächen und Modell-Router-UIs

## Benötigte Tools

- `Docker`
- `Docker Compose v2`
- freier Port für die Penpot Web-UI
- ausreichend RAM und SSD-Speicher

Sinnvolle Ergänzungen:

- `Ollama`
- `OpenClaw`
- `Open_WebUI`
- `Tailscale`
- `cloudflared`

## Self-Hosting im Setup

Der optionale Tool-Eintrag `Penpot` installiert bevorzugt einen lokalen Docker-Compose-Stack mit:

- Penpot Frontend
- Penpot Backend
- Penpot Exporter
- PostgreSQL
- Valkey
- lokaler Mailcatch-Testoberfläche

Wichtig:

- Standardbindung nur auf `127.0.0.1`
- Standardport in diesem Repository: `9011`
- `PENPOT_PUBLIC_URI` muss angepasst werden, wenn später ein Reverse Proxy oder Tunnel davor gesetzt wird

## MCP-Anbindung

Penpot besitzt einen offiziellen MCP-Server. Damit können `Codex`, `OpenClaw` oder andere MCP-kompatible Clients Penpot-Dateien kontextbezogen lesen und bearbeiten.

Mehr dazu:

- [Penpot-MCP-Integration.md](/C:/Users/danie/Documents/GitHub/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/Profil/Penpot-MCP-Integration.md)

## Sicherheits- und Ressourcenhinweise

- Penpot standardmäßig nur lokal oder privat betreiben
- MCP-Server und Plugin nicht ungeschützt ins Internet stellen
- für Remote-Zugriff zuerst `Tailscale`, Reverse Proxy oder bewusst konfigurierte Tunnel nutzen
- `PENPOT_SECRET_KEY` niemals im Repository speichern
- für mehrere Projekte und Assets zusätzlichen SSD-Speicher einplanen

## Beispielprompts

```txt
Erstelle mir in Penpot einen modernen Dashboard-Prototypen für Ollama/OpenClaw mit Navigation, Modell-Auswahl, Chatfenster, Agentenstatus und Systemmonitor.
```

```txt
Analysiere dieses Penpot-Design und generiere daraus React/Tailwind-Komponenten.
```

```txt
Erstelle ein Design-System für mein AI-Control-Panel mit Farben, Buttons, Cards, Formularen und Icons.
```

```txt
Exportiere aus dem Design sinnvolle CSS-Variablen und Design Tokens.
```

## Grenzen des Profils

- Penpot ersetzt kein LLM
- Penpot ersetzt keinen Agenten-Orchestrator
- MCP-basierte Designänderungen sollten zunächst nur lokal oder privat getestet werden
- die fertige UI braucht weiterhin Review, Umsetzung und Entwicklerabnahme
