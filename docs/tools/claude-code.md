# Claude Code: Coding-Agent, GitHub und Open-Source-Grenze

**Claude Code ist der Coding-Agent mit dem Befehl `claude`:** Er kann Code
lesen, Dateien bearbeiten, Tests und Terminalwerkzeuge verwenden.
Ein API-Client wie `ant` ist nicht dasselbe Produkt.

## Lizenzpruefung vom 21.10.2026

Das offizielle Repository ist
[anthropics/claude-code](https://github.com/anthropics/claude-code).
Seine [LICENSE.md](https://github.com/anthropics/claude-code/blob/main/LICENSE.md)
behaelt die Rechte vor und verweist auf Anthropics Commercial Terms.
**Der eigentliche Coding-Agent ist damit nicht als Open Source freigegeben.**
Ein oeffentliches GitHub-Repository, verfuegbare Plugins, kostenlose Nutzung
eines anderen Modells oder eine Quellcode-Spiegelung ersetzen keine
Open-Source-Lizenz. Daraus darf kein vermeintlicher vollstaendiger
GitHub-Source-Build des Original-Agenten abgeleitet werden.

Die [offizielle README](https://github.com/anthropics/claude-code#get-started)
beschreibt eine native Distribution ueber Anthropic und Paketmanager;
die npm-Installation wird dort inzwischen als veraltet eingeordnet.
Der [GitHub-Releasebereich](https://github.com/anthropics/claude-code/releases)
allein ist weder ein Lizenznachweis noch eine vollstaendige Buildanleitung.
Keine unbestaetigten Binary-URLs, Forks oder Drittanbieter-Repackages verwenden.

## Was im Setup vorhanden ist

| Eintrag | Tatsaechlicher Umfang | Nicht versprochen |
| --- | --- | --- |
| `Claude_Code` | Gepinnter GitHub-Checkout von Referenzmaterial/Plugins | Keine daraus gebaute funktionsfaehige `claude`-CLI |
| `Claude_Code_Agent` | Rollen-/Routingvorlage | Kein gestarteter Coding-Agent |
| [Anthropic_CLI / ant](anthropic-cli.md) | Offizieller MIT-API-Client mit eigenem GitHub-Buildinstaller | Kein Ersatz fuer Claude Code |
| [YouTube_Agent_Skill](youtube-agent-skill.md) | Optionales Skill-Paket fuer einen bereits eingerichteten kompatiblen Agenten | Keine Installation von Claude Code |

Die vorhandenen Eintraege bleiben getrennt. Die Vorgabe **GitHub statt Docker**
wird nicht durch einen heimlichen Download von claude.ai/npm umgangen.
Es wird deshalb kein nicht vorhandener Open-Source-Installer fuer Claude Code
hinzugefuegt. Eine zusaetzliche proprietaere Distribution waere ein eigener,
ausdruecklich so benannter Installationsweg mit separater Lizenzpruefung.

## Echte quelloffene Coding-Clients

| Projekt | Lizenzquelle | Einordnung |
| --- | --- | --- |
| [Qwen Code](https://github.com/QwenLM/qwen-code) | [Apache-2.0](https://github.com/QwenLM/qwen-code/blob/main/LICENSE) | Bereits im Setup; [GitHub-Buildanleitung](qwen-code.md) |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | [Apache-2.0](https://github.com/google-gemini/gemini-cli/blob/main/LICENSE) | Bereits als gepinnte Quellvorbereitung dokumentiert; [Umfang](../agents/coding-agent-profiles.md) |
| [OpenCode](https://github.com/anomalyco/opencode) | [MIT](https://github.com/anomalyco/opencode/blob/dev/LICENSE) | Eigenstaendiges Projekt, kein umbenannter Claude-Code-Fork; hier nur Alternative, kein neuer Installer |

Die Lizenz des Clients sagt nichts ueber Modellgewichte, Cloud-Preise,
Zugangsberechtigung oder unbegrenzte kostenlose Inferenz aus.

## Claude Code mit Ollama ist keine neue Open-Source-Lizenz

Ollama dokumentiert eine
[Claude-Code-Anbindung](https://docs.ollama.com/integrations/claude-code)
ueber seine Anthropic-kompatible Schnittstelle. Damit kann ein separat
installierter Claude-Code-Client andere Modelle verwenden. Der Client wird
dadurch nicht Open Source. Lokale und Cloud-Modelle unterscheiden; kein
automatisches `ollama launch`, Modell-Pull oder Agentenstart im Setup.

Bei lokaler Inferenz entfallen die entsprechenden Cloud-Tokengebuehren,
aber Strom, Hardware, Speicher und Betreuung bleiben Kostenfaktoren.
Werkzeugfreigaben, Queue und Datenschutz gelten weiterhin.

Weiter: [Coding-Agent-Profile](../agents/coding-agent-profiles.md),
[Free-Tier-Quellen und Auswertung](../_API-Keys/FREE_TIERS_AND_TRIAL_CREDITS.md).
