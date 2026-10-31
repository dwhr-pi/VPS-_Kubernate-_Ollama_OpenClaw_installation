# Getrennte Coding-Agenten statt Einbau in Jarvis

[Gemini-Interview: Werkzeuge und offizielle GitHub-Quellen](../tutorials/gemini-development-tooling.md)
ordnet Projektbibliotheken, lokale Entwicklung und Google-Cloud-Funktionen ein. Der vorhandene
Gemini-Quellcheckout ist weiterhin keine gebaute CLI.

Optionaler Analysebaustein: [REA](../tools/rea.md) und
[App-Steckbrief/Bau-Tutorial](../tutorials/own-app-with-rea.md). GitHub-Installation und
MCP-Freigabe bleiben getrennt; keine automatische Zielanalyse.

Optionaler Skill-Layer: [find-skills fuer Claude Code und Qwen Code](../tools/find-skills.md).
Separater GitHub-Kopierinstaller nach Zustimmung; kein Einbau in Jarvis, keine automatische Cloud-,
CLI- oder Agentenausfuehrung.

## Rollen und Architektur

| Profil            | Verantwortung                                        | Kein Bestandteil dieser Rolle                        |
| ----------------- | ---------------------------------------------------- | ---------------------------------------------------- |
| Claude-Code-Agent | Planung, Refactoring, Architektur, Dokumentation     | Orchestrator, automatische Cloud-Freigabe            |
| Gemini-Code-Agent | Recherche, Multimodalitaet, Google-Oekosystem        | kostenloser Offline-Ersatz fuer Cloud-Modelle        |
| Jarvis-Core       | Orchestrierung, Routing und Uebergaben               | eingebauter Claude-/Gemini-Client                    |
| Ollama-Coder      | lokale Coding-Inferenz mit separat gewaehltem Client | garantierte Modell-/Hardwarekompatibilitaet          |
| OpenClaw          | optionale Agent Runtime                              | Freigabe beliebiger Systemaktionen                   |
| Kubernetes        | optionale Worker-Skalierung                          | Pflicht fuer das Minimalsetup, Sicherheits-Sandbox   |
| MCP               | Tool-Layer mit Allowlist                             | automatisch erlaubter Shell-/Datei-/Datenbankzugriff |

```text
Aufgabe -> Jarvis-Core: Routingplan
             |-> Claude-Code-Agent (Cloud nur bewusst)
             |-> Gemini-Code-Agent (Cloud nur bewusst)
             `-> Ollama-Coder (lokaler Standard)
Ausfuehrung spaeter separat: OpenClaw Runtime -> freigegebene MCP-Tools
Skalierung spaeter optional: Kubernetes Worker
```

Implementiert sind **Profilvorlagen**, ihre private Installation und ein deterministischer
**Offline-Routingplan**, noch kein ausfuehrender Adapter. Das JSON-Format ist eine eigene
Setup-Vorlage, keine direkt importierbare OpenClaw-/Claude-/Gemini-Konfiguration. Es wird nichts in
einen laufenden Jarvis-Prozess eingebaut. Die JSON-Policies beschreiben Zielgrenzen; sie sind keine
Sandbox, Firewall oder erzwungene Quota. Bestehende Jarvis-, Ollama-, OpenClaw- und
Kubernetes-Installationen bleiben gleich.

## Profile installieren

Beispiel fuer die Claude-Rolle, analog fuer alle sieben Profile in der
[Profilmatrix](../PROFILE_MATRIX.md):

```bash
bash scripts/profiles/Claude_Code_Agent_install.sh --dry-run
bash scripts/profiles/Claude_Code_Agent_install.sh
bash scripts/profiles/Claude_Code_Agent_check.sh
bash scripts/profiles/Claude_Code_Agent_uninstall.sh
```

Der Installer kopiert nur die passende Vorlage aus diesem GitHub-Setup- Checkout nach
`${OPENCLAW_USER_DATA_DIR:-$HOME/.openclaw_ultimate_user_data}/agent_profiles/`. Python 3.10+ ohne
Zusatzpakete, 16 MiB freie Disk. Kein Docker, Node-/Python- Bootstrap, Modell-Download, Clientstart
oder Login. Fremde/geaenderte Vorlagen werden nicht ueberschrieben. `--repair` setzt
Nutzeraenderungen nicht zurueck. Deinstallation deaktiviert nur die Registrierung, nicht die
eigentlichen Dateien. `template_installed` bedeutet nicht `runtime_ready`; letzteres bleibt false.

## GitHub-Quellen der Coding-Clients

[Claude Code: Coding-Agent und Open-Source-Grenze](../tools/claude-code.md) fasst die erneut
gepruefte Lizenz, den tatsaechlichen Checkout-Umfang und eigenstaendige quelloffene Alternativen
zusammen. Ein oeffentliches GitHub-Repository ist keine Open-Source-Lizenz und kein fertiger
CLI-Build.

```bash
bash scripts/tools/gemini_cli_install.sh --dry-run
bash scripts/tools/gemini_cli_install.sh
bash scripts/tools/gemini_cli_status.sh
bash scripts/tools/claude_code_install.sh --dry-run
bash scripts/tools/claude_code_install.sh
bash scripts/tools/claude_code_doctor.sh
```

Diese **Quellvorbereitung** laedt feste GitHub-Commits in den privaten User-Workspace unter
`tools/gemini_cli/source/` bzw. `tools/claude_code/source/`. Zwei GiB freie Ziel-Disk erforderlich.
Git und Netzverbindung fuer den bewusst ausgewaehlten Download, keine rekursiven Submodule, Builds,
Docker-Images, globalen Paketinstallationen oder CLIs werden ausgefuehrt. Unter WSL vorher
zusaetzlich Windows-Host-Disk pruefen; dieser Python-Quellhelfer misst nur die freie Kapazitaet des
Ziel-Dateisystems. Keine Aussage ueber WSL-VHDX-Reserve.

| Quelle                                                                                                                | Gepinnter Commit                         | Installationsumfang                                |
| --------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- | -------------------------------------------------- |
| [google-gemini/gemini-cli](https://github.com/google-gemini/gemini-cli/tree/ed96faedfd5571f055c44f2c9509d62321d1138d) | ed96faedfd5571f055c44f2c9509d62321d1138d | Apache-2.0-Quellcode, noch keine gebaute CLI       |
| [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/dd6bee38458cc3e6dc5f2b16eca1f0f364619ad8)     | dd6bee38458cc3e6dc5f2b16eca1f0f364619ad8 | Referenzmaterial/Plugins, keine baubare Claude-CLI |

**Claude Code ist nicht Open Source.** Die Repository-Lizenz verweist auf
[Anthropics Commercial Terms](https://github.com/anthropics/claude-code/blob/dd6bee38458cc3e6dc5f2b16eca1f0f364619ad8/LICENSE.md).
Ein Git-Clone installiert daher keinen funktionsfaehigen Claude-Client. Unter der Vorgabe "nur
GitHub" wird keine andere proprietaere Distribution heimlich von npm, claude.ai oder Docker
nachgeladen. Eine bereits bewusst installierte CLI kann spaeter als separater Adapter eingebunden
werden.

Davon getrennt gibt es die offizielle **MIT-lizenzierte Claude-API-CLI `ant`** aus
`anthropics/anthropic-cli`. Sie wird als eigener Eintrag
[Anthropic_CLI aus GitHub](../tools/anthropic-cli.md) angeboten und ist kein automatischer Ersatz
fuer den Coding-Agenten oder dieses Rollenprofil.

Gemini CLI ist quelloffen; ein nativer Build benoetigt zusaetzlich einen passenden Node-/npm-Stack
und Registry-Abhaengigkeiten. Das bleibt ein eigener Buildschritt nach Pruefung der
[Upstream-Buildanleitung dieses Pins](https://github.com/google-gemini/gemini-cli/tree/ed96faedfd5571f055c44f2c9509d62321d1138d).
Der gepinnte Snapshot ist ein Entwicklungsstand (Paketversion 0.66.0-nightly.20261013.g204db94ae),
kein hier getestetes Stable-Release. Quelloffener Client bedeutet weder lokales Gemini-Modell noch
kostenfreie, unbegrenzte Cloud-Nutzung. Keine Google-Anmeldung oder API-Aufrufe im Installer.

`update` bleibt auf dem Pin. `--repair` verwirft keine lokalen Aenderungen. Uninstall entfernt nur
`source-ready.json`; Quellen bleiben erhalten. Seit 19.10.2026 synchronisiert das Tools-Menue auch
`Claude_Code` und `Gemini_CLI` anhand ihrer nichtleeren `source-ready.json`-Marker. Bestehende
Vorbereitungen werden beim naechsten Menueaufruf in beide Setup-Statuslisten uebernommen, ohne
erneuten Download. Nach Markerentfernung verschwinden die Eintraege wieder; blosse Quellordner
reichen nicht als Installationsnachweis. Der Menuehaken bedeutet hier nur
**GitHub-Quellen/Referenzmaterial vorbereitet**, nicht CLI gebaut, authentifiziert oder
betriebsbereit. Fuer die ausfuehrliche Pin-/Quellpruefung den jeweiligen Doctor verwenden. Extern
installierte CLIs ohne Setup-Marker werden dadurch nicht als setupverwaltet ausgegeben.
`source_ready` und erfolgreiches Doctor bedeuten nicht lauffaehige CLI. Direkte Skriptaufrufe geben
Status aus; beim Menueaufruf protokolliert der bestehende Setup-Logger. Der neue Helfer gibt
Git-stderr bewusst nicht aus, um Proxy-/Credential-Informationen nicht weiterzureichen.

## Routingplan ohne Ausfuehrung

```bash
python3 scripts/profiles/coding_agents.py route architecture
python3 scripts/profiles/coding_agents.py route research --allow-cloud
python3 scripts/profiles/coding_agents.py route coding
```

Ohne Cloud-Freigabe waehlt auch eine Architektur-/Rechercheaufgabe den lokalen Ollama-Coder als
**gekennzeichneten Fallback**, nicht als behaupteten identischen Ersatz. `--allow-cloud` aendert nur
den Plan; `executed` bleibt false. Planung/Refactoring/Architektur/Dokumentation bevorzugen Claude,
Recherche/ Multimodalitaet/Google Gemini, Coding/Local Ollama. Weitere Kategorien: `orchestrate`,
`runtime`, `scale`, `tools`. Der Planer startet keine Programme.

## Vertrag fuer spaetere Adapter

Eine freizugebende Aufgabe braucht Aufgaben-ID, erlaubten Workspace, Eingabedatei-Allowlist,
Zielprofil, feste Testkommandos, Timeout und Budget. Ergebnis: Diff-Vorschlag, Testbericht,
Quellenangaben und offene Risiken. Keine unkontrollierten Shellstrings aus LLM-Ausgaben ausfuehren.
Standard ein Job, drei Korrekturrunden und 900 Sekunden als Zielpolicy; ein spaeterer Executor muss
diese Grenzen technisch durchsetzen.

Cloud-Upload pro Auftrag freigeben, Kostenlimit setzen, Secrets/Personalakten vorher aussortieren.
Keine API-Keys in Profilen oder Logs. MCP-Tools einzeln read-only freigeben, eigene Credentials je
Rolle, keine offenen Container- Sockets. Schreibaktionen, Git-Commit/Push, Deployments und
Cluster-Zugriff separat bestaetigen. Weder Kubernetes noch ein Prompt ersetzt Least Privilege.

Minimal: Vorlagen + vorhandenes Ollama/Client, kein Cluster. Cloud-Clients, OpenClaw, MCP und
Kubernetes spaeter separat pruefen. Keine Installation oder Aenderung in der Benutzer-WSL durch die
Entwicklungsarbeit ausgefuehrt.
