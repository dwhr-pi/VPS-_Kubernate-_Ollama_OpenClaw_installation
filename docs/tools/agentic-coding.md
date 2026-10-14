# Tools fuer Agentic Coding

[Ausfuehrlicher Einsteiger-Leitfaden](../AGENTIC_CODING_GUIDE.md).
Stand: 14.10.2026. Registriert bedeutet **nicht** erfolgreich installiert,
getestet, sicher konfiguriert oder produktionsreif. Keine Installation wurde
fuer diesen Leitfaden ausgefuehrt.

## Vorhandene Tools bewusst auswaehlen

| Registry-ID | Primaerquelle | Rolle | Tatsaechlicher Setup-Pfad / Grenze |
|---|---|---|---|
| `aider` | [Aider-AI/aider](https://github.com/Aider-AI/aider) | Terminal-Coding, Diff und Testfeedback | GitHub-/venv-Scaffold; Abhaengigkeiten kommen auch aus Python-Paketquellen; Versions-/Smoke-Test offen |
| `continue_dev` | [continuedev/continue](https://github.com/continuedev/continue) | editornahe Coding-/Agentenarbeit | GitHub/npm-Scaffold; eine erfolgreiche Source-Installation ersetzt keine konfigurierte IDE-Integration |
| `opencode` | [anomalyco/opencode](https://github.com/anomalyco/opencode) | Coding-Client | Registry weiterhin planned/Stub, nicht durch ungenutztes Scaffold-Skript aktivieren; alte Quelle sst/opencode nicht mit einem getesteten aktuellen Build verwechseln |
| `openhands` | [OpenHands/OpenHands](https://github.com/OpenHands/OpenHands) | agentische Repo-/Sandbox-Aufgaben | Scaffold mit benoetigter Laufzeitkonfiguration, kein fertig getesteter Sandbox-Betrieb; Docker-/Hostzugriff pruefen |
| `langgraph` | [langchain-ai/langgraph](https://github.com/langchain-ai/langgraph) | explizite Workflows/Zustandsgraphen | vorhandener Python-Paket-Installer; nicht automatisch GitHub-Source-Build, kein fertiger Coding-Agent |
| `crewai` | [crewAIInc/crewAI](https://github.com/crewAIInc/crewAI) | Rollen-/Multi-Agent-Orchestrierung | vorhandener Installer, Ende-zu-Ende-Integration und Rechtekonzept nicht nachgewiesen |
| `autogen` | [microsoft/autogen](https://github.com/microsoft/autogen) | vorhandene Multi-Agent-Anwendungen | Upstream Maintenance Mode; bestehende Projekte erhalten, Migration gesondert planen |
| `agent_framework` | [microsoft/agent-framework](https://github.com/microsoft/agent-framework) | optionaler Orchestrierungs-Kandidat | **neu planned**, nur Registrierung/Plan, kein Download/Build/Start; Python/.NET, kein fertiger Repo-Coder |
| `automaton` | [Conway-Research/automaton](https://github.com/Conway-Research/automaton) | autonome Runtime als Forschungsreferenz | **planned/high-risk**, nur eigener Offline-Vorschlagspruefer; Runtime/Wallet/Signieren/Cloud/Replikation gesperrt |

Die Quellen wurden fuer die Dokumentation geprueft, aber weder deren Lizenzen
und Abhaengigkeiten vollstaendig auditiert noch ihre Kombination getestet.
GitHub als Primaerquelle bedeutet nicht, dass npm/PyPI-/Image-Abhaengigkeiten
verschwinden. Bestehende Installer nicht allein zum Nachlesen starten: nicht
jeder aeltere Installer hat ein nebenwirkungsfreies `--dry-run`.

AutoGen verweist selbst auf Microsoft Agent Framework als Nachfolger.
Das ist eine Upstream-Empfehlung, keine automatisch vollzogene Migration
oder Garantie unserer Integration. Modellzugang, API-Kompatibilitaet und
Deployment muessen separat getestet werden.
[Upstream-Hinweis](https://github.com/microsoft/autogen#readme).

## Kein Installationspaket fuer alles

Minimal: ein Coding-Client, ein vorhandenes Modell und festgelegte Tests.
Ollama ist eine Modellruntime, nicht selbst der Coding-Agent. Ein LLM benoetigt
passende Tool-Calling-/Kontext-Faehigkeiten und ist deshalb nicht beliebig
gegen jedes andere Modell austauschbar. Lokale Provider-/Client-Kompatibilitaet
vor vertraulichem Einsatz mit synthetischen Aufgaben pruefen.

Ausbau nach Bedarf: LangGraph **oder** ein passendes Orchestrierungsframework,
nicht alle Frameworks parallel. OpenClaw/n8n koennen spaeter freigegebene,
strukturierte Auftraege vermitteln; sie erhalten keine ungefilterten Shellstrings
aus Mails, Webseiten oder Modellantworten. Bei der
[WebsiteFactory](websitefactory.md) den dortigen Prototyp-/Integrationsstand
beachten, nicht automatisch einen fertigen SaaS-Generator annehmen.

Qualitaetswerkzeuge aus dem vorhandenen Setup: Playwright fuer isolierte
Browserchecks, Gitleaks fuer Secret-Scan, Semgrep fuer zusaetzliche Codepruefungen.
Ein Scanner-Ergebnis ist keine Zertifizierung. Browsertests koennen Daten
versenden; nur Testkonten, Testzahlungen und freigegebene Ziele verwenden.

## Neue Registrierung gefahrlos pruefen

```bash
bash scripts/tools/agent_framework_install.sh --dry-run
bash scripts/tools/agent_framework_status.sh
bash scripts/profiles/Agentic_Coding_Local_First_install.sh --dry-run
```

Die Framework-Pruefung liefert `installed: false`, `scope: registration_only`.
Ein normaler Install-/Update-/Uninstall-Aufruf endet mit Exit-Code 2,
ohne Download oder Statusmarkierung. Ein Doctor-Ergebnis prueft hier nur die
Registrierung, keine SDK-/Modellfunktion. Es werden keine Ports geoeffnet.

## Ressourcen und offene Aufgaben

Keine pauschale RAM-/VRAM-Zahl fuer alle Agenten: Client, Modell, Build und
Browser addieren ihren Bedarf. Fuer ein erstes Testprojekt nur einen Auftrag
ausfuehren und messen; keine schweren Installationen im Hintergrund starten.
Secrets liegen nicht in Aufgaben oder Git, sondern im privaten User-Workspace.
Kein automatischer Import aller ENV-Tresorwerte in einen Coding-Agenten.

Offen: versionsgebundene SDK-/Source-Pfade, einheitliche Dry-Runs fuer die
aelteren Installer, echte Client-/Ollama-Smoke-Tests, getestete Sandboxes und
Queue-Locks. Microsoft Agent Framework bleibt bis dahin documentation-first.
Die [Automaton-Integration](automaton.md) behielt ihre separaten Schutzsperren.
