# Gemini Desktop: Windows, Gemini CLI und OpenClaw

Stand: 28.10.2026. **Installations-, Build- und Integrationstests ungeprueft.**

## Die entscheidende Unterscheidung

Beide genannten Projekte sind unabhaengige Electron-Oberflaechen fuer die **Gemini-Webseite**, nicht
fuer **Gemini CLI**. Windows-Desktopzugriff auf Gemini ist damit moeglich; ein Terminal-Agent, eine
lokale Modelllaufzeit oder eine Windows-Computersteuerung entsteht dadurch nicht. Google-Chat, CLI
und OpenClaw-Gateway sind unterschiedliche Produkte und Schnittstellen.

| Projekt                                                                 | Einordnung                                                   | Pflege und Windows                                                                 |
| ----------------------------------------------------------------------- | ------------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| [bwendell/gemini-desktop](https://github.com/bwendell/gemini-desktop)   | Gemini-Webwrapper mit Fenstern, Hotkeys und Zusatzfunktionen | Pflege seit Juli 2026 pausiert; Windows x64/ARM64-Releases vorhanden               |
| [dortanes/gemini-desktop](https://github.com/dortanes/gemini-desktop)   | Zweiter Gemini-Webwrapper, kein Fork des ersten Projekts     | Archiviert; Windows-x64-Release, Linux/macOS nicht als fertige Releases abgenommen |
| [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli) | Eigener Kommandozeilenagent                                  | Separater CLI-Installations-/Buildweg, keine dieser beiden GUIs                    |
| OpenClaw                                                                | Eigener Agent/Gateway mit Control UI                         | Eigene Authentifizierung, Freigaben und Konfiguration                              |

Beide Desktop-Projekte sind Drittanbieterprojekte unter MIT, keine offiziellen Google-Clients. Die
Dienstbedingungen von Google und Abhaengigkeitslizenzen gelten daneben weiter. Quelloffener Wrapper
bedeutet nicht lokale/private Gemini-Inferenz. Login-Sitzungen und App-Einstellungen koennen lokal
liegen; Chats ueber die Google-Webseite erreichen weiterhin Google.
[Bwendell-README](https://github.com/bwendell/gemini-desktop/blob/6dae4a7e88fba61a4e17aa3a58902c7a2c4f779e/README.md),
[Dortanes-README](https://github.com/dortanes/gemini-desktop/blob/2dedef7d6e0665c9b95a137255df9477152bcf8f/README.md).

Bwendell besitzt zusaetzlich lokale Textvorhersage ueber `node-llama-cpp` und optionale
Qwen-GGUF-Downloads. Das betrifft Eingabevorschlaege, nicht einen allgemeinen Chatprovider-Schalter
fuer Ollama oder OpenClaw. Diese Funktionen werden vom Setup weder aktiviert noch heruntergeladen.
[LLM-Manager](https://github.com/bwendell/gemini-desktop/blob/6dae4a7e88fba61a4e17aa3a58902c7a2c4f779e/src/main/managers/llmManager.ts).

## Auswahl im Setup

Nach der bestehenden Trennlinie unter G, alphabetisch und ohne Docker:

| Menueeintrag                     | Was passiert tatsaechlich?                                                                    |
| -------------------------------- | --------------------------------------------------------------------------------------------- |
| `Gemini_Desktop_Bwendell`        | Manueller GitHub-Release-Weg mit Wartepunkt; kein automatischer Download oder EXE-Start       |
| `Gemini_Desktop_Bwendell_Source` | Gepinnte GitHub-Quellen fuer Studien/Weiterentwicklung, keine gebaute App                     |
| `Gemini_Desktop_Dortanes_Legacy` | Warnung und fester Release-Link; wegen Legacy-Risiken kein automatisches Oeffnen/Installieren |
| `Gemini_Desktop_Dortanes_Source` | Gepinnte archivierte Studienquellen; kein Build, Login oder GUI-Start                         |

Die Desktop-Eintraege erzeugen **keinen technisch geprueften Installiert-Marker**. Eine manuelle
Bestaetigung bleibt manuell/unverifiziert. Bei Source-Eintraegen bedeutet installiert
ausschliesslich: Quellen vorbereitet, nicht Windows-App installiert. Die getrennten Namen verhindern
ein Gleichsetzen der beiden gleichnamigen Upstream-Projekte.

```bash
# Offline-Plan, ohne Browseroeffnung oder Download:
bash scripts/tools/gemini_desktop_bwendell_install.sh --dry-run
bash scripts/tools/gemini_desktop_dortanes_install.sh --dry-run
bash scripts/tools/gemini_desktop_bwendell_source_install.sh --dry-run
bash scripts/tools/gemini_desktop_dortanes_source_install.sh --dry-run

# Quellen bewusst vorbereiten:
bash scripts/tools/gemini_desktop_bwendell_source_install.sh
bash scripts/tools/gemini_desktop_dortanes_source_install.sh
```

Die Quellen brauchen jeweils 2 GiB konservative Diskreserve. Sie liegen im externen User-Workspace
unter `tools/<id>/runtime/`, nicht im Setup-Repository:

| Quell-ID                         | Fester Commit                              |
| -------------------------------- | ------------------------------------------ |
| `gemini_desktop_bwendell_source` | `6dae4a7e88fba61a4e17aa3a58902c7a2c4f779e` |
| `gemini_desktop_dortanes_source` | `2dedef7d6e0665c9b95a137255df9477152bcf8f` |

`update`, `status`, `check`, `doctor` und `uninstall` haben eigene Skripte mit demselben ID-Praefix.
Update prueft denselben Pin, kein bewegliches `main`. Deinstallation entfernt nur inventarisierte
unveraenderte Quellbestande; geaenderter Bestand wird geschuetzt. Windows-Programme werden separat
ueber Windows deinstalliert; Cookies, Logins und Browserprofile werden nicht entfernt oder zwischen
beiden gleichnamigen Apps uebertragen.

## Windows-Releases manuell pruefen

Nur Releases des jeweiligen Projekts verwenden, nicht zufaellige Downloads:

| Projekt  | Fixierter Release                                                          | Windows-Datei                                                 |
| -------- | -------------------------------------------------------------------------- | ------------------------------------------------------------- |
| Bwendell | [v0.12.1](https://github.com/bwendell/gemini-desktop/releases/tag/v0.12.1) | `Gemini-Desktop-0.12.1-x64-installer.exe` oder ARM64-Variante |
| Dortanes | [v1.0.1](https://github.com/dortanes/gemini-desktop/releases/tag/v1.0.1)   | `Gemini.AI.Setup.1.0.1.exe`, Legacy/Studienzweck              |

Zum Recherchezeitpunkt meldet die GitHub-Release-API folgende SHA256-Werte:

```text
Bwendell Windows x64:
872202203450d52a3b6e9c2079cc4435fb187f939f6fd84c52843e16d4a37660
Bwendell Windows ARM64:
bf74860eee5425788ad611b8fafc05d1bf868009049ffd540f3cce1d67e9ce13
Dortanes Windows x64:
b97f8351c7c054c65ed4f65af0b75450909d147b500079e53cdc76ef96f55148
```

[Bwendell-Release-Metadaten](https://api.github.com/repos/bwendell/gemini-desktop/releases/tags/v0.12.1),
[Dortanes-Release-Metadaten](https://api.github.com/repos/dortanes/gemini-desktop/releases/tags/v1.0.1).
Das sind Metadaten, kein hier durchgefuehrter Binaer-/Signaturtest und keine Zusage, dass der
aktuelle Quell-Pin exakt dem Release-Binary entspricht. Nach einem bewussten Download in
Windows-PowerShell pruefen:

```powershell
$installer = Join-Path $HOME 'Downloads\Gemini-Desktop-0.12.1-x64-installer.exe'
Get-FileHash -LiteralPath $installer -Algorithm SHA256
Get-AuthenticodeSignature -LiteralPath $installer |
    Format-List Status, SignerCertificate
```

Dateiname und Hash an die gewaehlte Variante anpassen. Passende SHA256 ist kein Beweis fuer sichere
Software oder eine vertrauenswuerdige Herausgebersignatur. SmartScreen, Sandbox und
Web-Sicherheitsfunktionen nicht abschalten. Keine EXE aus WSL automatisch starten. Beide Projekte
sind aktuell keine Empfehlung fuer privilegierte Agenten oder sensible Produktivkonten.

## Konkrete Sicherheitsbefunde

Beim Dortanes-Pin steht in `src/handlers/WebContentsViewHandler.js` `webSecurity: false`;
zusaetzlich werden entsprechende Chromium-Schalter gesetzt. `package.json` enthaelt
`verifyUpdateCodeSignature: false`. Das ist ein Grund gegen die Verwendung als privilegierte
OpenClaw-Oberflaeche. Der README-Verweis auf den Nachfolger Atlas ist **keine** hier gepruefte
Migration; Atlas wird nicht automatisch installiert.
[WebContentsViewHandler](https://github.com/dortanes/gemini-desktop/blob/2dedef7d6e0665c9b95a137255df9477152bcf8f/src/handlers/WebContentsViewHandler.js),
[Paket-/Updater-Konfiguration](https://github.com/dortanes/gemini-desktop/blob/2dedef7d6e0665c9b95a137255df9477152bcf8f/package.json).

Bwendell verankert Gemini-/Google-Domains und die Gemini-App-URL im Code. Navigations-,
Berechtigungs- und DOM-Logik sind darauf abgestimmt. Eine andere Startadresse allein macht daraus
keinen sicheren allgemeinen Agentenclient.
[Konstanten](https://github.com/bwendell/gemini-desktop/blob/6dae4a7e88fba61a4e17aa3a58902c7a2c4f779e/src/main/utils/constants.ts),
[Berechtigungen](https://github.com/bwendell/gemini-desktop/blob/6dae4a7e88fba61a4e17aa3a58902c7a2c4f779e/src/main/utils/security.ts).

## Wie Gemini CLI vom Windows-Desktop erreichbar wird

Fuer die echte CLI Windows Terminal oder ein geeignetes IDE-Terminal verwenden, nicht diese
Webseitenwrapper. Zuerst nur pruefen, ob eine fertige CLI existiert:

```powershell
Get-Command gemini -ErrorAction SilentlyContinue
# Alternativ in einer bereits vorhandenen WSL-Distribution pruefen:
wsl.exe -d Ubuntu -- bash -lc 'command -v gemini'
```

Wenn eine funktionsfaehige, bewusst eingerichtete CLI vorhanden ist:

```powershell
# Expliziter interaktiver Start, kann Anmeldung/Cloudnutzung erfordern:
wt.exe new-tab wsl.exe -d Ubuntu -- bash -lc gemini
```

`Ubuntu` gegebenenfalls an den Namen der eigenen Distribution anpassen. Die bestehende Setup-Auswahl
`Gemini_CLI` bereitet derzeit Quellen vor; sie garantiert **keinen** verfuegbaren `gemini`-Befehl.
CLI-Login, Modellzugriff und Freigaben bleiben eigene Schritte. Google-Websitzung, CLI-Anmeldung und
API-Key-Abrechnung nicht gleichsetzen.

## OpenClaw oder Programmierer-Setup statt Gemini

**Direkt umschaltbar: nein. Als eigener Fork prinzipiell moeglich, hier nicht implementiert oder
abgenommen.** Es gibt in den geprueften Projektanleitungen keinen belegten
OpenClaw-/Ollama-/OpenAI-Base-URL-Schalter fuer den Hauptchat.

Der sichere Einstieg nutzt die vorhandene **OpenClaw Control UI**. Bei bereits laufendem lokalem
Gateway im Windows-Browser `http://127.0.0.1:18789/` oeffnen, normal anmelden und gegebenenfalls das
Geraet koppeln. Authentifizierung nicht abschalten. Bei WSL zuerst die Erreichbarkeit ueber
Windows-Localhost pruefen. Ein eigenes Desktopfenster kann ein bereits vorhandener Browser
bereitstellen:

```powershell
# Oeffnet nur ein Fenster; installiert/startet keinen Gateway-Dienst:
Start-Process msedge.exe -WindowStyle Normal -ArgumentList '--app=http://127.0.0.1:18789/'
```

Keine Tokens in Verknuepfungen, Kommandozeilen oder URLs hinterlegen. Fuer einen VPS einen
bestehenden VPN-/HTTPS-Zugang oder einen bewusst aufgebauten SSH- Tunnel nutzen; niemals den
Gateway-Port pauschal oeffentlich freigeben. WebSocket-Authentifizierung und Pairing gelten
weiterhin. [Offizielle Control UI](https://docs.openclaw.ai/web/control-ui),
[Verbindung und Pairing](https://docs.openclaw.ai/web/control-ui/connect-and-pair).

Fuer dein interaktives Programmierer-Setup ist ein Windows-Terminalfenster mit dem vorhandenen
WSL-Checkout ausreichend:

```powershell
# Pfad und Distribution muessen dem eigenen vorhandenen Setup entsprechen:
wt.exe new-tab wsl.exe -d Ubuntu --cd /home/ubuntu/openclaw_ultimate_setup -- bash setup_ultimate.sh
```

Das oeffnet das vorhandene Menue, keine zusaetzliche KI-Laufzeit. Coding-Agent, Projektverzeichnis,
Sandbox und Freigaben werden dort separat ausgewaehlt. Fuer reine Modellchats ist die bereits
dokumentierte Open-WebUI-/Ollama- Anbindung ein anderer Weg; sie ist nicht automatisch eine
OpenClaw-Steuerung.

## Was ein echter Fork oder Backendadapter benoetigt

1. Eigenen App-Namen, App-ID und getrenntes Daten-/Sitzungsprofil vergeben.
2. Entweder die bestehende lokale Control UI anzeigen oder eine eigene Chat-UI bauen.
3. Gemini-URL, Google-Login, DOM-Injektionen, Sprachautomation und Updateziel ersetzen; nicht nur
   `loadURL` aendern.
4. Bei einem eigenen API-Client den dokumentierten OpenClaw-Gateway-/WebSocket-Vertrag inklusive
   Auth, Pairing, Streaming und Freigaben implementieren. Eine OpenAI-Base-URL ist kein Ersatz
   dafuer.
5. Remote-Inhalte ohne Node-Zugriff, mit Kontextisolation, Sandbox, Web-Sicherheit und enger
   Navigations-/IPC-Allowlist betreiben. Keine Shell-/Dateisystemrechte an fremde Webseiten geben.
6. Fuer Gemini CLI stattdessen einen getrennten Subprozessadapter mit Argumentliste statt
   Shell-String, kontrolliertem Arbeitsordner und Versions-/Ausgabeformatpruefung entwickeln.
7. Tests mit fiktiven Daten und ohne Prod-Secrets, dann Login-/Berechtigungs-/Updatepruefung und
   getrennte Windows-Abnahme durchfuehren.

Diese Liste ist ein Refactor-Plan, **kein fertiger Adapter**. Fuer den praktischen Einstieg ist die
OpenClaw-eigene Oberflaeche wesentlich weniger Umbau als ein Google-Webwrapper. Modellwechsel
erfolgt im jeweiligen Backend, nicht durch das Umbenennen der Desktop-App. Agentenaktionen brauchen
weiter passende Rechte und menschliche Freigaben; ein Desktopfenster erweitert diese Rechte nicht.

## Quellbuilds und Abnahme

Ein Source-Menueeintrag fuehrt weder `npm install` noch Electron aus. Fuer einen spaeteren nativen
Windows-Build in einer getrennten Entwicklungsumgebung sind die jeweiligen Upstream-Bauanleitungen
massgeblich:

- Bwendell: `package-lock.json`, npm, Renderer-/Electron-Build und Windows- Distributionsskripte.
  `npm ci` kann Lifecycle-Skripte und native/Electron- Downloads ausloesen; Node-Anforderungen auch
  aus den gelockten Dependencies pruefen, nicht blind aus einer alten Mindestversionsangabe
  uebernehmen.
- Dortanes: `yarn.lock`, Yarn und `dist`-/`build-win`-Skripte. Archivierter Dependency-Stand,
  `postinstall` und bekannte Sicherheitsflags muessen zuerst ueberarbeitet werden. Kein abgenommener
  Linux-/macOS-Build allein aufgrund vorhandener Skriptnamen.

[Bwendell-Bauanleitung](https://github.com/bwendell/gemini-desktop/blob/6dae4a7e88fba61a4e17aa3a58902c7a2c4f779e/docs/CONTRIBUTING.md),
[Dortanes-Bauanleitung](https://github.com/dortanes/gemini-desktop/blob/2dedef7d6e0665c9b95a137255df9477152bcf8f/README.md).
Es gibt hier keinen automatisierten Source-Build, keinen neuen Installer- Signierschluessel, keine
Veroeffentlichung und keinen Login-/Modelltest.

Weiter: [Tools-Katalog](../TOOLS_CATALOG.md), [agentisches Coding](agentic-coding.md),
[OpenAPI-Toolserver](openapi-servers.md), [Registry](../../config/tools.yml).
