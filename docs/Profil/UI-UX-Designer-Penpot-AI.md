# Profil: UI-UX-Designer-Penpot-AI

## Zweck des Profils

Dieses Profil beschreibt einen optionalen Design- und Prototyping-Pfad fuer dieses Repository. Penpot dient hier nicht als Ersatz fuer `Ollama`, `OpenClaw` oder `Codex`, sondern als visuelle Oberflaeche fuer:

- UI/UX-Design
- klickbare Prototypen
- Design-Systeme
- Design Tokens
- SVG-, CSS- und HTML-nahe Handoffs
- AI-gestuetzte Design-to-Code-Workflows

Penpot ist besonders passend fuer dieses Setup, weil es self-hostbar, Open Source und stark auf Zusammenarbeit zwischen Design und Entwicklung ausgerichtet ist.

## Geeignete Einsatzgebiete

- Dashboards fuer `Ollama`, `OpenClaw` oder Multi-Agent-Plattformen
- Admin-Panels fuer Modellrouting, Chat, Agentenstatus und Monitoring
- Design-Systeme fuer interne KI-Webapps
- SVG-, Icon- und Komponentenbibliotheken
- fruehe Wireframes und Mid-Fidelity-Prototypen
- Vorbereitung von React-, Tailwind- oder Open-WebUI-nahen Frontends

## Benoetigte Tools

Pflicht:

- `Docker`
- `Docker Compose v2`
- freier lokaler Webport fuer Penpot
- ausreichend RAM und SSD

Sinnvolle Ergaenzungen in diesem Repository:

- `Ollama` fuer lokale Sprachmodelle
- `OpenClaw` fuer Agentensteuerung
- `Open_WebUI` fuer Modell-UI und Prompt-Tests
- `Tailscale` fuer privaten Remote-Zugriff
- `cloudflared` oder Reverse Proxy fuer spaetere bewusst abgesicherte Freigaben

## Docker- und Self-Hosting-Option

In diesem Repository wird Penpot bevorzugt per Docker Compose vorbereitet.

Der Setup-Pfad installiert dabei standardmaessig:

- Penpot Frontend
- Penpot Backend
- Penpot Exporter
- PostgreSQL
- Valkey
- eine lokale Mailcatch-Testoberflaeche

Wichtig:

- Penpot wird im Setup standardmaessig nur an `127.0.0.1` gebunden
- fuer dieses Repository wird standardmaessig `9011` statt `9001` genutzt, um Kollisionen mit MinIO zu vermeiden
- `PENPOT_PUBLIC_URI` muss angepasst werden, wenn du Penpot ueber Reverse Proxy, Cloudflare Tunnel oder Tailscale veroeffentlichen willst

## MCP-Anbindung an OpenClaw, Codex und Ollama

Penpot besitzt einen offiziellen MCP-Server. Damit koennen AI-Agenten Penpot-Dateien kontextbezogen lesen, analysieren und veraendern.

In diesem Setup ist die Idee:

- Penpot bleibt die visuelle Oberflaeche
- `Ollama` liefert lokale LLMs
- `OpenClaw` oder `Codex` koennen per MCP mit dem Design arbeiten
- daraus entstehen Design-to-Code-, Code-to-Design- und UI-Analyse-Workflows

Wichtig:

- Penpot ersetzt das LLM nicht
- das LLM ersetzt Penpot nicht
- zusammen ergaenzen sie sich: visuelles Design plus KI-gestuetzte Analyse, Generierung und Transformation

Fuer Details siehe:

- `docs/Profil/Penpot-MCP-Integration.md`

## Sicherheits- und Ressourcenhinweise

Sicherheit:

- Penpot standardmaessig nur lokal oder im privaten Netz betreiben
- MCP, Plugin-Server und Web-UI nicht offen ins Internet stellen
- bei externer Nutzung zuerst Reverse Proxy, Auth, Tailscale oder bewusst konfigurierte Tunnel einsetzen
- `PENPOT_SECRET_KEY` nie hart codieren oder in Git speichern

Ressourcen:

- kleine bis mittlere Self-Hosted-Instanzen sollten mindestens mehrere GB RAM und freien SSD-Speicher einplanen
- Exporte, Assets und Vorschaudaten wachsen mit der Zeit
- mehrere parallele Nutzer, grosse Bilddaten oder groessere Design-Systeme erhoehen den Ressourcenbedarf deutlich

## Beispielprompts fuer die Nutzung

```txt
Erstelle mir in Penpot einen modernen Dashboard-Prototypen fuer Ollama/OpenClaw mit Navigation, Modell-Auswahl, Chatfenster, Agentenstatus und Systemmonitor.
```

```txt
Analysiere dieses Penpot-Design und generiere daraus React/Tailwind-Komponenten.
```

```txt
Erstelle ein Design-System fuer mein AI-Control-Panel mit Farben, Buttons, Cards, Formularen und Icons.
```

```txt
Exportiere aus dem Design sinnvolle CSS-Variablen und Design Tokens.
```

## Grenzen des Profils

- Penpot ist kein Ersatz fuer ein LLM oder einen Agenten-Orchestrator
- MCP-gestuetzte Designaenderungen brauchen zusaetzliche Betriebs- und Sicherheitsdisziplin
- komplexe Produktionsfreigaben, Multi-User-MCP und Internet-Exposition sollten erst spaeter bewusst aufgebaut werden
- Penpot erstellt keine fertige Anwendung von allein; Design, Review und Entwicklerabnahme bleiben wichtig

## Praktische Empfehlung

Fuer dieses Repository ist Penpot besonders sinnvoll als:

- visuelle Schicht fuer KI-Dashboards
- Design-System-Werkzeug fuer OpenClaw/Ollama-UIs
- Frontend-Prototyping-Plattform fuer spaetere React-/Tailwind-Umsetzung
- Basis fuer Design-to-Code-Workflows mit MCP, aber zunaechst nur lokal oder privat freigegeben

## Offizielle Quellen

- [Penpot Repository](https://github.com/penpot/penpot)
- [Penpot Configuration Guide](https://help.penpot.app/technical-guide/configuration/)
- [Penpot MCP Repository-Hinweis](https://github.com/penpot/penpot-mcp)
