# GBOX

`babelcloud/gbox` ist eine CLI- und MCP-nahe Umgebung, mit der AI-Agenten Android-, Browser- und Desktop-Umgebungen bedienen koennen.

## Einordnung im Setup

Primäres Profil fuer dein `myBox`-Projekt:

- `Android_App_Builder`

Zusaetzlich sinnvoll:

- `MCP_Agent_Tools`
- `Browser_Automation_Agent`
- `Local_AI_App_Builder`

## Quelle

- GitHub: `https://github.com/babelcloud/gbox`
- Lizenz laut Upstream: Apache-2.0

## Installation

Dieses Setup nutzt bewusst die GitHub-Quelle statt fertiger npm-/Homebrew-Pakete:

```bash
bash scripts/tools/gbox_install.sh
```

Optionaler Source-Build:

```bash
GBOX_BUILD_FROM_SOURCE=1 bash scripts/tools/gbox_install.sh
```

Der Source-Build erwartet laut Upstream Go, make, Node.js und pnpm via Corepack. Falls diese Abhaengigkeiten fehlen, bricht der Installer ab und installiert keine fertigen Pakete im Hintergrund.

## myBox-Nutzung

GBOX eignet sich fuer:

- Android-App-Tests und UI-Flows
- mobile Automation mit Testgeraeten
- MCP-Anbindung fuer Agenten
- Browser-/Desktop-Automation in kontrollierten Umgebungen
- Codex-/OpenClaw-gestuetzte myBox-Entwicklung

## Sicherheit

- Zuerst nur Testgeraete und Testkonten nutzen.
- Kein produktives Google-/Bank-/Shop-Konto in automatisierte Agenten geben.
- Externe GBOX-/Cloud-Umgebungen nur bewusst nach Login und Kostenpruefung nutzen.
- MCP-Server niemals offen ins Internet stellen.
- Android-Debugging nur auf Geraeten aktivieren, denen du vertraust.
