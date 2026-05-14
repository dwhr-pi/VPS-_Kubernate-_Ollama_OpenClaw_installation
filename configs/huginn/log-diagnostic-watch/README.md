# Huginn Log Diagnostic Watch

Dieser kleine Worktree verbindet die OpenClaw-Diagnoseberichte mit Huginn und Codex.

Ziel:

- neue Markdown-Diagnoseberichte in `~/.openclaw_ultimate_user_data/diagnostic_reports/` erkennen
- daraus eine lokale Codex-Übergabedatei in `~/.openclaw_ultimate_user_data/codex_handoffs/` erzeugen
- Huginn optional regelmäßig prüfen lassen, ob neue Berichte eingegangen sind
- keine Secrets ins Repository schreiben

## Dateien

- `huginn_scenario_openclaw_log_watch.template.json`
  Vorlage für einen Huginn ShellCommandAgent.
- `sample_log_event.json`
  Beispielausgabe des Check-Skripts.
- `codex_handoff_template.md`
  Beispiel, wie die erzeugte Übergabedatei aufgebaut ist.

## Schnelltest

```bash
cd ~/openclaw_ultimate_setup
bash scripts/tool_log_diagnostics.sh --tool Huginn --no-email
bash scripts/huginn_log_worktree/check_log_intake.sh
ls -1t ~/.openclaw_ultimate_user_data/codex_handoffs/*.md | head
```

Beim zweiten Aufruf ohne neuen Bericht sollte `no_new_reports` erscheinen.

## Huginn-Hinweis

Der Huginn `ShellCommandAgent` ist mächtig und deshalb standardmäßig deaktiviert. Für diese lokale Aufgabe muss in `/opt/huginn/.env` bewusst gesetzt werden:

```env
ENABLE_INSECURE_AGENTS=true
```

Nur auf einem eigenen lokalen System aktivieren. Keine fremden Nutzer auf diese Huginn-Instanz lassen, wenn ShellCommandAgent aktiviert ist.
