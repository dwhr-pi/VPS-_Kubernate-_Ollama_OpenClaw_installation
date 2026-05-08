# Penpot MCP Integration

## Was ist MCP?

MCP steht fuer `Model Context Protocol`.

Es ist ein Protokoll, mit dem AI-Clients und Agenten strukturierte Werkzeuge und Kontexte ansprechen koennen. Statt nur freien Text zu schicken, kann ein Agent damit gezielt auf externe Tools, APIs oder Datenquellen zugreifen.

Fuer dieses Repository ist MCP interessant, weil `OpenClaw`, `Codex` oder andere AI-Clients damit kontrollierter auf lokale Systeme, Datenquellen und spezialisierte Plattformen zugreifen koennen.

## Wie Penpot MCP grundsaetzlich funktioniert

Penpot MCP verbindet ein LLM oder einen Agenten mit einer echten Penpot-Design-Datei.

Laut offizieller Penpot-MCP-Doku besteht der Ablauf grob aus drei Teilen:

- ein MCP-Server stellt HTTP-, Streamable-HTTP- oder SSE-Endpunkte fuer AI-Clients bereit
- ein Penpot-Plugin verbindet sich per WebSocket mit diesem MCP-Server
- der Agent arbeitet dadurch im Kontext einer geoeffneten Penpot-Datei

Praktisch bedeutet das:

- Design lesen
- Design aendern
- Design-Elemente erzeugen
- Design nach Code oder Tokens auswerten

## Warum das fuer OpenClaw, Codex und Ollama sinnvoll ist

Penpot MCP passt gut zu diesem Projekt, weil dadurch Design und lokale KI-Workflows naeherruecken:

- `Codex` kann Design analysieren und daraus Komponentenstruktur ableiten
- `OpenClaw` kann Design-, Routing- und Automationsaufgaben orchestrieren
- `Ollama` kann lokale Modelle fuer UI-Analyse, Komponentenentwurf oder Textgenerierung liefern

Typische Workflows:

- Design zu React/Tailwind
- Code zu Design-System-Vorschlaegen
- Design-Tokens extrahieren
- SVG-/Layout-Analyse
- Dashboard- und Agenten-UI-Prototypen iterieren

## Aktuelle Standardports laut offizieller Penpot-MCP-Doku

Die aktuellen Standardwerte laut offizieller Doku sind:

- `4400`: Plugin-Server fuer `manifest.json` bzw. Plugin-Auslieferung
- `4401`: MCP HTTP/SSE bzw. Streamable-HTTP-Endpunkt
- `4402`: WebSocket zwischen Penpot-Plugin und MCP-Server
- `4403`: REPL-/Debug-Port

Zusammenhaenge:

- Plugin-Manifest standardmaessig: `http://localhost:4400/manifest.json`
- MCP-Endpunkt modern: `http://localhost:4401/mcp`
- Legacy SSE: `http://localhost:4401/sse`

## Beispielkonfiguration fuer einen MCP-kompatiblen Client

### Direkter HTTP-MCP-Client

Wenn dein Client HTTP-MCP nativ versteht:

```txt
Servername: penpot
Transport: HTTP
URL: http://localhost:4401/mcp
```

### SSE-Client

Wenn dein Client mit SSE arbeitet:

```txt
Servername: penpot
Transport: SSE
URL: http://localhost:4401/sse
```

### Stdio-only Client ueber Proxy

Laut offizieller Penpot-MCP-Doku kann bei stdio-only Clients ein Proxy wie `mcp-remote` genutzt werden:

```bash
npx -y mcp-remote http://localhost:4401/sse --allow-http
```

## Sicherheitswarnung

Wichtige Sicherheitsregel fuer dieses Repository:

- Penpot MCP und das Penpot-Plugin nicht offen ins Internet stellen
- Web-UI, MCP-HTTP, SSE, WebSocket und Plugin-Server standardmaessig nur lokal oder privat betreiben
- bei Remote-Nutzung zuerst Auth, Reverse Proxy, Tailscale oder einen bewusst abgesicherten Tunnel planen

Besonders kritisch:

- der Plugin-Teil arbeitet im Kontext einer echten Design-Datei
- der MCP-Server kann Designdaten lesen und veraendern
- die Doku beschreibt ausserdem einen Modus, in dem der Agent Code ausfuehren oder Designumformungen erzeugen kann

## Empfehlung fuer dieses Setup

Empfohlener Start:

- Penpot Web-UI lokal
- Penpot MCP lokal
- AI-Client lokal
- keine Internet-Freigabe

Sinnvolle spaetere Erweiterung:

- Zugriff nur ueber `Tailscale`
- oder ueber bewusst abgesicherten Reverse Proxy
- oder ueber einen sehr gezielt konfigurierten Cloudflare Tunnel

Nicht empfohlen fuer den Anfang:

- offenes `0.0.0.0` fuer MCP
- ungeschuetzte Plugin-Server im Internet
- parallele Freigabe ohne Logging, Auth und Netztrennung

## Offizielle Quellen

- [Penpot Repository](https://github.com/penpot/penpot)
- [Penpot MCP Repository](https://github.com/penpot/penpot-mcp)
- [Penpot Configuration Guide](https://help.penpot.app/technical-guide/configuration/)
