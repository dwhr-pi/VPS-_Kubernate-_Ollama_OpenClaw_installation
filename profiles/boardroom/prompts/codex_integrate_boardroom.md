# Codex-Prompt: Boardroom-Skill in Ultimate KI Setup integrieren

Du arbeitest im Repository:

```text
https://github.com/dwhr-pi/VPS-_Kubernate-_Ollama_OpenClaw_installation
```

Ziel: Integriere eine OpenClaw-/Ollama-kompatible Boardroom-Skill fuer strategische Entscheidungen. Die urspruengliche Idee stammt aus einer Claude-Skill, muss aber vollstaendig fuer unser Setup umgebaut werden.

## Aufgaben

1. Suche im Repo nach vorhandenen Profilen unter:

```text
docs/Profile/
docs/Profil/
docs/profile/
```

2. Erstelle oder aktualisiere ein Profil:

```text
docs/Profile/Boardroom.md
```

Falls die vorhandene Struktur deutsch `Profil` statt `Profile` nutzt, passe dich an die bestehende Struktur an und dokumentiere die Entscheidung.

3. Erstelle zusaetzlich eine Skill-Datei:

```text
skills/boardroom/SKILL.md
```

4. Entferne alle Claude-spezifischen Annahmen:

- keine Pflicht auf `CLAUDE.md`
- keine Claude-Code-Installation
- keine Claude-Cowork-Hinweise
- keine Claude-Toolnamen wie `Glob`/`Read` als zwingende Voraussetzung

5. Ersetze sie durch OpenClaw-/Ollama-kompatiblen Kontext:

- `README.md` oder `readme.md`
- `docs/Profile/*.md` oder `docs/Profil/*.md`
- `memory/*.md`
- `.env.example`
- `install*.sh`
- `setup*.sh`
- fruehere Boardroom-Protokolle

6. Implementiere die Boardroom-Logik als Dokumentation und nutzbaren Prompt:

- Frage framen
- CFO analysiert
- Operator analysiert
- Vertriebler analysiert
- Mentor analysiert
- Skeptiker analysiert
- Antworten anonymisieren
- Peer-Review durchfuehren
- Chairman-Verdict erzeugen

7. Ergaenze Setup-spezifische Gewichtung:

- Datenschutz und lokale Kontrolle hoch gewichten
- Cloud-Lock-in vermeiden
- Docker nur optional, weil dieses Projekt Git-/Shell-Installationen bevorzugt
- WSL2/Ubuntu/Ollama/OpenClaw/n8n/Cloudflare Tunnel/Tailscale/Home Assistant/Kubernetes beruecksichtigen
- bei Security-Fragen Skeptiker und Operator staerker gewichten
- bei VPS-/GPU-/Kubernetes-Fragen CFO, Operator und Skeptiker staerker gewichten

## README-Hinweis

```markdown
## Boardroom-Profil

Das Boardroom-Profil hilft bei strategischen Entscheidungen im Setup. Es simuliert CFO, Operator, Vertriebler, Mentor und Skeptiker und erzeugt danach ein Chairman-Verdict. Aktivierung z.B. mit: `Boardroom rufen: Soll ich X oder Y fuer unser Setup nutzen?`
```
