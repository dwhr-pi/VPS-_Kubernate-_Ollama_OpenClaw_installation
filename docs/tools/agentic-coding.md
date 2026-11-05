# Tools fuer Agentic Coding

[Ausfuehrlicher Einsteiger-Leitfaden](../AGENTIC_CODING_GUIDE.md). Stand: 14.10.2026. Registriert
bedeutet **nicht** erfolgreich installiert, getestet, sicher konfiguriert oder produktionsreif.
Keine Installation wurde fuer diesen Leitfaden ausgefuehrt.

## Vorhandene Tools bewusst auswaehlen

| Registry-ID       | Primaerquelle                                                             | Rolle                                      | Tatsaechlicher Setup-Pfad / Grenze                                                                                                                                   |
| ----------------- | ------------------------------------------------------------------------- | ------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `aider`           | [Aider-AI/aider](https://github.com/Aider-AI/aider)                       | Terminal-Coding, Diff und Testfeedback     | GitHub-/venv-Scaffold; Abhaengigkeiten kommen auch aus Python-Paketquellen; Versions-/Smoke-Test offen                                                               |
| `continue_dev`    | [continuedev/continue](https://github.com/continuedev/continue)           | editornahe Coding-/Agentenarbeit           | GitHub/npm-Scaffold; eine erfolgreiche Source-Installation ersetzt keine konfigurierte IDE-Integration                                                               |
| `opencode`        | [anomalyco/opencode](https://github.com/anomalyco/opencode)               | Coding-Client                              | Registry weiterhin planned/Stub, nicht durch ungenutztes Scaffold-Skript aktivieren; alte Quelle sst/opencode nicht mit einem getesteten aktuellen Build verwechseln |
| `openhands`       | [OpenHands/OpenHands](https://github.com/OpenHands/OpenHands)             | agentische Repo-/Sandbox-Aufgaben          | Scaffold mit benoetigter Laufzeitkonfiguration, kein fertig getesteter Sandbox-Betrieb; Docker-/Hostzugriff pruefen                                                  |
| `langgraph`       | [langchain-ai/langgraph](https://github.com/langchain-ai/langgraph)       | explizite Workflows/Zustandsgraphen        | vorhandener Python-Paket-Installer; nicht automatisch GitHub-Source-Build, kein fertiger Coding-Agent                                                                |
| `crewai`          | [crewAIInc/crewAI](https://github.com/crewAIInc/crewAI)                   | Rollen-/Multi-Agent-Orchestrierung         | vorhandener Installer, Ende-zu-Ende-Integration und Rechtekonzept nicht nachgewiesen                                                                                 |
| `autogen`         | [microsoft/autogen](https://github.com/microsoft/autogen)                 | vorhandene Multi-Agent-Anwendungen         | Upstream Maintenance Mode; bestehende Projekte erhalten, Migration gesondert planen                                                                                  |
| `agent_framework` | [microsoft/agent-framework](https://github.com/microsoft/agent-framework) | optionale Python-Orchestrierungsbibliothek | **experimental**, gepinnter GitHub-Core-Source-Installer in eigener venv, kein Docker/Start; [Anleitung](microsoft-agent-framework.md)                               |
| `automaton`       | [Conway-Research/automaton](https://github.com/Conway-Research/automaton) | autonome Runtime als Forschungsreferenz    | **planned/high-risk**, nur eigener Offline-Vorschlagspruefer; Runtime/Wallet/Signieren/Cloud/Replikation gesperrt                                                    |

Die Quellen wurden fuer die Dokumentation geprueft, aber weder deren Lizenzen und Abhaengigkeiten
vollstaendig auditiert noch ihre Kombination getestet. GitHub als Primaerquelle bedeutet nicht, dass
npm/PyPI-/Image-Abhaengigkeiten verschwinden. Bestehende Installer nicht allein zum Nachlesen
starten: nicht jeder aeltere Installer hat ein nebenwirkungsfreies `--dry-run`.

AutoGen verweist selbst auf Microsoft Agent Framework als Nachfolger. Das ist eine
Upstream-Empfehlung, keine automatisch vollzogene Migration oder Garantie unserer Integration.
Modellzugang, API-Kompatibilitaet und Deployment muessen separat getestet werden.
[Upstream-Hinweis](https://github.com/microsoft/autogen#readme).

## Kein Installationspaket fuer alles

Minimal: ein Coding-Client, ein vorhandenes Modell und festgelegte Tests. Ollama ist eine
Modellruntime, nicht selbst der Coding-Agent. Ein LLM benoetigt passende
Tool-Calling-/Kontext-Faehigkeiten und ist deshalb nicht beliebig gegen jedes andere Modell
austauschbar. Lokale Provider-/Client-Kompatibilitaet vor vertraulichem Einsatz mit synthetischen
Aufgaben pruefen.

Ausbau nach Bedarf: LangGraph **oder** ein passendes Orchestrierungsframework, nicht alle Frameworks
parallel. OpenClaw/n8n koennen spaeter freigegebene, strukturierte Auftraege vermitteln; sie
erhalten keine ungefilterten Shellstrings aus Mails, Webseiten oder Modellantworten. Bei der
[WebsiteFactory](websitefactory.md) den dortigen Prototyp-/Integrationsstand beachten, nicht
automatisch einen fertigen SaaS-Generator annehmen.

Qualitaetswerkzeuge aus dem vorhandenen Setup: Playwright fuer isolierte Browserchecks, Gitleaks
fuer Secret-Scan, Semgrep fuer zusaetzliche Codepruefungen. Ein Scanner-Ergebnis ist keine
Zertifizierung. Browsertests koennen Daten versenden; nur Testkonten, Testzahlungen und freigegebene
Ziele verwenden.

## Neue Registrierung gefahrlos pruefen

```bash
bash scripts/tools/agent_framework_install.sh --dry-run
bash scripts/tools/agent_framework_status.sh
bash scripts/profiles/Agentic_Coding_Local_First_install.sh --dry-run
```

Der Framework-Dry-Run beschreibt den GitHub-Python-Core-Installer ohne Downloads. Ein normaler
Install-Aufruf installiert jetzt bewusst das SDK. Status und Doctor pruefen die vorhandene
Installation offline, aber keine Modellfunktion. Es werden keine Ports geoeffnet. Das Gesamtprofil
bleibt weiterhin planned.

## Ressourcen und offene Aufgaben

Keine pauschale RAM-/VRAM-Zahl fuer alle Agenten: Client, Modell, Build und Browser addieren ihren
Bedarf. Fuer ein erstes Testprojekt nur einen Auftrag ausfuehren und messen; keine schweren
Installationen im Hintergrund starten. Secrets liegen nicht in Aufgaben oder Git, sondern im
privaten User-Workspace. Kein automatischer Import aller ENV-Tresorwerte in einen Coding-Agenten.

Offen: versionsgebundene SDK-/Source-Pfade, einheitliche Dry-Runs fuer die aelteren Installer, echte
Client-/Ollama-Smoke-Tests, getestete Sandboxes und Queue-Integration. Microsoft Agent Framework hat
nun einen optionalen Source-Installer mit eigenem Operations-Lock; Modell-/Agentenbetrieb bleibt
separat. Die [Automaton-Integration](automaton.md) behielt ihre separaten Schutzsperren.

<!-- BEGIN GENERATED VPS SSH -->

## VPS ueber SSH bedienen

Voraussetzung: ein bereits gepruefter Setup-Checkout und ein selbst eingerichteter
SSH-Alias `vps` (Benutzer, Host und Schluessel in deiner SSH-Konfiguration).
Alternativ `vps` durch `BENUTZER@VPS_HOST` ersetzen. Den Host-Fingerprint vorher
unabhaengig pruefen; keine Host-Key-Pruefung abschalten. Keine Zugangsdaten in Git.

Auf deinem Client (PowerShell, Linux oder macOS):

```bash
ssh -t vps
```

Danach **im Linux-Terminal des VPS**. Den Pfad bei einem Branch-Checkout anpassen;
ein Windows-/Desktop-Tool wird durch SSH nicht zu einer VPS-Anwendung:

```bash
cd "$HOME/openclaw_ultimate_setup" || exit 1
test -f scripts/tool_commands.py || exit 1
```

Zuerst nur den Offline-Plan lesen (keine Installation und kein Dienststart):

```bash
python3 -I -B scripts/tool_commands.py show autogen
python3 -I -B scripts/tool_commands.py show continue_dev
python3 -I -B scripts/tool_commands.py show crewai
python3 -I -B scripts/tool_commands.py show langgraph
```

### SSH-Aktionen: `autogen`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`AutoGen` (ID `autogen`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

### SSH-Aktionen: `continue_dev`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`Continue.dev` (ID `continue_dev`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

### SSH-Aktionen: `crewai`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`CrewAI` (ID `crewai`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

### SSH-Aktionen: `langgraph`

Kein freigegebener unbeaufsichtigter Docker-freier Adapter. Der Plan nennt
vorhandene Skriptpfade; diese nicht ungeprueft ausfuehren. Die
tool-spezifischen Plattform-, Lizenz- und Laufzeitgrenzen oben gelten weiterhin.

Fuer die interaktive Installation nach Pruefung `bash setup_ultimate.sh` im
VPS-Terminal oeffnen, dort im Tool-Management das gewuenschte Tool
`LangGraph` (ID `langgraph`) waehlen und die Einzelfreigaben lesen.
Fehlt der Eintrag oder ist der native Weg gesperrt, hier stoppen: keine
Legacy-/Docker-Ausweichinstallation und kein automatischer Plattformwechsel.

Das interaktive Setup bleibt nach bewusster Freigabe im SSH-Terminal erreichbar:

```bash
bash setup_ultimate.sh
```

Keine automatische Installation, kein Browser-/Modell-/Produktivdienststart durch diese Dokumentation.
Nach jedem bewusst ausgefuehrten Befehl den Exitcode unmittelbar mit `echo $?` pruefen;
zum Verlassen des VPS-Terminals `exit` verwenden.

[SSH-Voraussetzungen und Sicherheitsgrenzen](../HEADLESS_SETUP.md) | [Befehle aller registrierten Tools](../generated/HEADLESS_TOOL_COMMANDS.md)

Dieser Abschnitt wird aus der Registry erzeugt. Pflege: `python3 -I -B scripts/quality/tool_ssh_docs.py --write`.

<!-- END GENERATED VPS SSH -->
