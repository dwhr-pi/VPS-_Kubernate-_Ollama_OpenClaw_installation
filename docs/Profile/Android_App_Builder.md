# Android App Builder

Geplantes Setup-Profil fuer Android SDK, Gradle, Kotlin-Workflows, Companion-Apps und dein `myBox`-Projekt. Siehe Quellprofil: `docs/Profil/Android_App_Builder.doc.md`.

Status: `planned`

## Kern-Tools

- Java JDK
- Gradle
- Android SDK CLI
- optional Node/pnpm
- `gbox` fuer agentische Android-/UI-Automation und MCP-nahe Device-Steuerung

## GBOX fuer myBox

`babelcloud/gbox` passt hier als primaeres Tool, wenn Codex/OpenClaw Android-UI-Flows pruefen, Screenshots erzeugen oder spaeter ueber MCP ein Testgeraet bedienen soll.

Empfohlener Einstieg:

```bash
bash scripts/tools/gbox_install.sh
```

Optionaler Source-Build:

```bash
GBOX_BUILD_FROM_SOURCE=1 bash scripts/tools/gbox_install.sh
```

## Sicherheitsgrenzen

- zuerst nur Testgeraet, Test-App und Testkonto verwenden
- keine produktiven Zahlungs-, Banking-, Google- oder Shop-Konten automatisieren
- MCP-/Device-Zugriff nur lokal oder ueber private Tunnel freigeben
- agentische Aktionen immer protokollieren und bei riskanten Schritten manuell freigeben

Mehr Details: `docs/myBOX_GBOX_INTEGRATION.md`
