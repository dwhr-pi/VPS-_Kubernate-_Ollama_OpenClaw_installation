# Custom Quellen und Ollama-Builds

Diese Erweiterung erlaubt es, eigene GitHub-Repositories, Forks und Custom-Ollama-Builds sauber im Setup zu hinterlegen, ohne die Standardquellen im Quellcode unlesbar zu machen.

## Ziel

Du kannst jetzt:

- Standard-Repositories für Tools und Hauptprogramme überschreiben
- eigene GitHub-Forks dokumentiert im Benutzer-Workspace speichern
- daraus lokale Build-Workspaces anlegen
- eigene Ollama-Modelfiles erzeugen
- exportierte GGUF-Modelle in Ollama registrieren

Wichtig:

- Die benutzerdefinierten Quellen liegen bewusst **nicht** im Git-Repository.
- Sie werden unter `~/.openclaw_ultimate_user_data` gespeichert.
- Dadurch bleiben eigene Forks, URLs und Build-Notizen bei Repo-Updates erhalten.

## Wo die Daten gespeichert werden

### Custom GitHub-Quellen

```bash
~/.openclaw_ultimate_user_data/custom_sources.conf
```

### Eigene geklonte Quellen

```bash
~/.openclaw_ultimate_user_data/custom_sources/
```

### Eigene Ollama-Build-Notizen

```bash
~/.openclaw_ultimate_user_data/custom_ollama_builds.conf
```

### Eigene Modelfiles

```bash
~/.openclaw_ultimate_user_data/modelfiles/
```

## Neue Option im Setup

Im Menü `⚙ Optionen` gibt es jetzt:

- `Custom GitHub-Quellen & Ollama-Builds`

Dort kannst du:

1. `custom_sources.conf` bearbeiten
2. `custom_ollama_builds.conf` bearbeiten
3. vorhandene Custom-Quellen anzeigen
4. ein eigenes Repo klonen oder aktualisieren
5. einen Custom-Ollama-Build vorbereiten oder direkt registrieren

## Unterstützte Override-Quellen

Derzeit sind besonders sinnvoll vorbereitet:

- `OpenClaw`
- `OpenManus`
- `Open WebUI`
- `LiteLLM`
- `ComfyUI`
- `FinGPT`
- `FinRobot`
- `FinRAG`

Beispiel in `custom_sources.conf`:

```bash
# Standard FinGPT: https://github.com/AI4Finance-Foundation/FinGPT.git
CUSTOM_REPO_FINGPT_URL="https://github.com/DEINNAME/FinGPT.git"
```

## Finanz-LLMs in Ollama nutzbar machen

Bei GitHub-Projekten wie `FinGPT`, `FinRobot` oder `FinRAG` gilt:

- Das Quellrepo allein ist **noch kein sofort nutzbares Ollama-Modell**
- in der Regel brauchst du zusätzlich:
  - ein Basismodell
  - Fine-Tuning oder Adapter
  - Export nach `GGUF`
  - ein `Modelfile`

### Typischer Ablauf

1. GitHub-Repo oder Fork wählen
2. lokal klonen
3. Basismodell wählen
4. Fine-Tuning / LoRA / QLoRA durchführen
5. nach `GGUF` exportieren
6. `Modelfile` erzeugen
7. mit `ollama create` registrieren

### Beispiel

```bash
ollama pull qwen3:30b
```

Danach nach dem Fine-Tuning/Export:

```bash
ollama create fingpt-fork-local -f ~/.openclaw_ultimate_user_data/modelfiles/fingpt-fork-local.Modelfile
ollama run fingpt-fork-local
```

## Beispiel für einen eigenen Fork

Angenommen, du hast einen eigenen Fork von `FinGPT`.

### 1. Quelle im Setup hinterlegen

```bash
CUSTOM_REPO_FINGPT_URL="https://github.com/DEINNAME/FinGPT.git"
```

### 2. Quelle in den Workspace holen

Über `⚙ Optionen -> Custom GitHub-Quellen & Ollama-Builds`

oder manuell:

```bash
git clone https://github.com/DEINNAME/FinGPT.git ~/.openclaw_ultimate_user_data/custom_sources/fingpt-fork
```

### 3. Build vorbereiten

Im neuen Manager einen Build-Namen, Basismodell, Quellordner und später den GGUF-Pfad eintragen.

### 4. Modelfile prüfen

Beispiel:

```text
FROM /pfad/zu/deinem/exportierten-modell.gguf

PARAMETER temperature 0.2
PARAMETER num_ctx 32768

SYSTEM You are a finance analysis model prepared for structured market, report and risk analysis. You must not claim to execute trades autonomously.
```

### 5. In Ollama registrieren

```bash
ollama create fingpt-fork-local -f ~/.openclaw_ultimate_user_data/modelfiles/fingpt-fork-local.Modelfile
```

## Downloadgrößen grob einschätzen

### Nur GitHub-Quellrepos

Die Quellrepos selbst sind meist deutlich kleiner als die späteren Modelle.

Richtwert:

- Repo-Download: oft nur einige MB bis wenige 100 MB
- Python-/Node-Abhängigkeiten: zusätzlich mehrere 100 MB bis einige GB

### Eigentliche Modellgewichte

Die großen Datenmengen entstehen meist erst durch:

- Basismodelle
- Checkpoints
- Adapter
- GGUF-Exporte
- Embeddings oder Datasets

Richtwerte für lokale Modellgrößen findest du in:

- [docs/OLLAMA_MODEL_CATALOG.md](/C:/Users/danie/.codex/worktrees/967e/VPS,_Kubernate,_Ollama_OpenClaw_installation/docs/OLLAMA_MODEL_CATALOG.md:1)

## Für eigene Tools und Hauptprogramme

Das gleiche Muster funktioniert auch für andere Komponenten:

- Fork in `custom_sources.conf` eintragen
- Quelle lokal klonen
- Tool-Installer mit Override nutzen
- Build-/Compose-/Python-/Node-Schritte lokal ausführen

Das ist besonders sinnvoll für:

- `OpenClaw`
- `OpenManus`
- `Open WebUI`
- `LiteLLM`
- `ComfyUI`
- eigene Finanz- oder RAG-Forks

## Sicherheits- und Betriebsregeln

- keine Tokens, PATs, API-Keys oder Seeds in diese Dateien schreiben
- nur GitHub-URLs und Build-Metadaten speichern
- echte Secrets weiterhin nur in `.env` oder sicheren Secret-Speichern pflegen
- bei Trading-/Web3-Forks keine autonome Live-Orderlogik als Standardpfad bauen
