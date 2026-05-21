# myBox + GBOX Integration

## Kurzentscheidung

`babelcloud/gbox` passt am besten zum Profil `Android_App_Builder`.

Fuer dein `myBox`-Projekt ist GBOX ein sinnvoller Baustein, wenn Codex/OpenClaw Android-Apps testen, UI-Flows bedienen oder spaeter ueber MCP eine mobile Umgebung steuern soll.

## Warum dieses Profil?

| Profil | Rolle fuer myBox |
|---|---|
| `Android_App_Builder` | Primaeres Profil fuer Android-App-Entwicklung, Tests, Companion-App und mobile Automation |
| `MCP_Agent_Tools` | Macht GBOX als Tool-/MCP-Schicht fuer Agenten sichtbar |
| `Browser_Automation_Agent` | Ergaenzt Browser-/Desktop-Tests und UI-Pruefungen |
| `Local_AI_App_Builder` | Gut fuer lokale myBox-Dashboards, Admin-Panels und interne UIs |

## Was GBOX fuer myBox leisten kann

- Android-App auf Testgeraet oder Testumgebung bedienen
- UI-Abläufe pruefen
- Screenshots und Zustandspruefungen fuer Codex/OpenClaw vorbereiten
- MCP-Server fuer Agenten bereitstellen
- Browser-/Desktop-nahe Testumgebungen in spaeteren Ausbaustufen anbinden

## Installationspfad

```bash
bash scripts/tools/gbox_install.sh
```

Optional aus Source bauen:

```bash
GBOX_BUILD_FROM_SOURCE=1 bash scripts/tools/gbox_install.sh
```

## Sicherheitsregeln

- Starte mit Testgeraet, Test-App und Testkonto.
- Keine produktiven Zahlungs-, Google-, Banking- oder Shop-Konten automatisieren.
- Agenten duerfen nicht ohne Freigabe Apps bedienen, die Kosten ausloesen koennen.
- MCP-/Device-Zugriff nur lokal oder privat ueber Tailscale/Cloudflare Access freigeben.
- Erst beobachten und protokollieren, dann automatisieren.

## Empfohlener Codex-Workflow

```text
1. myBox Android-App bauen.
2. GBOX-Testumgebung oder lokales Android-Testgeraet vorbereiten.
3. Codex/OpenClaw bekommt eine konkrete Testaufgabe.
4. GBOX fuehrt nur den definierten UI-Test aus.
5. Ergebnis als Screenshot, Log und Fehlerbeschreibung speichern.
6. Codex korrigiert den Code oder erstellt eine Issue-/Fix-Liste.
```

## Status

Experimentell, aber passend. GBOX ist stark fuer Agenten-Automation, braucht aber klare Grenzen, weil es reale Apps und Geraete bedienen kann.
