# Install Checklist

Diese Checkliste beschreibt den aktuell empfohlenen Weg für ein sauberes Setup. Sie ist bewusst anfängerfreundlich gehalten und trennt Basis, optionale Profile und Prüfungen.

## 1. Repository und Basis aktualisieren

```bash
cd ~/openclaw_ultimate_setup
git fetch origin --prune
git reset --hard origin/main
bash ./setup_ultimate.sh
```

## 2. Vor dem ersten größeren Ausbau prüfen

- `⚙ Optionen` öffnen und die Setup-Sprache festlegen
- Benutzer-Workspace prüfen: `~/.openclaw_ultimate_user_data`
- Ressourcen prüfen:

```bash
bash scripts/lib/resource_check.sh --summary /
```

- Version lokal und online vergleichen:

```bash
grep 'APP_VERSION=' ~/openclaw_ultimate_setup/setup_ultimate.sh
git -C ~/openclaw_ultimate_setup show origin/main:setup_ultimate.sh | grep 'APP_VERSION='
```

## 3. Basis-Setup ausführen

Empfohlen für Einsteiger:

1. `Setup-Update + System-Update`
2. `Standalone: Nur MiniPC (Lokal)` oder `Hybrid`
3. OpenClaw-Konfiguration bearbeiten
4. mindestens ein Ollama-Modell laden

## 4. OpenClaw und Ollama prüfen

Wichtige lokale Prüfungen:

```bash
ollama list
curl -fsS http://127.0.0.1:11434/api/tags
```

## 5. Erst dann Profile wählen

Empfohlene Reihenfolge:

1. Grundprofil:
   - `Programmierer`
   - `RAG_Wissensdatenbank`
   - `Office_Productivity`
   - `Smart_Home_Automation`
2. Spezialisierung:
   - `Image_Generation_Studio`
   - `Video_Generation_Studio`
   - `Voice_Clone_TTS_Studio`
   - `Data_Analytics_BI`
3. Betriebs- und Sicherheitsprofile:
   - `Security_DevSecOps`
   - `Monitoring_Observability`
   - `Backup_Recovery`
   - `DevOps_SRE_Agent`

## 6. Nach jeder größeren Installation ausführen

Portkonflikte prüfen:

```bash
bash scripts/operations/check_port_conflicts.sh
```

Registry-basierte Tool-Checks:

```bash
bash scripts/operations/tool_healthcheck.sh
```

Security-Basischeck:

```bash
bash scripts/operations/security_scan.sh
```

## 7. Vor riskanten Profilen unbedingt lesen

- `Trading_Crypto_Web3` und `Web3_Crypto_Agent`:
  niemals Seed-Phrases, Wallet-Private-Keys oder echte Börsen-API-Keys ins Repo speichern
- `MCP_Agent_Tools`:
  Shell-/Browser-/Filesystem-Zugriff nur mit Safe-Mode und bewusster Freigabe nutzen
- `Cloudflare Tunnel`:
  öffentliche Ports, Token und Policies absichern

## 8. Für Medien-Profile zusätzlich prüfen

- GPU/VRAM vorhanden?
- genug freier SSD-Speicher?
- WSL2/Docker/NVIDIA-Setup korrekt?

Besonders relevant für:
- `Image_Generation`
- `Image_Generation_Studio`
- `Video_Generation`
- `Video_Generation_Studio`
- `Visual_Creator`

## 9. Backup nicht vergessen

Vor großen Umbauten:

```bash
bash scripts/operations/backup_run.sh
```

Wiederherstellung testen:

```bash
bash scripts/operations/restore_test.sh
```
