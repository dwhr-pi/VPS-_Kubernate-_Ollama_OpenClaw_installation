# Mistral AI Integration

Diese Seite beschreibt, wie Mistral-Modelle in dieses Setup mit `Ollama`, `OpenClaw`, lokalen Agenten und Coding-Workflows passen.

## Was ist Mistral AI?

Mistral AI ist ein europaeisches KI-Unternehmen mit starkem Fokus auf leistungsfaehige Modelle, die sich gut fuer Self-Hosting, lokale Inferenz und hybride Plattformen eignen.

Fuer dieses Repository ist Mistral besonders interessant, weil:

- mehrere Modelle lokal oder halb-lokal nutzbar sind
- die Modellfamilie von kompakten 7B-/12B-Varianten bis zu staerkeren MoE- und Coding-Modellen reicht
- die Modelle in `Ollama` gut verfuegbar sind
- Mistral-Modelle oft eine gute Balance aus Leistung, Geschwindigkeit und Hardwarebedarf bieten

## Open Source und Open Weight

Wichtig ist die Unterscheidung:

- `Fully Open Source` bedeutet normalerweise: Gewichte, Code, Lizenz und oft auch wesentliche Trainingsinformationen sind offen genug, um das Modell breit selbst zu nutzen, zu veraendern und weiterzugeben.
- `Open Weight` bedeutet: Die Modellgewichte sind oeffentlich verfuegbar, aber nicht automatisch der gesamte Trainingsprozess, die Trainingsdaten oder jede Nutzungsform.

Fuer Mistral gilt:

- viele Mistral-Modelle sind als `Open` oder `Open Weight` veroeffentlicht
- mehrere Gewichte stehen laut Mistral unter `Apache 2.0`
- nicht alle Modelle sind gleich offen oder gleich lizenziert
- Trainingsdaten und kompletter Trainingsprozess sind haeufig nicht vollstaendig offen dokumentiert

Praxis fuer dieses Setup:

- `mistral:7b`, `mixtral`, `mistral-nemo` und `devstral` sind gute lokale Kandidaten
- `codestral` ist fuer Coding sehr interessant, sollte aber lizenzseitig getrennt betrachtet werden
- fuer produktive oder kommerzielle Nutzung immer das konkrete Modell und seine Lizenz pruefen

## Warum Mistral fuer lokale KI-Agentensysteme interessant ist

Mistral passt gut zu diesem Projekt, weil die Modelle fuer mehrere typische Pfade brauchbar sind:

- `Ollama`-basierte lokale Inferenz
- `OpenClaw` als Agenten-Orchestrator
- Coding- und Repository-Workflows
- lokale oder hybride Multi-Agent-Architekturen
- Self-Hosting ohne Pflicht zur Cloud

Typische Vorteile:

- gute Inferenzgeschwindigkeit bei moderatem Ressourcenbedarf
- starke allgemeine Modelle fuer Routing, RAG und Assistenten
- starke Coding-Modelle fuer Entwicklerprofile
- gute Eignung fuer Agenten, die Tool-Aufrufe, Planung und mehrstufige Workflows brauchen

## Empfohlene Mistral-Modelle fuer dieses Setup

| Modell | Zweck | Empfehlung |
|---|---|---|
| `mistral:7b` | leichtgewichtiges Allround-Modell | gut fuer VPS, kleine Systeme, Tests und lokale OpenClaw-Basis |
| `mistral-nemo:12b` | allgemeines Modell mit langem Kontext | gut fuer RAG, Routing, groessere Dokumente und bessere Balance als 7B |
| `mixtral:8x7b` | starke General AI mit MoE | gut als Hauptagent auf staerkeren lokalen Systemen |
| `mixtral:8x22b` | High-End General AI | fuer grosse Server, viele Dokumente, grosse Kontexte und hochwertige Hauptagenten |
| `codestral:22b` | Coding und Refactoring | gut fuer Codex-nahe Entwicklerpfade und lokale Coding-Assistenten |
| `devstral:24b` | agentisches Software Engineering | sehr gut fuer Multi-File-Edits, Tool-Nutzung und Coding-Agenten |

## Empfehlung nach Einsatzfall

### Kleine Systeme

- `mistral:7b`
- optional `mistral-nemo:12b`, wenn mehr RAM vorhanden ist

### Allgemeine OpenClaw- und RAG-Workflows

- `mistral:7b` fuer kompakte lokale Starts
- `mistral-nemo:12b` fuer laengeren Kontext
- `mixtral:8x7b` als staerkerer Hauptagent

### Entwickler- und Coding-Workflows

- `codestral:22b` fuer Coding
- `devstral:24b` fuer agentische Software-Engineering-Aufgaben
- `mixtral:8x7b` als allgemeiner Planungs- oder Review-Agent

### Grosse Maschinen oder Server

- `mixtral:8x22b`
- `devstral:24b`

## Ollama Integration

Typische Befehle:

```bash
ollama pull mistral
ollama pull mistral-nemo
ollama pull mixtral
ollama pull mixtral:8x22b
ollama pull codestral
ollama pull devstral
```

Direkter Start:

```bash
ollama run mistral
ollama run mixtral
ollama run codestral
```

Fuer `OpenClaw` oder andere lokale Agenten ist ein typischer `.env`-Ausschnitt:

```env
OLLAMA_HOST=http://127.0.0.1:11434
OLLAMA_MODEL=mistral:7b
```

Oder fuer Coding-Agenten:

```env
OLLAMA_HOST=http://127.0.0.1:11434
OLLAMA_MODEL=devstral:24b
```

## Praktische Empfehlung fuer dieses Repository

Als einfache Staffelung:

1. `mistral:7b` fuer kompakte lokale Tests
2. `mistral-nemo:12b` fuer mehr Kontext und staerkere allgemeine Nutzung
3. `mixtral:8x7b` als staerkerer Hauptagent
4. `codestral:22b` oder `devstral:24b` fuer Entwicklerprofile
5. `mixtral:8x22b` nur auf wirklich grossen Maschinen

## Quellen

- [Mistral Models Overview](https://docs.mistral.ai/models)
- [Mistral Model Weights and Licenses](https://docs.mistral.ai/getting-started/models/weights/)
- [Mistral 7B](https://docs.mistral.ai/models/model-cards/mistral-7b-0-1)
- [Mistral Nemo 12B](https://docs.mistral.ai/models/mistral-nemo-12b-24-07)
- [Ollama: mistral](https://ollama.com/library/mistral)
- [Ollama: mixtral](https://ollama.com/library/mixtral)
- [Ollama: codestral](https://ollama.com/library/codestral)
- [Ollama: devstral](https://ollama.com/library/devstral)
